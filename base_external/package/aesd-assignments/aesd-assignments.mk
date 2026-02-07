##############################################################
#
# AESD-ASSIGNMENTS
#
##############################################################

# Pseudocode Block 3: define where Buildroot fetches assignment sources.
# - Pin to a specific commit for reproducible builds.
# - Use the SSH URL required by assignment infrastructure.
AESD_ASSIGNMENTS_VERSION = a0d65a85f81160f77f237803ce27e9c82f0d7d89
AESD_ASSIGNMENTS_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-jsnapoli1.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

# Pseudocode Block 4: cross-compile target binaries from finder-app.
# - Reuse TARGET_CONFIGURE_OPTS so CC/CFLAGS point at Buildroot toolchain.
define AESD_ASSIGNMENTS_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all
endef

# Pseudocode Block 5: stage runtime assets into rootfs.
# - Place configuration in /etc/finder-app/conf.
# - Install command-line tools in /usr/bin so they're accessible through PATH.
# - Install our updated finder-test.sh wrapper to /usr/bin.
define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/etc/finder-app/conf
	$(INSTALL) -m 0644 $(@D)/conf/* $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -d $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 0755 $(@D)/finder-app/writer $(TARGET_DIR)/usr/bin/writer
	$(INSTALL) -m 0755 $(@D)/finder-app/finder.sh $(TARGET_DIR)/usr/bin/finder.sh
	$(INSTALL) -m 0755 $(@D)/finder-app/tester.sh $(TARGET_DIR)/usr/bin/tester.sh
	$(INSTALL) -m 0755 $(BR2_EXTERNAL_project_base_PATH)/package/aesd-assignments/finder-test.sh $(TARGET_DIR)/usr/bin/finder-test.sh
endef

$(eval $(generic-package))
