#!/usr/bin/with-contenv bashio

# Guards against corrupt readings from the Hypon API.
#
# The API intermittently returns garbage for the first readings after sunrise.
# Two shapes have been observed:
#
#  1. Absurd magnitudes. On 2026-08-30 `pvkwh` came back as 387929941747.78 and
#     then 96205065471.24 within 60 seconds, before settling to 3.3.
#  2. Values that start too high and decay downwards over several refresh
#     cycles, e.g. 2026-08-31: 2.21, 2.38, 2.52, 2.7, 1.43, 1.07, 0.89, 0.73.
#
# Both are destructive because the daily energy sensors are `total_increasing`.
# Home Assistant treats every downward step as a counter reset and re-adds the
# new value in full, so one bad morning permanently inflates the long-term
# statistics `sum`. The 30 Aug event added 484,135,007,219 kWh to the solar
# production total and had to be undone with `recorder/adjust_sum_statistics`.

# Any numeric reading at or above this magnitude is corrupt, whatever the
# sensor. Real values here are watts, kWh, percent, kg and currency - none of
# them get within several orders of magnitude of this.
declare SENSOR_ABSURD_MAGNITUDE=1000000000

# Ceiling for a single day's energy total. The best day on this system so far is
# ~36 kWh; the cap is deliberately loose so it only ever catches corruption.
declare DAILY_TOTAL_MAX_KWH=200

# A daily counter may only fall when it genuinely rolls over. Treat a drop to at
# or below this as a real reset and anything else as API noise.
declare DAILY_TOTAL_RESET_CEILING=0.2

# Last value published per sensor, and the day it belongs to.
declare -A LAST_ACCEPTED_VALUE
declare -A LAST_ACCEPTED_DAY

# ------------------------------------------------------------------------------
# True when the argument is a number we can reason about arithmetically.
# Non-numeric values are legitimate for the status/model/warning sensors, so
# callers decide whether to pass them through or reject them.
#
# Arguments
#  $1 The value to test
# ------------------------------------------------------------------------------
function is-numeric {
    [[ "${1}" =~ ^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$ ]]
}

# ------------------------------------------------------------------------------
# Float comparisons. Values are passed to awk via -v so a hostile payload cannot
# escape into the awk program.
# ------------------------------------------------------------------------------
function num-lt {
    awk -v a="${1}" -v b="${2}" 'BEGIN { exit !(a < b) }'
}

function num-gt {
    awk -v a="${1}" -v b="${2}" 'BEGIN { exit !(a > b) }'
}

# ------------------------------------------------------------------------------
# Update a daily total_increasing energy sensor, dropping corrupt readings.
#
# A rejected reading is simply not published, so the sensor holds its last good
# value until the API returns something sane. For a total_increasing counter
# that is the correct failure mode: holding the running maximum is exactly what
# Home Assistant expects, and the day's final total is unaffected.
#
# Arguments
#  $1 The template value for the sensor
#  $2 The value to use for the sensor
#  $3 The name of the sensor
# ------------------------------------------------------------------------------
function update-daily-total-sensor {
    local sensor_template=${1}
    local sensor_value=${2}
    local sensor_name=${3}
    local today
    local last_value

    if ! is-numeric "$sensor_value"; then
        bashio::log.warning "Rejecting non-numeric value '$sensor_value' for $sensor_name"
        return 0
    fi

    if num-lt "$sensor_value" 0 || num-gt "$sensor_value" "$DAILY_TOTAL_MAX_KWH"; then
        bashio::log.error "Rejecting implausible value $sensor_value for $sensor_name (expected 0-${DAILY_TOTAL_MAX_KWH} kWh)"
        return 0
    fi

    # Forget yesterday's reading so the midnight rollover to 0 is accepted.
    today=$(date +%Y-%m-%d)
    if [ "${LAST_ACCEPTED_DAY[$sensor_name]:-}" != "$today" ]; then
        unset "LAST_ACCEPTED_VALUE[$sensor_name]"
        LAST_ACCEPTED_DAY[$sensor_name]=$today
    fi

    # A mid-day drop to a non-zero value is the decay glitch, not a reset.
    last_value=${LAST_ACCEPTED_VALUE[$sensor_name]:-}
    if [ -n "$last_value" ] \
        && num-lt "$sensor_value" "$last_value" \
        && num-gt "$sensor_value" "$DAILY_TOTAL_RESET_CEILING"; then
        bashio::log.warning "Holding $sensor_name at $last_value, API returned lower value $sensor_value mid-day"
        return 0
    fi

    LAST_ACCEPTED_VALUE[$sensor_name]=$sensor_value
    update-sensor "$sensor_template" "$sensor_value" "$sensor_name"
}
