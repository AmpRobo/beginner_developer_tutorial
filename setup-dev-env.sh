#!/usr/bin/env bash
# Install common development packages and ROS 2 (Jazzy on Ubuntu 24.04, Humble on 22.04).
# Usage: setup-dev-env.sh [-y] [-h] [--skip-ros]

set -e

print_help() {
    echo "Usage: setup-dev-env.sh [OPTIONS]"
    echo "Options:"
    echo "  -h, --help    Show this help"
    echo "  -y            Non-interactive: no prompt, use apt -y"
    echo "  --skip-ros    Do not install ROS 2"
    echo ""
}

option_yes=false
option_skip_ros=false
while [ "${1:-}" != "" ]; do
    case "$1" in
    -h | --help)
        print_help
        exit 0
        ;;
    -y)
        option_yes=true
        ;;
    --skip-ros)
        option_skip_ros=true
        ;;
    *)
        echo "Unknown option: $1" >&2
        print_help
        exit 1
        ;;
    esac
    shift
done

if [ "$option_yes" = true ]; then
    export DEBIAN_FRONTEND=noninteractive
    APT_NONINTERACTIVE=(--yes)
else
    echo -e "\e[33mThis will install common development packages via apt"
    if [ "$option_skip_ros" = false ]; then
        echo -e "and ROS 2 (Jazzy on Ubuntu 24.04, Humble on 22.04).\e[m"
    else
        echo -e "(ROS 2 skipped).\e[m"
    fi
    read -rp "> Continue? [y/N] " answer
    if ! [[ ${answer:0:1} =~ y|Y ]]; then
        echo -e "\e[33mCancelled.\e[0m"
        exit 1
    fi
    APT_NONINTERACTIVE=()
fi

# Install sudo
if ! command -v sudo >/dev/null 2>&1; then
    apt-get -y update
    apt-get -y install sudo
fi

sudo apt-get "${APT_NONINTERACTIVE[@]}" update
sudo apt-get "${APT_NONINTERACTIVE[@]}" install \
    git \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    cmake \
    python3 \
    python3-pip \
    python3-venv

# --- ROS 2 (from install_ros2.sh: Jazzy on noble, Humble on jammy) ---
if [ "$option_skip_ros" = true ]; then
    echo -e "\e[32mDone (ROS 2 skipped).\e[0m"
    exit 0
fi

UBUNTU_VERSION=$(lsb_release -sc)
ROS_VERSION=""
case $UBUNTU_VERSION in
noble)
    ROS_VERSION="jazzy"
    ;;
jammy)
    ROS_VERSION="humble"
    ;;
*)
    echo -e "\e[33mSkipping ROS 2: unsupported Ubuntu ($UBUNTU_VERSION). Supported: noble (24.04), jammy (22.04).\e[m"
    echo -e "\e[32mDone.\e[0m"
    exit 0
    ;;
esac

echo -e "\e[36mInstalling ROS 2 ${ROS_VERSION}...\e[m"

# Locales
sudo apt-get "${APT_NONINTERACTIVE[@]}" install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# ROS 2 apt source (ros-apt-source .deb)
sudo apt-get "${APT_NONINTERACTIVE[@]}" install software-properties-common
sudo add-apt-repository -y universe
sudo apt-get "${APT_NONINTERACTIVE[@]}" update
export ROS_APT_SOURCE_VERSION
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -fsSL -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo "${UBUNTU_CODENAME:-${VERSION_CODENAME}}")_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# Packages
sudo apt-get "${APT_NONINTERACTIVE[@]}" update
sudo apt-get "${APT_NONINTERACTIVE[@]}" install ros-dev-tools
sudo apt-get "${APT_NONINTERACTIVE[@]}" update
sudo apt-get "${APT_NONINTERACTIVE[@]}" upgrade
sudo apt-get "${APT_NONINTERACTIVE[@]}" install "ros-${ROS_VERSION}-desktop"

sudo apt-get "${APT_NONINTERACTIVE[@]}" install python3-rosdep python3-colcon-common-extensions
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update

# Shell setup
if ! grep -q "ROS 2 ${ROS_VERSION}" ~/.bashrc 2>/dev/null; then
    {
        echo ""
        echo "# ROS 2 ${ROS_VERSION} environment"
        echo "source /opt/ros/${ROS_VERSION}/setup.bash"
        echo "source /usr/share/colcon_cd/function/colcon_cd.sh"
        echo "export _colcon_cd_root=/opt/ros/${ROS_VERSION}/"
    } >> ~/.bashrc
fi

echo -e "\e[32mDone.\e[0m ROS 2 ${ROS_VERSION} installed."
echo "Reload: source ~/.bashrc  |  Verify: ros2 run demo_nodes_cpp talker"
