# NAS SSD Setup on Ubuntu Server 24.04

## Overview

This guide covers:

1. Detecting a new SSD
2. Creating a partition table
3. Formatting the SSD
4. Mounting the SSD
5. Configuring automatic mounting
6. Accessing the mounted storage
7. Setting up a USB Wi‑Fi adapter

---

## 1. Detect the SSD

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

---

## 2. Create a GPT Partition

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

---

## 3. Format the SSD

```bash
sudo mkfs.ext4 /dev/sdb1
```

---

## 4. Create a Mount Point

```bash
sudo mkdir -p /data
```

---

## 5. Mount the SSD

```bash
sudo mount /dev/sdb1 /data
```

Verify:

```bash
df -h
lsblk -f
```

---

## 6. Configure Automatic Mounting

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
UUID=<your-uuid> /data ext4 defaults,nofail 0 2
```

Test:

```bash
sudo mount -a
```

---

## 7. Accessing the SSD

```bash
cd /data
ls
```

Check mount locations:

```bash
lsblk -f
```

---

## 8. USB Wi‑Fi Setup

Detect the adapter:

```bash
lsusb
ip link
iw dev
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

### Netplan Alternative

Edit:

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

Example:

```yaml
network:
  version: 2
  wifis:
    wlan0:
      dhcp4: true
      access-points:
        "YourSSID":
          password: "YourPassword"
```

Apply:

```bash
sudo netplan generate
sudo netplan apply
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
