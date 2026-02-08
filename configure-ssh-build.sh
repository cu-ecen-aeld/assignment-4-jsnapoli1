#!/bin/bash
# Pseudocode Block 9: configure SSH-capable image through menuconfig and build.
# - Open menuconfig so developer can confirm/update options.
# - Require dropbear, root password, compiler cache, and download dir settings.
# - Save defconfig and trigger build with the standard build script.
set -e
cd "$(dirname "$0")"
source shared.sh

EXTERNAL_REL_BUILDROOT=../base_external
export BR2_DL_DIR="${HOME}/.dl"
export BR2_CCACHE_DIR="${HOME}/.buildroot-ccache"

if [ ! -f buildroot/.config ]; then
    if [ -e "${AESD_MODIFIED_DEFCONFIG}" ]; then
        echo "USING ${AESD_MODIFIED_DEFCONFIG}"
        make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT}
    else
        echo "No modified defconfig found, using default ${AESD_DEFAULT_DEFCONFIG}"
        make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_DEFAULT_DEFCONFIG}
    fi
fi

make -C buildroot menuconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT}

# Clarifying note: these validations fail fast if the required menuconfig options were not applied.
grep -q '^BR2_PACKAGE_DROPBEAR=y' buildroot/.config || { echo 'Enable Target packages -> Networking applications -> dropbear'; exit 1; }
grep -q '^BR2_TARGET_GENERIC_ROOT_PASSWD="root"' buildroot/.config || { echo 'Set System configuration -> Root password to "root"'; exit 1; }
grep -q '^BR2_CCACHE=y' buildroot/.config || { echo 'Enable Build options -> Enable compiler cache'; exit 1; }
grep -q '^BR2_DL_DIR="\${HOME}/.dl"' buildroot/.config || { echo 'Set Build options -> Download dir to ${HOME}/.dl'; exit 1; }

./save-config.sh
./build.sh
