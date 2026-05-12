#!/usr/bin/with-contenv bashio

source scripts/home-assistant.sh
source scripts/hypon.sh
source scripts/mqtt.sh
source scripts/variables.sh

loadSensorData() {
  authToken=$1
  local lastInverterRefresh=0
  local inverterRefreshInterval
  inverterRefreshInterval=$(bashio::config 'inverter_refresh_interval')
  if [ -z "$inverterRefreshInterval" ] || [ "$inverterRefreshInterval" = "null" ]; then
    inverterRefreshInterval=3600
  fi

  while true
  do
    solarData=$(retrieveSolarData "$authToken")
    realTimeData=$(retrieveRealTimeSolarData "$authToken")

    # 502 Bad Gateway check
    if echo "$solarData" | grep -q "502 Bad Gateway" || echo "$realTimeData" | grep -q "502 Bad Gateway"; then
      bashio::log.error "Hypon.cloud returned 502 Bad Gateway - skipping this update cycle"
      sleep "$(bashio::config 'refresh_time')"
      continue
    fi

    # JSON validation for solar data
    if ! echo "$solarData" | jq -e . >/dev/null 2>&1; then
      bashio::log.error "Invalid JSON from daily data endpoint, refreshing auth token"
      bashio::log.debug "Daily data raw response: $solarData"
      authToken=$(loginHypon) || true
      sleep "$(bashio::config 'refresh_time')"
      continue
    fi

    # JSON validation for realtime data
    if ! echo "$realTimeData" | jq -e . >/dev/null 2>&1; then
      bashio::log.error "Invalid JSON from realtime endpoint, refreshing auth token"
      bashio::log.debug "Realtime raw response: $realTimeData"
      authToken=$(loginHypon) || true
      sleep "$(bashio::config 'refresh_time')"
      continue
    fi

    solarDataResponseCode=$(echo "$solarData" | jq -r '.code // "unknown"')

    bashio::log.debug "Response Code From loading solar data: $solarDataResponseCode"

    if [ "$solarDataResponseCode" = "20000" ]; then
      bashio::log.debug "Data retrieved successfully"

      # --- Daily Energy Sensors (from /energy2) ---
      bashio::log.info "Updating Daily Energy Sensors"
      update-sensor "$INVERTER_AC_OUT_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.kwhac')" "$INVERTER_AC_OUT_TODAY_SENSOR_NAME"
      update-sensor "$TOTAL_ENERGY_USED_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.load')" "$TOTAL_ENERGY_USED_TODAY_SENSOR_NAME"
      update-sensor "$BATTERY_USED_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.load_from_bat')" "$BATTERY_USED_TODAY_SENSOR_NAME"
      update-sensor "$GRID_USED_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.load_from_grid')" "$GRID_USED_TODAY_SENSOR_NAME"
      update-sensor "$PV_USED_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.load_from_pv')" "$PV_USED_TODAY_SENSOR_NAME"
      update-sensor "$TOTAL_PV_GENERATED_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.pvkwh')" "$TOTAL_PV_GENERATED_TODAY_SENSOR_NAME"
      update-sensor "$PV_TO_BATTERY_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.pv_to_bat')" "$PV_TO_BATTERY_TODAY_SENSOR_NAME"
      update-sensor "$PV_TO_GRID_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.pv_to_grid')" "$PV_TO_GRID_TODAY_SENSOR_NAME"
      update-sensor "$PV_TO_LOAD_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.pv_to_load')" "$PV_TO_LOAD_TODAY_SENSOR_NAME"
      update-sensor "$ENERGY_BALANCE_TODAY_TEMPLATE" "$(echo "$solarData" | jq -r '.data.balance')" "$ENERGY_BALANCE_TODAY_SENSOR_NAME"

      # --- Real-time Power Sensors (from /monitor) ---
      bashio::log.info "Updating Real-time Power Sensors"
      update-sensor "$PV_POWER_NOW_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.power_pv')" "$PV_POWER_NOW_SENSOR_NAME"
      update-sensor "$GRID_POWER_NOW_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.meter_power')" "$GRID_POWER_NOW_SENSOR_NAME"
      update-sensor "$LOAD_POWER_NOW_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.power_load')" "$LOAD_POWER_NOW_SENSOR_NAME"
      update-sensor "$BATTERY_POWER_NOW_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.power_bat // .data.w_cha')" "$BATTERY_POWER_NOW_SENSOR_NAME"
      update-sensor "$BATTERY_SOC_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.soc // "unknown"')" "$BATTERY_SOC_SENSOR_NAME"
      update-sensor "$MICRO_POWER_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.micro')" "$MICRO_POWER_SENSOR_NAME"
      update-sensor "$SELF_CONSUMPTION_PERCENT_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.percent')" "$SELF_CONSUMPTION_PERCENT_SENSOR_NAME"

      # --- Generation Tracking Sensors (from /monitor) ---
      bashio::log.info "Updating Generation Tracking Sensors"
      update-sensor "$PV_GENERATION_TODAY_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.e_today')" "$PV_GENERATION_TODAY_SENSOR_NAME"
      update-sensor "$PV_GENERATION_MONTH_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.e_month')" "$PV_GENERATION_MONTH_SENSOR_NAME"
      update-sensor "$PV_GENERATION_YEAR_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.e_year')" "$PV_GENERATION_YEAR_SENSOR_NAME"
      update-sensor "$PV_GENERATION_TOTAL_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.e_total')" "$PV_GENERATION_TOTAL_SENSOR_NAME"

      # --- Status Sensor (from /monitor) ---
      update-sensor "$INVERTER_WARNING_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.warning')" "$INVERTER_WARNING_SENSOR_NAME"

      # --- Earnings & Environmental Sensors (from /monitor) ---
      bashio::log.info "Updating Earnings & Environmental Sensors"
      update-sensor "$TODAY_EARNING_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.today_earning')" "$TODAY_EARNING_SENSOR_NAME"
      update-sensor "$TOTAL_EARNING_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.total_earning')" "$TOTAL_EARNING_SENSOR_NAME"
      update-sensor "$TOTAL_CO2_SAVED_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.total_co2')" "$TOTAL_CO2_SAVED_SENSOR_NAME"
      update-sensor "$TOTAL_TREES_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.total_tree')" "$TOTAL_TREES_SENSOR_NAME"
      update-sensor "$TOTAL_DIESEL_SAVED_TEMPLATE" "$(echo "$realTimeData" | jq -r '.data.total_diesel')" "$TOTAL_DIESEL_SAVED_SENSOR_NAME"

      # --- Per-Inverter Sensors (from /inverter, on slower refresh) ---
      local now
      now=$(date +%s)
      if [ $((now - lastInverterRefresh)) -ge "$inverterRefreshInterval" ]; then
        bashio::log.info "Updating Per-Inverter Sensors"
        local inverterData
        inverterData=$(retrieveInverterData "$authToken")

        if echo "$inverterData" | jq -e '.data[0]' >/dev/null 2>&1; then
          update-sensor "$INVERTER_POWER_TEMPLATE" "$(echo "$inverterData" | jq -r '.data[0].power')" "$INVERTER_POWER_SENSOR_NAME"
          update-sensor "$INVERTER_E_TODAY_TEMPLATE" "$(echo "$inverterData" | jq -r '.data[0].e_today')" "$INVERTER_E_TODAY_SENSOR_NAME"
          update-sensor "$INVERTER_E_TOTAL_TEMPLATE" "$(echo "$inverterData" | jq -r '.data[0].e_total')" "$INVERTER_E_TOTAL_SENSOR_NAME"
          update-sensor "$INVERTER_STATUS_TEMPLATE" "$(echo "$inverterData" | jq -r '.data[0].status')" "$INVERTER_STATUS_SENSOR_NAME"
          update-sensor "$INVERTER_MODEL_TEMPLATE" "$(echo "$inverterData" | jq -r '.data[0].model')" "$INVERTER_MODEL_SENSOR_NAME"
          update-sensor "$INVERTER_FAULTS_TEMPLATE" "$(echo "$inverterData" | jq -r '.data[0].fault')" "$INVERTER_FAULTS_SENSOR_NAME"
          lastInverterRefresh=$now
        else
          bashio::log.warning "No inverter data found in API response"
        fi
      fi

    elif [ "$solarDataResponseCode" = "40000" ]; then
      bashio::log.error "Plant access denied - system_id '$(bashio::config 'system_id')' is not associated with your account"
    else
      bashio::log.error "Data Retrieval Error (code: $solarDataResponseCode) - refreshing auth token"
      authToken=$(loginHypon) || true
    fi

    sleep "$(bashio::config 'refresh_time')"
  done
}

bashio::log.info "Loading Authentication Token"
authToken=""
until [ -n "$authToken" ]; do
  authToken=$(loginHypon) || true
  if [ -z "$authToken" ]; then
    bashio::log.warning "Login failed, retrying in 60 seconds..."
    sleep 60
  fi
done
bashio::log.info "Using system_id: $(bashio::config 'system_id')"
startMqttControlLoop &
loadSensorData "$authToken"
