# ZeroByte

ZeroByte Core is an aggressive, low-level systems architecture delivered as a Magisk module. It is designed to bypass the Android Framework (Java layer) overhead, transforming any supported Android device (tested on AOSP/GSI environments) into a highly optimized, headless Linux node. It creates the perfect foundation for running isolated Debian chroot environments with maximum hardware resource allocation.

## ⚙️ Features

### 1. Bimodal State Execution (Coma & Resurrection)
ZeroByte introduces two custom kernel-level execution states that can be toggled via the ADB shell, avoiding the infinite bootloops caused by standard framework destruction.
* **`zb-sleep` (Coma Protocol):** Kills the `SystemServer` and `Zygote` via `stop`, aggressively freezing the Android UI.
* **`zb-wake` (Resurrection Protocol):** Re-initializes the Android Framework and restores display hardware parameters without requiring a system reboot.

### 2. Darkroom LCD Protocol
Standard `stop` commands leave LCD panels in a frozen, backlit state (Hardware Bleed). ZeroByte directly manipulates the kernel's backlight drivers (`/sys/class/backlight/*/brightness`), forcing a physical `0` state to the pixels instantly.

### 3. Aggressive Memory Optimization
Upon entering Coma Mode, ZeroByte manipulates the Linux kernel's memory management to heavily favor native Linux/Debian tasks over sleeping Android services:
* Forces maximum ZRAM utilization (`vm.swappiness=100`).
* Accelerates VFS cache dropping (`vm.vfs_cache_pressure=200`).
* Executes a hard cache drop (`echo 3 > /proc/sys/vm/drop_caches`) to clear VRAM and Slab overhead, dropping active RAM usage to bare-metal limits (~800 MiB on standard 64-bit kernels).

### 4. Bulletproof Headless ADB
Pre-boot initialization scripts ensure that the device remains accessible even when the UI is dead.
* Forces ADB over TCP (Port 5555).
* Neutralizes RSA key authentication (`ro.adb.secure=0`).
* Employs an immortal watchdog loop to restart `adbd` if it crashes during framework suspension.

## 🛠️ Installation

1. Package the repository into a `.zip` file.
2. Flash via Magisk Manager or `adb shell "su -c 'magisk --install-module /path/to/ZeroByte-Core.zip'"`.
3. Reboot the device.

## 🚀 Usage

By default, the `service.sh` script waits for network initialization (`wlan0` IP allocation) and automatically puts the device into Coma Mode on boot.

To manage states remotely via ADB:

```bash
# Put the device to sleep (Kill UI, drop caches, kill LCD)
adb shell zb-sleep

# Wake the device (Restore backlight, restart Android Framework)
adb shell zb-wake
