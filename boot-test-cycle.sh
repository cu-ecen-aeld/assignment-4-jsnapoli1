#!/bin/bash
# Pseudocode Block 10: orchestrate an end-to-end clean/build/boot workflow.
# - Distclean to validate reproducibility.
# - Run SSH configuration + build twice (as requested).
# - Launch QEMU without extra workflow steps.
set -e
cd "$(dirname "$0")"

./clean.sh
./configure-ssh-build.sh
./configure-ssh-build.sh
./runqemu.sh
