# Assignment 4 Part 2 Implementation Plan

## Scope
Integrate an external Buildroot package (`aesd-assignments`) that pulls assignment sources over SSH, installs runtime scripts/binaries into target rootfs, and adds repeatable automation scripts for clean/build/boot workflows.

## Work Plan
1. **Create external tree metadata**
   - Add `base_external/external.desc` with external name `project_base`.
   - Add `base_external/Config.in` and `base_external/external.mk` so Buildroot can discover package config and makefiles.
2. **Complete `aesd-assignments` package recipe**
   - Configure git site method using SSH URL `git@github.com:cu-ecen-aeld/assignments-3-and-later-jsnapoli1.git`.
   - Pin a commit hash for reproducibility.
   - Build `finder-app` using target cross toolchain options.
   - Install `writer`, `finder.sh`, `tester.sh`, and an updated `finder-test.sh` in `/usr/bin`.
   - Install configuration files under `/etc/finder-app/conf`.
3. **Implement portable `finder-test.sh` behavior**
   - Ensure script runs from any path using PATH-resolved tools.
   - Write finder output to `/tmp/assignment4-result.txt`.
   - Validate required executables and run writer/tester paths needed by assignment tests.
4. **Add automation scripts in repository root**
   - `clean.sh` to run `make distclean` from buildroot directory.
   - `configure-ssh-build.sh` to launch `make menuconfig`, verify required options (dropbear, root password=root, ccache, `${HOME}/.dl`), save config, and build.
   - `boot-test-cycle.sh` to run `clean.sh`, then the SSH build script twice, then boot QEMU.
   - Add `save_config.sh` compatibility wrapper for required naming.
5. **Build performance and cache configuration**
   - Update build workflow to export `BR2_DL_DIR=${HOME}/.dl`.
   - Use `BR2_CCACHE_DIR` in `${HOME}` and require `BR2_CCACHE=y` in config checks.
6. **Documentation and review artifacts**
   - Add this plan file.
   - Add `code-review-assignment4-part2.md` with pseudocode blocks and engineering rationale.
   - Update `README.md` with technical summary, commit hashes, and dates.
7. **Validation and delivery**
   - Run shell syntax checks against all modified scripts.
   - Review git diff for correctness.
   - Commit changes and open PR message via tool.
