#!/bin/bash
# Replays the real 30/31 Aug 2026 Hypon API sequences through the new guards.
set -u
cd "$(dirname "$0")/../hypon-cloud" || exit 1

FAILURES=0

source scripts/sanity.sh
source scripts/home-assistant.sh

# Stubs are defined after sourcing so they win over the real implementations.
function bashio::log.info    { :; }
function bashio::log.debug   { :; }
function bashio::log.warning { :; }
function bashio::log.error   { :; }

# Minimal stand-in for the one jq invocation inside update-sensor.
function jq {
  local val=""
  while [ $# -gt 0 ]; do
    case "$1" in --arg) val="$3"; shift 3 ;; *) shift ;; esac
  done
  cat >/dev/null
  printf '{"state": "%s"}' "$val"
}

# Capture the POST instead of calling the HA REST API. update-sensor invokes
# this inside a command substitution, i.e. a subshell, so the captured values
# have to go to a file rather than a shell array.
CAPTURE=$(mktemp)
function ha-post-sensor {
  [[ "$1" =~ \"state\":\ \"([^\"]*)\" ]] && printf '%s\n' "${BASH_REMATCH[1]}" >>"$CAPTURE"
  echo "{}"
}
function captured { tr '\n' ' ' <"$CAPTURE" | sed 's/ $//'; }
function reset-capture { : >"$CAPTURE"; }
trap 'rm -f "$CAPTURE"' EXIT

SENSOR=sensor.hypon_total_pv_generated_today
TPL='{"state": "unknown"}'

check() {
  local label=$1 expected=$2 actual=$3
  if [ "$expected" = "$actual" ]; then
    echo "PASS  $label"
  else
    echo "FAIL  $label"
    echo "        expected: $expected"
    echo "        actual:   $actual"
    FAILURES=$((FAILURES + 1))
  fi
}

replay() {
  local label=$1 expected=$2; shift 2
  reset-capture
  unset LAST_ACCEPTED_VALUE LAST_ACCEPTED_DAY
  declare -gA LAST_ACCEPTED_VALUE LAST_ACCEPTED_DAY
  for v in "$@"; do update-daily-total-sensor "$TPL" "$v" "$SENSOR"; done
  check "$label" "$expected" "$(captured)"
}

# 30 Aug: two absurd magnitudes, then a decaying tail. The garbage must never
# reach HA, and the counter must hold its running maximum through the decay.
# The early 0.01 -> 0 step is a genuine drop to zero and is passed through.
replay "30 Aug 2026 (as it actually arrived)" \
  "0 0.01 0 3.3 4.5 9.8 18.24" \
  0 0.01 0 387929941747.78 96205065471.24 3.3 1.92 2 1.53 1.19 1.23 1.15 1.19 1.26 1.17 1.06 1.27 4.5 9.8 18.24

# 31 Aug: first reading of the day too high, then decays.
replay "31 Aug 2026 (as it actually arrived)" \
  "0 2.21 2.38 2.52 2.7 3.01 7.11 26.22" \
  0 2.21 2.38 2.52 2.7 1.43 1.52 1.07 0.89 0.79 0.73 3.01 7.11 26.22

# A clean day must pass through completely untouched.
replay "01 Sep 2026 (clean day, unaltered)" \
  "0 0.01 0.02 0.03 0.05 0.1 0.25 0.36 5.2 11.86" \
  0 0.01 0.02 0.03 0.05 0.1 0.25 0.36 5.2 11.86

# The rollover to zero is a real reset and must be published.
replay "Midnight rollover accepted" \
  "11.86 0 0.01" \
  11.86 0 0.01

# The 200 kWh cap must not clip a genuinely huge summer day.
replay "45 kWh summer day not clipped" \
  "0 12.5 45.9" \
  0 12.5 45.9

# 14 Aug: a genuine mid-day counter restart. The counter reached 9.99 kWh by
# 13:00, restarted, then climbed to 8.75 kWh by midnight; 18.74 kWh really was
# generated. The restart must be let through in full. A fixed kWh floor pinned
# the sensor at 9.99 here and lost the whole afternoon.
replay "14 Aug 2026 mid-day counter restart passes through" \
  "0 0.06 0.37 1.27 2.93 6.45 9.99 1.5 2.57 3.98 5.12 6.09 6.86 7.65 8.49 8.69 8.73 8.75" \
  0 0.06 0.37 1.27 2.93 6.45 9.99 1.5 2.57 3.98 5.12 6.09 6.86 7.65 8.49 8.69 8.73 8.75

# Either side of the 20% reset fraction, against a held value of 10.
replay "drop to 1.9 kWh from 10 reads as a restart" \
  "10 1.9 3.4" \
  10 1.9 3.4
replay "drop to 2.5 kWh from 10 reads as decay and is held" \
  "10 11.2" \
  10 2.5 2.6 2.4 11.2

# Backstop on sensors that do not go through the daily guard.
reset-capture
update-sensor "$TPL" "387929941747.78" sensor.hypon_pv_generation_total
update-sensor "$TPL" "2967.84"         sensor.hypon_pv_generation_total
update-sensor "$TPL" "Normal"          sensor.hypon_inverter_status
update-sensor "$TPL" "-2500"           sensor.hypon_battery_power_now
check "absurd-magnitude backstop (strings and negatives pass)" \
  "2967.84 Normal -2500" "$(captured)"

echo
if [ "$FAILURES" -eq 0 ]; then echo "All checks passed."; else echo "$FAILURES check(s) failed."; exit 1; fi
