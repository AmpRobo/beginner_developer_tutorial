# NAS SSD Setup on Ubuntu Server 24.04

## Dependency Installation
### General tools 
```sh
sudo apt-get install git fdisk net-tools dkms build-essential rsnapshot linux-headers-$(uname -r) network-manager rfkill iftop
```
### Docker
```sh
# Install docker
curl -fsSL https://get.docker.com | sudo sh

# Version check
docker --version

# Add docker group
sudo usermod -aG docker $USER

# Log again
newgrp docker

# Test
docker run hello-world

# Check installation of Docker Compose
docker compose version

# Install if no feedback
sudo apt install docker-compose-plugin
```
### Zerotier
```sh
# Install
curl -s https://install.zerotier.com | sudo bash

# Check staus
sudo zerotier-cli info
```

## Setup SSD

This guide covers:
1. Detecting a new SSD
2. Creating a partition table
3. Formatting the SSD
4. Mounting the SSD
5. Configuring automatic mounting
6. Accessing the mounted storage
7. Setting up a USB Wi‑Fi adapter

### 1. Detect the SSD

```bash
lsblk
```

or

```bash
sudo fdisk -l
```

Example:

```text
NAME   SIZE TYPE
sda    500G disk
sdb      2T disk
```

Assume the new SSD is `/dev/sdb`.

### 2. Create a GPT Partition

```bash
sudo fdisk /dev/sdb
```

Inside `fdisk`:

```text
g
n
<Enter>
<Enter>
<Enter>
w
```

This creates `/dev/sdb1`.

Verify:

```bash
lsblk
```

### 3. Format the SSD

```bash
sudo mkfs.ext4 /dev/sdb1
```

### 4. Create a Mount Point

```bash
sudo mkdir -p /mnt/data
```
### 5. Mount the SSD

```bash
sudo mount /dev/sdb1 /mnt/data
```

Verify:

```bash
df -h
lsblk -f
```

### 6. Configure Automatic Mounting

Get the UUID:

```bash
sudo blkid /dev/sdb1
```

Edit fstab:

```bash
sudo nano /etc/fstab
```

Add:

```text
UUID=<your-uuid> /mnt/data ext4 defaults,nofail 0 2
```

Test:

```bash
sudo mount -a
```

### 7. Accessing the SSD

```bash
cd /mnt/data
ls
```

Check mount locations:

```bash
lsblk -f
```
---
## Setup Cloud

### Zerotier Setup
#### Create Zerotier Network
1. Log in ZeroTier Central: https://my.zerotier.com
2. Create network
3. Get Network ID: 8056c2e21cxxxxxx
#### Add PC to Zerotier Network
```sh
# Add PC to Zerotier Network
sudo zerotier-cli join 8056c2e21cxxxxxx

# Check status
sudo zerotier-cli listnetworks

# Back to ZeroTier Central, click 'Auth' in 'Members' to authorize device

# Check IP
ip addr
# For example
10.147.20.5
```
### Nextcloud

```sh
# Install by snap
sudo snap install nextcloud
# Initialize and create admin account (recommand access from web page with IP directly)
sudo nextcloud.manual-install admin 'admin'

# Check the IP
sudo nextcloud.occ config:system:get trusted_domains
# You will see something like:
# 0 => localhost
# 1 => 192.168.3.221
# 2 => 10.181.44.10
# Set up public IP
sudo nextcloud.occ config:system:set trusted_domains 1 --value=ZIMABOARD_IP

# Check storage folder
sudo nextcloud.occ config:system:get datadirectory
# Output is like: /var/snap/nextcloud/common/nextcloud/data

# Stop nextcloud
sudo snap stop nextcloud
# Create folder
sudo mkdir -p /mnt/data/nextcloud/data
# Allow access to external disk
sudo snap connect nextcloud:removable-media

# Edit config file
sudo nano /var/snap/nextcloud/current/nextcloud/config/config.php
# Find "'datadirectory' => '/var/snap/nextcloud/common/nextcloud/data',", change to
'datadirectory' => '/mnt/data/nextcloud/data',
# Change access
sudo chown -R root:www-data /mnt/data/nextcloud/data
sudo chmod -R 750 /mnt/data/nextcloud/data

# Start Nextcloud
sudo snap start nextcloud
# Check folder path again
sudo nextcloud.occ config:system:get datadirectory
```
<!-- ```sh
# Create folder
mkdir ~/nextcloud
cd ~/nextcloud

# Create config file
nano compose.yml

# Start up Nextcloud
docker compose up -d

# Check status
docker ps
```
compose.yml:
```sh
services:

  db:
    image: mariadb:11
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: nextcloudpass

    volumes:
      - db:/var/lib/mysql

  app:
    image: nextcloud
    restart: always
    ports:
      - "8081:80"

    environment:
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: nextcloudpass
      MYSQL_HOST: db

    volumes:
      - /mnt/data/nextcloud:/var/www/html

volumes:
  db:
``` -->
Log in for the fisrt time and create account:
```sh
# Open web brouser and enter
http://ZIMABOARD_IP
```

## Automatic Backup Setup

### Setup rsnapshot
Two SATA SSDs will be set up, and data will be synchrized to backup everyday:
```sh
SSD1: /mnt/data
SSD2: /mnt/backup
```

```sh
# Modify config file
sudo nano /etc/rsnapshot.conf

# Change
snapshot_root   /var/cache/rsnapshot/
# To
snapshot_root   /mnt/backup/rsnapshot/

# Modify
retain  daily   7
retain  weekly  4
retain  monthly 3

cmd_rsync      /usr/bin/rsync

# Change
backup  /home/          localhost/
# To
backup  /mnt/data/      data/

# Check status
sudo rsnapshot configtest
# Output
Syntax OK

# Manual
sudo rsnapshot daily
tree -L 2 /mnt/backup/rsnapshot
#rsnapshot
#└── daily.0
#    └── data

# Check
du -sh /mnt/backup/rsnapshot
```

### Automatic Synchronization
Ubuntu 24.04 systemd timer
```sh
# Create service
sudo nano /etc/systemd/system/rsnapshot-daily.service
# Add following to rsnapshot-daily.service
[Unit]
Description=rsnapshot daily backup

[Service]
Type=oneshot
ExecStart=/usr/bin/rsnapshot daily

# Cteate timer
sudo nano /etc/systemd/system/rsnapshot-daily.timer
# Add following to rsnapshot-daily.timer
[Unit]
Description=Run rsnapshot daily

[Timer]
OnCalendar=03:00
Persistent=true

[Install]
WantedBy=timers.target

# Start service
sudo systemctl daemon-reload
sudo systemctl enable rsnapshot-daily.timer
sudo systemctl start rsnapshot-daily.timer

# Check
systemctl list-timers
```

How to recover files
```sh
# If deleted
/mnt/data/report.docx
# Recover by
cp /mnt/backup/rsnapshot/daily.1/data/report.docx /mnt/data/
```

对于你的 1TB SSD 推荐配置

假设 SSD2 也是 1TB：

retain daily 7
retain weekly 4
retain monthly 2

一个更稳妥的配置

在 /etc/rsnapshot.conf 中增加：

link_dest 1

并确保备份项为：

backup /mnt/data/ data/

然后在同步前先确认备份盘已挂载：

mountpoint -q /mnt/backup || exit 1

避免 SSD2 掉线时把数据写到系统盘目录里。

---
## USB Wi‑Fi Setup

Detect the adapter:

```bash
lsusb
ip link
```

Check drivers:

```bash
sudo dmesg | grep -iE "wifi|wlan|80211|firmware"
sudo lshw -C network
```

Scan networks:

```bash
nmcli device wifi list
```

Install NetworkManager if needed:

```bash
sudo apt update
sudo apt install network-manager
sudo systemctl enable --now NetworkManager
```

Connect:

```bash
nmcli device wifi connect "YourSSID" password "YourPassword"
```

Verify:

```bash
nmcli connection show --active
ip addr
```

---

## Useful Diagnostics

Storage:

```bash
lsblk
lsblk -f
df -h
sudo blkid
```

Wi‑Fi:

```bash
lsusb
ip link
iw dev
nmcli device wifi list
```
