# Pseudocode Block 2: collect package makefiles from this external tree.
# - Let Buildroot discover package .mk files automatically.
# - Keep wildcard scope under package/*/*.mk to match Buildroot conventions.
include $(sort $(wildcard $(BR2_EXTERNAL_project_base_PATH)/package/*/*.mk))
