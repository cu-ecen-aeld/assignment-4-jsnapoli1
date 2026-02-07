#!/bin/bash
# Compatibility wrapper for environments expecting save_config.sh naming.
set -e
cd "$(dirname "$0")"
./save-config.sh
