# Task description
Add a Linux-only `--overlay` option to `latest_python3.py` so `install` mode prepares overlay directory layout and performs `make install` inside a `chroot` to an overlayfs merged root, with overlay storage defaulting under `~/.local`.

# Current state analysis
- `latest_python3.py` has no `--overlay` option yet
- Build/install flow currently calls `make install` directly in extracted source directory
- User asked to avoid Windows-style paths and use workspace-relative/POSIX-safe paths
- A separate script handles mounting, so this task should only prepare directories and consume an already-mounted merged root

# Step-by-step plan
1. Add CLI options and Linux/install validation for overlay mode
2. Add helpers to prepare overlay directory structure and validate merged mountpoint
3. Route install path to chrooted `make install` when overlay is enabled
4. Run static error checks and adjust as needed

# Progress log
- started: gathered repo instructions and current file state
