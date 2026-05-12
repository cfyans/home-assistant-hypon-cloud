#!/usr/bin/with-contenv bashio


declare SENSOR_URL="/core/api/states/"

# ------------------------------------------------------------------------------
# Call The HA API to update a sensor value.
#
# Arguments
#  $1 The data to send to the API
#  $2 The Sensor name
# ------------------------------------------------------------------------------
function ha-post-sensor {
    local data=${1}
    local sensor_name=${2}
    local status
    local response

    bashio::log.debug "Posting sensor data to API at ${SENSOR_URL}${sensor_name}"

    if ! response=$(curl --silent --show-error \
        --write-out '\n%{http_code}' --request "POST" \
        -H "Authorization: Bearer ${__BASHIO_SUPERVISOR_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${data}" \
        "${__BASHIO_SUPERVISOR_API}${SENSOR_URL}$2"
    ); then
        bashio::log.debug "${response}"
        bashio::log.error "Something went wrong contacting the API"
        return 1
    fi

    status=${response##*$'\n'}
    response=${response%$status}

    bashio::log.debug "API Status: ${status}"
    bashio::log.debug "API Response: ${response}"

    if [[ "${status}" -eq 401 ]]; then
        bashio::log.error "Unable to authenticate with the API, permission denied"
        return 1
    fi

    echo "${response}"
    return 0
}

# ------------------------------------------------------------------------------
# Update the Home Assistant sensor.
#
# Arguments
#  $1 The template value for the sensor
#  $2 The value to use for the sensor
#  $3 The name of the sensor
# ------------------------------------------------------------------------------
function update-sensor {
    local data
    local sensor_template=${1}
    local sensor_value=${2}
    local sensor_name=${3}
    bashio::log.info "Updating sensor $sensor_name with value $sensor_value"
    data=$(echo "$sensor_template" | jq --arg val "$sensor_value" '.state = $val')
    if ! response=$(ha-post-sensor "$data" "$sensor_name"); then
        bashio::log.error "Unable to update sensor $sensor_name in Home Assistant"
    fi
}