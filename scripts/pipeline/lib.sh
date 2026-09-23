#!/usr/bin/env bash
# Sourced by every script under scripts/pipeline: logging, the log file, and
# the ok/changed/skipping/unreachable/fatal recap, in the spirit of Ansible.

set -euo pipefail

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    C_OK=$'\033[32m'; C_CHANGED=$'\033[33m'; C_SKIP=$'\033[36m'
    C_UNREACHABLE=$'\033[1;31m'; C_FATAL=$'\033[31m'; C_RESET=$'\033[0m'
else
    C_OK=""; C_CHANGED=""; C_SKIP=""; C_UNREACHABLE=""; C_FATAL=""; C_RESET=""
fi

LOG_FILE="${LOG_FILE:-.logs/pipeline.log}"

RECAP_OK=0
RECAP_CHANGED=0
RECAP_SKIPPED=0
RECAP_UNREACHABLE=0
RECAP_FAILED=0

# Appends one timestamped, ANSI-free line to LOG_FILE. Never call this with a
# value that might hold a secret.
_log_line() {
    local level="$1" msg="$2"
    mkdir -p "$(dirname "${LOG_FILE}")"
    [[ -f "${LOG_FILE}" ]] || : > "${LOG_FILE}"
    chmod 600 "${LOG_FILE}"
    printf '%s [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${level}" "${msg}" >> "${LOG_FILE}"
}

log_ok()          { printf '%sok%s          %s\n' "${C_OK}" "${C_RESET}" "$1"; _log_line ok "$1"; RECAP_OK=$((RECAP_OK+1)); }
log_changed()     { printf '%schanged%s     %s\n' "${C_CHANGED}" "${C_RESET}" "$1"; _log_line changed "$1"; RECAP_CHANGED=$((RECAP_CHANGED+1)); }
log_skip()        { printf '%sskipping%s    %s\n' "${C_SKIP}" "${C_RESET}" "$1" >&2; _log_line skipping "$1"; RECAP_SKIPPED=$((RECAP_SKIPPED+1)); }
log_unreachable() { printf '%sunreachable%s %s\n' "${C_UNREACHABLE}" "${C_RESET}" "$1" >&2; _log_line unreachable "$1"; RECAP_UNREACHABLE=$((RECAP_UNREACHABLE+1)); }
log_fatal()       { printf '%sfatal%s       %s\n' "${C_FATAL}" "${C_RESET}" "$1" >&2; _log_line fatal "$1"; RECAP_FAILED=$((RECAP_FAILED+1)); }

die() { log_fatal "$1"; exit 1; }

print_recap() {
    local label="$1"
    printf '\nPLAY RECAP %s\n' "$(printf '*%.0s' {1..40})"
    printf '%-20s: ok=%-4s changed=%-4s unreachable=%-4s failed=%-4s skipped=%-4s\n' \
        "${label}" "${RECAP_OK}" "${RECAP_CHANGED}" "${RECAP_UNREACHABLE}" "${RECAP_FAILED}" "${RECAP_SKIPPED}"
}

# Non-zero exit whenever something failed or could not be reached.
# skipped never fails the run: not applicable is not false.
recap_exit_code() {
    [[ "${RECAP_FAILED}" -eq 0 && "${RECAP_UNREACHABLE}" -eq 0 ]]
}
