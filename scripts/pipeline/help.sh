#!/usr/bin/env bash
# Prints the help: collects every target and section from the Makefile and
# its includes, then groups by section, so a section declared in more than
# one file (##@ Deploy shows up in every component fragment) prints once.

set -euo pipefail

files=(Makefile makefiles/*.mk)

bold="" cyan="" reset=""
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    bold=$'\033[1m'; cyan=$'\033[36m'; reset=$'\033[0m'
fi

echo "Usage: make <target>"

awk -v bold="${bold}" -v cyan="${cyan}" -v reset="${reset}" '
/^##@/ {
    section = substr($0, 5)
    if (!(section in seen)) { order[++n] = section; seen[section] = 1 }
    next
}
/^[a-zA-Z0-9_-]+:.*## / {
    colon = index($0, ":")
    target = substr($0, 1, colon - 1)
    rest = substr($0, colon + 1)
    marker = index(rest, "## ")
    desc = substr(rest, marker + 3)
    body[section] = body[section] sprintf("  %s%-20s%s %s\n", cyan, target, reset, desc)
}
END {
    for (i = 1; i <= n; i++) {
        s = order[i]
        if (!(s in body)) { continue }
        printf "\n%s%s%s\n", bold, s, reset
        printf "%s", body[s]
    }
}
' "${files[@]}"
echo
