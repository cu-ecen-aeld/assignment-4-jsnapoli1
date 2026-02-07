#!/bin/bash
# Script to build buildroot configuration

# Pseudocode Block 7: centralize build settings used on every build invocation.
# - Keep downloads in ${HOME}/.dl for faster rebuilds across repos.
# - Reference BR2_CCACHE_DIR with a HOME-relative path to satisfy assignment constraints.
# - Preserve existing external tree wiring.
source shared.sh

EXTERNAL_REL_BUILDROOT=../base_external
BR2_DL_DIR="${HOME}/.dl"
BR2_CCACHE_DIR="${HOME}/.buildroot-ccache"
export BR2_DL_DIR BR2_CCACHE_DIR

git submodule init
git submodule sync
git submodule update

set -e
cd "$(dirname "$0")"

if [ ! -e buildroot/.config ]
then
	echo "MISSING BUILDROOT CONFIGURATION FILE"

	if [ -e "${AESD_MODIFIED_DEFCONFIG}" ]
	then
		echo "USING ${AESD_MODIFIED_DEFCONFIG}"
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT}
	else
		echo "Run ./save_config.sh to save this as the default configuration in ${AESD_MODIFIED_DEFCONFIG}"
		echo "Then add packages as needed to complete the installation, re-running ./save_config.sh as needed"
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_DEFAULT_DEFCONFIG}
	fi
else
	echo "USING EXISTING BUILDROOT CONFIG"
	echo "To force update, delete .config or make changes using make menuconfig and build again."
	make -C buildroot BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT}
fi
