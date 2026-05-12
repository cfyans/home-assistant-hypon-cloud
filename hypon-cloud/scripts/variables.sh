# Sensor definitions for Hypon Cloud HA Addon
# Power = Watts (W) at a point in time, Energy = kilo-Watt-hours (kWh) over a period

# --------------------------------------------------------------------------
# Daily Energy Sensors (from /plant/{id}/energy2)
# --------------------------------------------------------------------------
declare INVERTER_AC_OUT_TODAY_SENSOR_NAME="sensor.hypon_inverter_ac_out_today"
declare TOTAL_ENERGY_USED_TODAY_SENSOR_NAME="sensor.hypon_total_energy_used_today"
declare BATTERY_USED_TODAY_SENSOR_NAME="sensor.hypon_battery_used_today"
declare GRID_USED_TODAY_SENSOR_NAME="sensor.hypon_grid_used_today"
declare PV_USED_TODAY_SENSOR_NAME="sensor.hypon_pv_used_today"
declare TOTAL_PV_GENERATED_TODAY_SENSOR_NAME="sensor.hypon_total_pv_generated_today"
declare PV_TO_BATTERY_TODAY_SENSOR_NAME="sensor.hypon_pv_to_battery_today"
declare PV_TO_GRID_TODAY_SENSOR_NAME="sensor.hypon_pv_to_grid_today"
declare PV_TO_LOAD_TODAY_SENSOR_NAME="sensor.hypon_pv_to_load_today"
declare ENERGY_BALANCE_TODAY_SENSOR_NAME="sensor.hypon_energy_balance_today"

declare INVERTER_AC_OUT_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_ac_out_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Inverter AC Output Today"}}'
declare TOTAL_ENERGY_USED_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_total_energy_used_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Total Energy Used Today"}}'
declare BATTERY_USED_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_battery_used_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Battery Used Today"}}'
declare GRID_USED_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_grid_used_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Grid Used Today"}}'
declare PV_USED_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_used_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Solar Used Today"}}'
declare TOTAL_PV_GENERATED_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_total_pv_generated_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Total Solar Generated Today"}}'
declare PV_TO_BATTERY_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_to_battery_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Solar to Battery Today"}}'
declare PV_TO_GRID_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_to_grid_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Solar to Grid (Exported) Today"}}'
declare PV_TO_LOAD_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_to_load_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Solar to Load Today"}}'
declare ENERGY_BALANCE_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_energy_balance_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Energy Balance Today"}}'

# --------------------------------------------------------------------------
# Real-time Power Sensors (from /plant/{id}/monitor)
# --------------------------------------------------------------------------
declare PV_POWER_NOW_SENSOR_NAME="sensor.hypon_pv_power_now"
declare GRID_POWER_NOW_SENSOR_NAME="sensor.hypon_grid_power_now"
declare LOAD_POWER_NOW_SENSOR_NAME="sensor.hypon_load_power_now"
declare BATTERY_POWER_NOW_SENSOR_NAME="sensor.hypon_battery_power_now"
declare BATTERY_SOC_SENSOR_NAME="sensor.hypon_battery_soc"
declare MICRO_POWER_SENSOR_NAME="sensor.hypon_micro_power"
declare SELF_CONSUMPTION_PERCENT_SENSOR_NAME="sensor.hypon_self_consumption_percent"
declare GRID_EXPORT_NOW_SENSOR_NAME="sensor.hypon_grid_export_now"
declare GRID_IMPORT_NOW_SENSOR_NAME="sensor.hypon_grid_import_now"

declare PV_POWER_NOW_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_power_now", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "PV Power Now"}}'
declare GRID_POWER_NOW_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_grid_power_now", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Grid Power Now"}}'
declare LOAD_POWER_NOW_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_load_power_now", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Load Power Now"}}'
declare BATTERY_POWER_NOW_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_battery_power_now", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Battery Power Now"}}'
declare BATTERY_SOC_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_battery_soc", "state_class": "measurement", "unit_of_measurement": "%", "device_class": "battery", "friendly_name": "Battery State of Charge"}}'
declare MICRO_POWER_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_micro_power", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Micro Power"}}'
declare SELF_CONSUMPTION_PERCENT_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_self_consumption_percent", "state_class": "measurement", "unit_of_measurement": "%", "friendly_name": "Self Consumption Percent"}}'
declare GRID_EXPORT_NOW_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_grid_export_now", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Grid Export Now"}}'
declare GRID_IMPORT_NOW_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_grid_import_now", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Grid Import Now"}}'

# --------------------------------------------------------------------------
# Generation Tracking Sensors (from /plant/{id}/monitor)
# --------------------------------------------------------------------------
declare PV_GENERATION_TODAY_SENSOR_NAME="sensor.hypon_pv_generation_today"
declare PV_GENERATION_MONTH_SENSOR_NAME="sensor.hypon_pv_generation_month"
declare PV_GENERATION_YEAR_SENSOR_NAME="sensor.hypon_pv_generation_year"
declare PV_GENERATION_TOTAL_SENSOR_NAME="sensor.hypon_pv_generation_total"

declare PV_GENERATION_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_generation_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "PV Generation Today"}}'
declare PV_GENERATION_MONTH_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_generation_month", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "PV Generation This Month"}}'
declare PV_GENERATION_YEAR_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_generation_year", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "PV Generation This Year"}}'
declare PV_GENERATION_TOTAL_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_pv_generation_total", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "PV Generation Lifetime"}}'

# --------------------------------------------------------------------------
# Status Sensor (from /plant/{id}/monitor)
# --------------------------------------------------------------------------
declare INVERTER_WARNING_SENSOR_NAME="sensor.hypon_inverter_warning"

declare INVERTER_WARNING_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_warning", "friendly_name": "Inverter Warning Code"}}'

# --------------------------------------------------------------------------
# Earnings & Environmental Sensors (from /plant/{id}/monitor)
# --------------------------------------------------------------------------
declare TODAY_EARNING_SENSOR_NAME="sensor.hypon_today_earning"
declare TOTAL_EARNING_SENSOR_NAME="sensor.hypon_total_earning"
declare TOTAL_CO2_SAVED_SENSOR_NAME="sensor.hypon_total_co2_saved"
declare TOTAL_TREES_SENSOR_NAME="sensor.hypon_total_trees"
declare TOTAL_DIESEL_SAVED_SENSOR_NAME="sensor.hypon_total_diesel_saved"

declare TODAY_EARNING_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_today_earning", "state_class": "total_increasing", "unit_of_measurement": "GBP", "device_class": "monetary", "friendly_name": "Today Earning"}}'
declare TOTAL_EARNING_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_total_earning", "state_class": "total_increasing", "unit_of_measurement": "GBP", "device_class": "monetary", "friendly_name": "Total Earning"}}'
declare TOTAL_CO2_SAVED_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_total_co2_saved", "state_class": "total_increasing", "unit_of_measurement": "kg", "device_class": "weight", "friendly_name": "Total CO2 Saved"}}'
declare TOTAL_TREES_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_total_trees", "state_class": "total_increasing", "friendly_name": "Trees Planted Equivalent"}}'
declare TOTAL_DIESEL_SAVED_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_total_diesel_saved", "state_class": "total_increasing", "unit_of_measurement": "L", "friendly_name": "Diesel Saved Equivalent"}}'

# --------------------------------------------------------------------------
# Per-Inverter Sensors (from /plant/{id}/inverter)
# --------------------------------------------------------------------------
declare INVERTER_POWER_SENSOR_NAME="sensor.hypon_inverter_power"
declare INVERTER_E_TODAY_SENSOR_NAME="sensor.hypon_inverter_energy_today"
declare INVERTER_E_TOTAL_SENSOR_NAME="sensor.hypon_inverter_energy_total"
declare INVERTER_STATUS_SENSOR_NAME="sensor.hypon_inverter_status"
declare INVERTER_MODEL_SENSOR_NAME="sensor.hypon_inverter_model"
declare INVERTER_FAULTS_SENSOR_NAME="sensor.hypon_inverter_faults"

declare INVERTER_POWER_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_power", "state_class": "measurement", "unit_of_measurement": "W", "device_class": "power", "friendly_name": "Inverter Power"}}'
declare INVERTER_E_TODAY_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_energy_today", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Inverter Energy Today"}}'
declare INVERTER_E_TOTAL_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_energy_total", "state_class": "total_increasing", "unit_of_measurement": "kWh", "device_class": "energy", "friendly_name": "Inverter Energy Lifetime"}}'
declare INVERTER_STATUS_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_status", "friendly_name": "Inverter Status"}}'
declare INVERTER_MODEL_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_model", "friendly_name": "Inverter Model"}}'
declare INVERTER_FAULTS_TEMPLATE='{"state": "unknown", "attributes": {"unique_id": "hypon_cloud_inverter_faults", "friendly_name": "Inverter Fault Count"}}'
