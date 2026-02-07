#!/bin/bash
# Pseudocode Block 8: provide a one-command clean state reset.
# - Execute Buildroot distclean from the buildroot directory.
set -e
cd "$(dirname "$0")"
make -C buildroot distclean
