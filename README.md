# Beginner Developer Tutorial

Step-by-step guides for development setup on Ubuntu, embedded targets, and common tooling. Below is a short summary of each instruction file in this repository.

## Instruction files (summary)

| File | What it covers |
|------|----------------|
| [`ubuntu_setup.md`](ubuntu_setup.md) | **Ubuntu 24.04 onboarding:** install and first steps, basic shell commands, Git/GitHub basics, Xiao RP2350 and **Zephyr** (SDK layout, build, UF2 flash), **STM32** toolchain and CubeIDE, **Anaconda**, **PyTorch** (CUDA vs CPU), **YOLO**, browsers and VPN pointers, and editors (**VS Code**, **Octave**).References [`setup-dev-env.sh`](setup_dev_env.sh) for automated setup. |
| [`ubuntu_program_tools.md`](ubuntu_program_tools.md) | Links for **Remmina** / remote desktop; **Byobu**; **SerialPortAssistant** and serial permissions; a Linux proxy-bypass wiki link; checking **CPU temperature** from sysfs. |
| [`git.md`](git.md) | Install **git**, global user/email, **GitHub SSH** (ed25519), **conventional-style commit prefixes** (`feat:`, `fix:`, etc.), branch/PR workflow (clone via SSH, feature branch, push, merge request), and everyday **git** commands. |
| [`vscode.md`](vscode.md) | Install VS Code from App Center. **VS Code** plugins: **LaTeX Workshop**, **Markdown All in One** (TOC commands), **Draw.io Integration** and **Markdown Table Prettifier**. |
| [`clang_format_usage.md`](clang_format_usage.md) | Install **clang-format**, in-place formatting, built-in styles (LLVM, Google, …), generating **`.clang-format`**, and formatting many files with **find** + **xargs**. |
| [`remote_desktop.md`](remote_desktop.md) | **xrdp** on Ubuntu (install, service, **ufw** port 3389) and connecting from Windows/macOS/Linux RDP clients; session type **Xorg**. |
| [`windows_program_tools.md`](windows_program_tools.md) | **PuTTY:** clearing saved sessions with `putty.exe -cleanup`. |
| [`website_development.md`](website_development.md) | **Node.js/npm** on Ubuntu, a **React landing page** template link, **`npm install`**, **`npm run build`**, serving with **`serve`**, and **`npm start`**. |
| [`ros2.md`](ros2.md) | **ROS 2 Jazzy** on Ubuntu: **`ros2 run demo_nodes_cpp talker`**, **`colcon build`** (workspace, symlink install, package select), and basic verification. |
| [`realsense.md`](realsense.md) | Build **Intel RealSense librealsense** from source (deps, clone, **udev** rules, cmake install, optional kernel patch script), **`lsusb`** check, and **`realsense-viewer`**. |
| [`pinocchio.md`](pinocchio.md) | **Pinocchio** robotics library: **Pixi**, **eigenpy** and **example-robot-data** from source, then build Pinocchio from upstream with links. |
| [`nuttx.md`](nuttx.md) | Short **NuttX** note: replacing or relocating **`apps/`** via **`CONFIG_APPS_DIR`** (out-of-tree apps, per Apache NuttX docs). |
| [`nuttx_driver_porting_guide.md`](nuttx_driver_porting_guide.md) | Long **NuttX driver porting** guide using **ICM42688** on **Raspberry Pi Pico W**: RTOS vs Linux, Kconfig/Make flow, **I2C** driver skeleton, board bringup, **defconfig**, test app, flash/serial test, troubleshooting, and links to reference material (includes Baidu disk link for example project). |
| [`nvidia_jetson.md`](nvidia_jetson.md) | **Jetson Orin NX** hardware links, **JetPack** via SDK Manager reference, and disabling deep sleep by setting **`SuspendMode=freeze`** in **`/etc/systemd/sleep.conf`**. |
| [`radxa.md`](radxa.md) | **Radxa** boards: **`u-boot-install`** and **`ubuntu-rockchip-install`** to eMMC/SD, **Ubuntu 24.04** on Zero **3W/3E**, **ROS2** Rolling/Jazzy mention, and pointers to **netplan**, **ubuntu-rockchip** wiki, and Radxa device-tree docs. |

<!-- ## Scripts and extras (not Markdown)

- **[`install_ros2.sh`](install_ros2.sh)** — Automates ROS 2 installation (see [`ros2.md`](ros2.md)).
- **`new_ubuntu_enviroment_setup/`** — Contains [`new_ubuntu_enviroment_setup.sh`](new_ubuntu_enviroment_setup/new_ubuntu_enviroment_setup.sh), CUDA install helpers, and apt `source*.list` files for a fresh Ubuntu environment (see [`dummy_beginner.md`](dummy_beginner.md)).

For full commands and details, open the linked file; the table above is only an index. -->

<!-- | [`ubuntu_environment_setup.md`](ubuntu_environment_setup.md) | **GitHub** SSH keys and **submodules**; **OpenSSH** server and firewall; terminal colors in `~/.bashrc`; **Fcitx5** for Chinese/Japanese input; **TeXstudio** + **texlive-full** and dark-theme tips; **OpenGL/Mesa** dev packages; **eGPU** (Thunderbolt, NVIDIA/AMD, `boltctl`, troubleshooting). | -->
