# Install RobotCAD on Ubuntu with Docker

## Contents
1. [Supported Environment](#supported-environment)
2. [Preparation](#preparation)
3. [Install Docker](#install-docker)
4. [Configure Docker User Permissions](#configure-docker-user-permissions)
5. [Install and Check Docker Compose](#install-and-check-docker-compose)
6. [Clone RobotCAD Source Code](#clone-robotcad-source-code)
7. [Run RobotCAD with Docker](#run-robotcad-with-docker)
8. [Optional: Use a FreeCAD AppImage](#optional-use-a-freecad-appimage)
9. [Common Maintenance Commands](#common-maintenance-commands)
10. [Optional: Docker Registry Mirrors](#optional-docker-registry-mirrors)
11. [Optional: NVIDIA / OpenGL Issues](#optional-nvidia--opengl-issues)
12. [Verify the Installation](#verify-the-installation)
13. [Common Docker Commands](#common-docker-commands)
14. [Troubleshooting](#troubleshooting)
15. [References](#references)

---

## Supported Environment

This guide explains how to install and run RobotCAD on Ubuntu with Docker. RobotCAD is also known as FreeCAD OVERCROSS, a FreeCAD workbench for robotics development.

According to the official README, the Docker workflow has been tested on:

- Ubuntu 24.04
- Ubuntu 22.04
- Ubuntu 20.04
- Windows 10 with WSL2 Ubuntu 22.04

Recommended environment:

- Ubuntu Desktop, preferably Ubuntu 22.04 or Ubuntu 24.04
- x86_64 PC
- A user account with `sudo` permission
- Network access to GitHub and Docker image sources
- A local Ubuntu desktop session or a working X11 display environment if you want to open the FreeCAD / RobotCAD GUI

Check the Ubuntu version and CPU architecture:

```bash
lsb_release -a
uname -m
```

If you are using ARM64 devices such as Jetson or Radxa boards, first confirm that the RobotCAD Docker build scripts and related images support ARM64.

---

## Preparation

Update the system and install common tools:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl ca-certificates x11-xserver-utils
```

Explanation:

- `git`: used to clone the RobotCAD source repository.
- `curl`: used to install Docker.
- `ca-certificates`: used for HTTPS certificate verification.
- `x11-xserver-utils`: provides `xhost`, which is needed when allowing Docker containers to display GUI windows through X11.

---

## Install Docker

This step follows the quick Docker installation method already used in this repository's [`nas_setup.md`](nas_setup.md).

```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo sh

# Version check
docker --version
```

If Docker is installed correctly, you should see output similar to:

```text
Docker version 28.x.x, build xxxxxxx
```

---

## Configure Docker User Permissions

By default, a normal user may not have permission to run Docker commands directly. Add the current user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

Apply the new group membership to the current terminal:

```bash
newgrp docker
```

The official Docker setup notes recommend rebooting after adding the user to the `docker` group. `newgrp docker` is useful for applying the group change in the current terminal, but rebooting is the most reliable method.

Test Docker:

```bash
docker run hello-world
```

If you still see `permission denied while trying to connect to the Docker daemon socket`, log out and log back in, or reboot the computer and try again.

---

## Install and Check Docker Compose

The RobotCAD Docker directory may use Docker Compose / Buildx plugins. Check Docker Compose V2 first:

```bash
docker compose version
```

If there is no output or the command is not found, install the Compose plugin:

```bash
sudo apt install -y docker-compose-plugin
```

Check Docker Buildx as well:

```bash
docker buildx version
```

If Buildx is missing, install the Buildx plugin:

```bash
sudo apt install -y docker-buildx-plugin
```

Check again:

```bash
docker compose version
docker buildx version
```

Use the modern Docker Compose V2 command:

```bash
docker compose
```

Do not use the old standalone command unless you intentionally installed it:

```bash
docker-compose
```

---

## Clone RobotCAD Source Code

Clone the RobotCAD repository:

```bash
cd ~/
git clone https://github.com/drfenixion/freecad.robotcad.git
```

Enter the Docker directory:

```bash
cd ~/freecad.robotcad/docker
```

---

## Run RobotCAD with Docker

Run this command inside the RobotCAD Docker directory:

```bash
bash run.bash -c
```

One-line version:

```bash
cd ~/ && git clone https://github.com/drfenixion/freecad.robotcad.git && cd freecad.robotcad/docker && bash run.bash -c
```

The script builds or starts the RobotCAD / FreeCAD Docker environment and opens a FreeCAD GUI window on the host machine.

The first run may take a long time because Docker needs to build images and download dependencies. Keep the network connection stable during this process.

Common host-side bind directories used by the RobotCAD Docker setup include:

```text
docker/freecad/freecad_projects_save_place/   # FreeCAD project save directory
docker/freecad/freecad_custom_appimage_dir           # Directory for a custom FreeCAD AppImage
docker/ros2_ws/src                            # src directory of the ROS 2 workspace
docker/ros2_ws/build_data                     # ROS 2 build / install / log data
~/.local/share/FreeCAD/Mod                    # Host FreeCAD Mod directory
```

Save long-term project files in a bind-mounted directory. Do not store important files only inside the container, because files that are not mounted from the host may be lost when the container is removed.

---

## Optional: Use a FreeCAD AppImage

The official README recommends using a FreeCAD `1.1.*` AppImage. FreeCAD `1.2.* dev` may also work, but RobotCAD should be updated first.

Put the FreeCAD AppImage into this directory:

```text
~/freecad.robotcad/docker/freecad/freecad_custom_appimage_dir
```

Make the AppImage executable, for example:

```bash
chmod +x ~/freecad.robotcad/docker/freecad/freecad_custom_appimage_dir/*.AppImage
```

Run with the custom AppImage for the first time:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -cif
```

After the first run, start it normally with:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -ci
```

---

## Common Maintenance Commands

Enter the RobotCAD repository:

```bash
cd ~/freecad.robotcad
```

Update RobotCAD and run it again:

```bash
git pull
cd docker
bash run.bash -fc
```

Force-create a fresh container and clean related build data:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -f
```

Rebuild the image and run a new container:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -b
```

Clean old container logs and start RobotCAD:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -c
```

---

## Optional: Docker Registry Mirrors

If Docker image pulling or dependency downloads are slow, configure Docker registry mirrors.

First check whether a Docker daemon configuration file already exists:

```bash
sudo ls /etc/docker/daemon.json
```

If the file already exists, do not overwrite it directly. Merge the `registry-mirrors` field into the existing configuration instead.

Edit the configuration file:

```bash
sudo nano /etc/docker/daemon.json
```

Example configuration:

```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.nju.edu.cn"
  ]
}
```

Restart Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Check the Docker configuration:

```bash
docker info
```

Do not blindly copy old Docker apt source settings from older scripts. Also do not add `nvidia-container-runtime` unless NVIDIA Container Toolkit is installed and needed.

---

## Optional: NVIDIA / OpenGL Issues

RobotCAD / FreeCAD is a GUI application, so some computers may encounter OpenGL or GPU-related issues.

First check whether the host NVIDIA driver works:

```bash
nvidia-smi
```

If the host GPU driver does not work, fix the host driver first before troubleshooting graphics inside Docker.

If startup fails with an error similar to `failed to create drawable`, the RobotCAD README suggests forcing NVIDIA container options:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -fcn
```

If your computer does not have an NVIDIA GPU, or if you are using only CPU / integrated graphics, you do not need to run the command in this section.

---

## Verify the Installation

### 1. Verify Docker

```bash
docker --version
docker compose version
docker buildx version
docker run hello-world
```

### 2. Verify the RobotCAD container

Enter the RobotCAD Docker directory:

```bash
cd ~/freecad.robotcad/docker
```

Start RobotCAD:

```bash
bash run.bash -c
```

If the FreeCAD / RobotCAD GUI window opens successfully, the basic setup is working.

### 3. Verify the project save directory

In FreeCAD / RobotCAD, save a test project to the bind-mounted project directory, for example:

```text
~/freecad.robotcad/docker/freecad/freecad_projects_save_place/
```

Then return to the Ubuntu terminal and check that the file exists:

```bash
ls ~/freecad.robotcad/docker/freecad/freecad_projects_save_place/
```

---

## Common Docker Commands

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

List images:

```bash
docker images
```

View container logs:

```bash
docker logs <container-name-or-id>
```

Enter a running container:

```bash
docker exec -it <container-name-or-id> bash
```

Stop a container:

```bash
docker stop <container-name-or-id>
```

Remove a container:

```bash
docker rm <container-name-or-id>
```

---

## Troubleshooting

### 1. Docker daemon permission denied

Symptom:

```text
permission denied while trying to connect to the Docker daemon socket
```

Fix:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

If it still fails, log out and log back in, or reboot the computer.

### 2. `docker compose` command not found

Install the Docker Compose plugin:

```bash
sudo apt update
sudo apt install -y docker-compose-plugin
```

Verify:

```bash
docker compose version
```

### 3. `xhost: command not found`

Install the package that provides `xhost`:

```bash
sudo apt install -y x11-xserver-utils
```

### 4. GUI window does not appear

Check `DISPLAY` first:

```bash
echo $DISPLAY
```

Allow local Docker containers to access the X server:

```bash
xhost +local:docker
```

Ubuntu 24.04 may use Wayland by default. If the GUI still does not appear, log out, use the gear menu on the login screen, choose **Ubuntu on Xorg**, log in again, and retry.

After finishing your work, you can revoke the X server permission:

```bash
xhost -local:docker
```

### 5. Docker pull or build is slow

Try the following:

- Check the network connection.
- Configure Docker registry mirrors.
- Use a team-provided internal image mirror if available.
- Run `bash run.bash -c` again.

### 6. `failed to create drawable`

If you use an NVIDIA GPU, try:

```bash
cd ~/freecad.robotcad/docker
bash run.bash -fcn
```

If you do not have an NVIDIA GPU, this option is not recommended.

### 7. UID or username issue during Docker build

If the build script fails to detect the current username, check the username first:

```bash
echo $USER
```

Then run the script with the username explicitly set:

```bash
cd ~/freecad.robotcad/docker
USER=replace_with_your_user_name bash run.bash
```

Replace `replace_with_your_user_name` with the output of `echo $USER`.

### 8. RobotCAD conflicts with the FreeCAD CROSS workbench

RobotCAD and the FreeCAD CROSS workbench use the same namespace, which can cause conflicts. If you previously installed the CROSS workbench, remove CROSS before installing or running RobotCAD.

### 9. FreeCAD segmentation fault

If FreeCAD starts with this error:

```text
Program received signal SIGSEGV, Segmentation fault.
```

A common cause is incorrect permissions on FreeCAD-related directories. The common directory is:

```text
~/.local/share/FreeCAD
```

Change the owner back to the current user:

```bash
sudo chown -R $USER:$USER ~/.local/share/FreeCAD
```

If you are migrating from a version earlier than v7 to v7+, try:

```bash
cd ~/freecad.robotcad
git pull
cd docker
bash run.bash -bco
```

If you are already using a version after v7, try:

```bash
cd ~/freecad.robotcad
git pull
cd docker
bash run.bash -fco
```

---

## References

- [RobotCAD / FreeCAD OVERCROSS GitHub repository](https://github.com/drfenixion/freecad.robotcad)
- [RobotCAD Docker README](https://github.com/drfenixion/freecad.robotcad/blob/main/docker/README.md)
- [FreeCAD official website](https://www.freecad.org/)
- [ROS official website](https://www.ros.org/)
- [Docker Engine installation on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Ubuntu 24.04 setup in this repository](ubuntu_setup.md)
- [NAS Docker setup in this repository](nas_setup.md)
