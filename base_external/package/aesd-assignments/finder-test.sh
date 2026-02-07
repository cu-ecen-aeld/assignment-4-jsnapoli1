#!/bin/sh

# Pseudocode Block 6: make this test script path-independent.
# - Assume required executables are on PATH.
# - Assume configuration lives at /etc/finder-app/conf.
# - Save finder command output in /tmp/assignment4-result.txt for grading.
set -eu

OUTPUT_FILE="/tmp/assignment4-result.txt"
SEARCH_DIR="/etc/finder-app/conf"
SEARCH_STR="${1:-writer}"

# Clarifying note: command -v gives a portable executable presence check in POSIX shells.
for required_cmd in finder.sh writer tester.sh; do
    command -v "${required_cmd}" >/dev/null 2>&1 || {
        echo "ERROR: ${required_cmd} must be available in PATH" >&2
        exit 1
    }
done

# Run finder and mirror output both to terminal and to the required result file.
finder.sh "${SEARCH_DIR}" "${SEARCH_STR}" | tee "${OUTPUT_FILE}"

# Exercise writer to verify target-cross-compiled binary is functional.
writer /tmp/assignment4-writer-test.txt "writer executed from finder-test.sh"

# Run the existing tester script against config path for consistency.
tester.sh "${SEARCH_DIR}" "${SEARCH_STR}"
