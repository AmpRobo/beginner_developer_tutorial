# Ubuntu 24.04 Development Environment Setup
## Contents
1. [Ubuntu 24.04 Installation](#ubuntu-2404-installation)
2. [Basic Ubuntu 24.04 setup](#basic-ubuntu-2404-setup)
3. [GitHub usage](#github-usage)
4. [Pico development environment](#pico-development-environment)
5. [STM32 development environment](#stm32-development-environment)
6. [Anaconda environment](#anaconda-environment)
7. [PyTorch environment](#pytorch-environment)
8. [Darknet environment](#darknet-environment)
9. [Web browser and VPN](#web-browser-and-vpn)
10. [Common development software](#common-development-software)

---

## Ubuntu 24.04 Installation
### Purpose  
Install the latest Ubuntu as the base system for your development environment.

### Preparation
1. Download the Ubuntu 24.04 LTS ISO from the [Ubuntu website](https://ubuntu.com/download/desktop).
2. Create a bootable USB drive (recommended: [Balena Etcher](https://www.balena.io/etcher/)).

### Installation steps
1. Insert the USB drive (>=16GB), reboot, and set the USB as the first boot device in BIOS/UEFI.
2. Choose **Install Ubuntu**.
3. Partitioning: at least 500 GB recommended.
4. Set username, password, and computer name.
5. Reboot after installation completes.

### First-boot checks
```bash
# Check system information
lsb_release -a
# Check disk space
df -h
```

### Basic terminal commands
```bash
# Show current directory
pwd
# List directory contents
ls
ls -l         # Detailed listing
ls -a         # Include hidden files

# Change directory
cd /path/to/directory
cd ..         # Parent directory
cd ~          # Home directory

# Create directories and files
mkdir new_folder
touch file.txt
# Copy, move, delete
cp source.txt dest.txt     # Copy file
mv old.txt new.txt         # Move or rename
rm file.txt                # Delete file
rm -r folder_name          # Delete directory and contents

# View and edit files
cat file.txt
less file.txt
head file.txt     # First 10 lines
tail file.txt     # Last 10 lines
nano file.txt     # Simple terminal editor
vim file.txt      # Advanced editor

# System information and management
whoami                    # Current user
uname -a                  # System information
lsb_release -a
df -h                     # Disk space
free -h                   # Memory usage
sudo apt update           # Refresh package lists
sudo apt upgrade -y       # Upgrade installed packages
sudo apt install package  # Install package
sudo apt remove package   # Remove package

# Permissions
ls -l                               # File permissions
chmod 755 file.txt                  # Change permissions
sudo chown user:group file.txt      # Change owner
```

## Basic Ubuntu 24.04 Update
### Common steps
```bash
# Update the system
sudo apt update && sudo apt upgrade -y
```

### Ubuntu Environment Setup
For basic configuration and software installation you can run the script: 
[`setup-dev-env.sh`](setup_dev_env.sh).

---

## GitHub usage
### Notes  
Git is the most common version control system for managing code and collaborating. Register a GitHub account before you start.

### Installation
1. Install Git:
```sh
sudo apt update
sudo apt install git -y
git --version
```

2. Initial configuration  
The first time you use Git, set your name and email so commits are attributed correctly:
```sh
# Global user name
git config --global user.name "Your username"
# Global email
git config --global user.email "your.email@example.com"
# View configuration
git config --list
```

3. Common commands
```sh
# Clone a repository
git clone https://github.com/username/repo.git
# Stage changes
git add filename       # Single file
git add .              # All changes in current directory
# Commit
git commit -m "Commit message"
# Push to GitHub
git push origin branch-name
# Pull updates
git pull origin branch-name
# Branches
git branch             # List local branches
git branch new-branch  # Create branch
git checkout branch-name  # Switch branch
git merge branch-name  # Merge branch
git branch -d branch-name  # Delete local branch
git push origin --delete branch-name  # Delete remote branch
```

---

## Pico development environment
### Notes  
You can develop using the official Raspberry Pi Pico SDK.

### Installation
1. Install build tools:
```sh
sudo apt-get install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential
sudo apt-get install pkg-config libusb-1.0-0-dev
```

2. Lay out the source tree like this:
```sh
screw_drive_unit_pico/
  |->pico-sdk/
  |->pico-examples/
  |->screw_drive_unit_pico/
```

3. Initialize submodules:
```sh
git submodule update --init
cd pico-sdk
git submodule update --init
```

4. Set `PICO_SDK_PATH` in your shell (replace the path with your actual repo location):
```sh
cd ~
echo "export PICO_SDK_PATH=$HOME/(to your directory path)/screw_drive_unit_pico/pico-sdk" >> ~/.bashrc
. ~/.bashrc
```

### Usage
1. Build:
```sh
cd ~/screw_drive_unit_pico/screw_drive_unit_pico
mkdir build
cd build
cmake .. -DPICO_BOARD=pico_w -DCMAKE_BUILD_TYPE=Release
make
```

2. Flashing firmware  
Hold the **BOOTSEL** button on the Pico while connecting it with a Micro USB cable so it appears as a USB mass storage device. Copy `main.uf2` from the `build` folder onto that drive.

---

## STM32 development environment
### Notes  
Install the toolchain and IDE needed for STM32 microcontroller development.

### Installation
```bash
# ARM toolchain
sudo apt install gcc-arm-none-eabi gdb-multiarch -y

# Download STM32CubeIDE from ST’s site
wget https://www.st.com/en/development-tools/stm32cubeide.html
# Follow ST’s installation instructions
```

### Useful tools
- `st-flash` (programming)
```bash
sudo apt install stlink-tools -y
```

---

## Anaconda environment
### Notes  
Anaconda provides Python for scientific computing and machine learning. You can create a separate environment per project.

### Installation
1. On the Anaconda website, choose **Linux** → **64-bit (x86_64)** and copy the installer URL.
2. In a terminal:
```bash
wget https://repo.anaconda.com/archive/Anaconda3-2024.02-Linux-x86_64.sh
bash Anaconda3-2024.02-Linux-x86_64.sh
```

### Initialization
```bash
source ~/.bashrc
conda create -n dev python=3.10 -y
conda activate dev
```

---

## PyTorch environment
### Notes  
Install PyTorch for deep learning.

### Installation
1. Activate your Conda environment.
2. For the GPU build, install NVIDIA drivers and CUDA first.
3. On the [PyTorch website](https://pytorch.org), pick something like:  
   **PyTorch Build:** Stable (e.g. 2.3.1)  
   **Your OS:** Linux  
   **Package:** Conda  
   **Language:** Python  
   **Compute Platform:** CUDA x.x (requires NVIDIA driver and CUDA toolkit)

```bash
# GPU (CUDA) or CPU-only examples
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
conda install pytorch torchvision torchaudio cpuonly -c pytorch
```

**Verify:**
```bash
python -c "import torch; print(torch.cuda.is_available())"
```

---

## Darknet environment
### Purpose  
Darknet is a C/C++ framework for CNNs; you can run YOLO models for object detection.

### Installation
1. Clone and build:
```bash
git clone https://github.com/pjreddie/darknet.git
cd darknet
make
```

2. Follow the official setup: https://pjreddie.com/darknet/

3. Test Darknet:
```bash
# Download YOLOv3 weights
wget https://pjreddie.com/media/files/yolov3.weights
# Run detection on a sample image
./darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
```

---

## Web browser and VPN
### Purpose  
Install a web browser and tools for unrestricted network access where needed.

### Browser
1. **Firefox** is installed by default (you can add Chrome extensions via **Add-ons**).
2. **Google Chrome** (optional):
```bash
cd ~/Downloads
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
# If you see dependency errors:
sudo apt -f install -y
```

### VPN options
- Clash Verge  
- v2ray / xray-core  

---

## Common development software
### Overview  
Recommended editors and tools for everyday development.

### VS Code (recommended)
1. **Install VS Code**  
   - GUI: open **Ubuntu Software**, search **Visual Studio Code**, click **Install**.  
   - CLI:
```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code
```

2. **Useful extensions for beginners**  
   Open VS Code → **Extensions** and install, for example:  
   - **C/C++** — IntelliSense and debugging  
   - **Python** — syntax and debugging  
   - **Git Graph** — visualize history  
   - **Chinese (Simplified)** — UI language (after install: Ctrl+Shift+P → **Configure Display Language**)  
   - **Code Runner** — run snippets quickly  

3. **Basics**  
   - **Open folder:** **File** → **Open Folder**  
   - **Run:** with Code Runner, use the ▶ button in the editor  
   - **Debug:** F5 and pick the environment (e.g. Python, C++)

### Sublime Text (lightweight editor)
```bash
# Add Sublime’s apt repository
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
# Install
sudo apt update
sudo apt install -y sublime-text
```

### Octave (MATLAB-like numeric computing)
1. Install:
```bash
sudo apt update
sudo apt install octave -y
# Launch
octave --gui
octave
```

2. **Basics**  
   - Arithmetic: `2 + 3`, `5 - 2`, `4 * 3`, `8 / 2`, `2^3`  
   - Variables and matrices:
```text
a = 5;
b = [1, 2, 3];
c = [1; 2; 3];
A = [1 2; 3 4];
```
   - Operations: `B = A'`, `C = A * A`, `D = A .* A`  
   - Functions: `sum`, `mean`, `max`, `min`, `size`, `eye`, `zeros`, `ones`  
   - Plotting example:
```text
x = 0:0.1:2*pi;
y = sin(x);
plot(x, y)
title('Sine wave')
xlabel('x')
ylabel('sin(x)')
grid on
```
   - Functions and scripts: save `example.m`, run `example` in Octave.  
   - Tips: `help functionname`, `clc`, `clear`, `close all`. Most `.m` files compatible with MATLAB work in Octave.

### LaTeX with VS Code (papers and typesetting)
1. Install TeX Live on Ubuntu 24.04:
```bash
sudo apt update
sudo apt install texlive-full -y
```

2. Open VS Code and install the **LaTeX Workshop** extension.

3. Configure LaTeX Workshop in `settings.json` (Ctrl+, → search **settings.json** → **Edit in settings.json**).

4. Example document `example.tex` (English; add `ctex` if you need Chinese):
```latex
\documentclass[12pt]{article}
\usepackage{amsmath, amssymb}

\title{LaTeX sample}
\author{Your name}
\date{\today}

\begin{document}
\maketitle

\section{Introduction}
This is a sample document using VS Code and LaTeX Workshop.

\section{Math}
Inline: $E=mc^2$.

Display:
\[
\int_0^\infty e^{-x}\, dx = 1
\]

\end{document}
```

5. Build and preview from VS Code, or use an external PDF viewer.

---
