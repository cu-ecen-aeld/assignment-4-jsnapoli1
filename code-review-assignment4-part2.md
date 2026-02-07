# Code Review: Assignment 4 Part 2

This review documents each pseudocode block added to the implementation and explains architectural intent, tradeoffs, and non-obvious syntax choices.

---

## Block 1 — External Config exposure

```make
# Pseudocode Block 1: expose external packages to Buildroot menu system.
# - Source each package Config.in under base_external/package.
# - Keep this file minimal so new package directories can be added predictably.
source "$BR2_EXTERNAL_project_base_PATH/package/aesd-assignments/Config.in"
```

**Rationale**
- Buildroot external trees require a top-level `Config.in` to expose package toggles in `menuconfig`; without this, `BR2_PACKAGE_AESD_ASSIGNMENTS` is undiscoverable.
- `$BR2_EXTERNAL_project_base_PATH` is the canonical variable generated from `external.desc` name (`project_base`). This keeps paths relocatable.

---

## Block 2 — External makefile discovery

```make
# Pseudocode Block 2: collect package makefiles from this external tree.
# - Let Buildroot discover package .mk files automatically.
# - Keep wildcard scope under package/*/*.mk to match Buildroot conventions.
include $(sort $(wildcard $(BR2_EXTERNAL_project_base_PATH)/package/*/*.mk))
```

**Rationale**
- Standard Buildroot pattern: wildcard all package mk files and include them in deterministic sorted order.
- `$(sort ...)` avoids accidental nondeterminism across filesystems.

---

## Block 3 — Source fetch configuration

```make
# Pseudocode Block 3: define where Buildroot fetches assignment sources.
# - Pin to a specific commit for reproducible builds.
# - Use the SSH URL required by assignment infrastructure.
AESD_ASSIGNMENTS_VERSION = a0d65a85f81160f77f237803ce27e9c82f0d7d89
AESD_ASSIGNMENTS_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-jsnapoli1.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES
```

**Rationale**
- Pinning a commit hash is an industry best practice for reproducible CI.
- SSH URL is explicitly required by assignment infrastructure and avoids HTTPS auth ambiguity in environments with SSH keys.
- Submodule support is enabled defensively in case the assignment repository adds nested dependencies.

---

## Block 4 — Cross-compile logic

```make
# Pseudocode Block 4: cross-compile target binaries from finder-app.
# - Reuse TARGET_CONFIGURE_OPTS so CC/CFLAGS point at Buildroot toolchain.
define AESD_ASSIGNMENTS_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all
endef
```

**Rationale**
- `$(TARGET_CONFIGURE_OPTS)` injects cross-compiler triplet and sysroot information; this avoids host-compiler contamination.
- Keeping build execution scoped to `finder-app` matches the known project layout and avoids unnecessary top-level make targets.

---

## Block 5 — Rootfs install contract

```make
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
```

**Rationale**
- `/usr/bin` was chosen over `/bin` to match assignment requirements and ensure PATH execution without absolute paths.
- Explicit installs are preferred over wildcard script copies: this avoids accidentally shipping non-runtime files.
- Mode flags:
  - `0644` for config files (read-only by default).
  - `0755` for executable scripts/binaries.

---

## Block 6 — Finder test portability

```sh
# Pseudocode Block 6: make this test script path-independent.
# - Assume required executables are on PATH.
# - Assume configuration lives at /etc/finder-app/conf.
# - Save finder command output in /tmp/assignment4-result.txt for grading.
```

**Rationale**
- `set -eu` hardens script behavior by failing on undefined variables and first error.
- `command -v` checks are POSIX-compliant and provide immediate diagnostics for missing runtime dependencies.
- `tee` simultaneously emits to console and required output artifact file.
- Running `writer` and `tester.sh` in the flow verifies that cross-compiled executable + shell scripts are both functional in target runtime.

---

## Block 7 — Build-time cache/download policy

```sh
# Pseudocode Block 7: centralize build settings used on every build invocation.
# - Keep downloads in ${HOME}/.dl for faster rebuilds across repos.
# - Reference BR2_CCACHE_DIR with a HOME-relative path to satisfy assignment constraints.
# - Preserve existing external tree wiring.
```

**Rationale**
- Using `${HOME}` avoids machine-specific absolute paths and aligns with assignment constraints.
- Exporting cache vars in `build.sh` ensures consistent behavior regardless of caller script.
- Existing external wiring (`BR2_EXTERNAL=../base_external`) is preserved to avoid regressions.

---

## Block 8 — Distclean utility

```sh
# Pseudocode Block 8: provide a one-command clean state reset.
# - Execute Buildroot distclean from the buildroot directory.
```

**Rationale**
- `make -C buildroot distclean` is the canonical method to return Buildroot to a pristine state.
- Dedicated wrapper script simplifies repeatability in CI and in the orchestration script.

---

## Block 9 — SSH image configuration workflow

```sh
# Pseudocode Block 9: configure SSH-capable image through menuconfig and build.
# - Open menuconfig so developer can confirm/update options.
# - Require dropbear, root password, compiler cache, and download dir settings.
# - Save defconfig and trigger build with the standard build script.
```

**Rationale**
- Requirement explicitly called for `make menuconfig`; this script enforces that workflow.
- Post-menuconfig `grep` assertions fail fast if the expected options were not set. This avoids silent misconfiguration.
- Root password `root` requirement is validated exactly through `BR2_TARGET_GENERIC_ROOT_PASSWD="root"`.

---

## Block 10 — End-to-end orchestration

```sh
# Pseudocode Block 10: orchestrate an end-to-end clean/build/boot workflow.
# - Distclean to validate reproducibility.
# - Run SSH configuration + build twice (as requested).
# - Launch QEMU without extra workflow steps.
```

**Rationale**
- Encapsulates assignment-required sequence into one command path.
- Running build script twice checks idempotency and catches stateful config issues.
- Final `runqemu.sh` handoff keeps existing emulator settings centralized in one place.

---

## Architecture Notes
- **Separation of concerns**:
  - Buildroot package logic lives in `base_external/package/aesd-assignments`.
  - Host orchestration scripts live at repo root.
  - Documentation artifacts (`plan-*`, `code-review-*`) are isolated from runtime code.
- **Reproducibility strategy**:
  - Pinned git commit for package source.
  - Explicit config validation gates in SSH configure script.
  - Distclean-first flow in `boot-test-cycle.sh`.
- **Operational ergonomics**:
  - Compatibility wrapper `save_config.sh` added due to assignment naming mismatch with existing `save-config.sh`.

## References
- Buildroot manual: external trees and generic-package usage.
- POSIX shell practices (`set -eu`, `command -v`) for portable scripting.
