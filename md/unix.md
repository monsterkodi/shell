# map hostname to ip in local network

/private/etc/hosts

# raspi

## rename

/etc/hostname
/etc/hosts

## set timezone

sudo dpkg-reconfigure tzdata

## analog audio

amixer cset numid=3 1

## setup wlan

/etc/network/interfaces

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp

### setup dhcp for ethernet

iface eth0 inet dhcp

## update

sudo apt-get update
sudo apt-get upgrade

## raspbian disable wifi dongle sleep

cat /sys/module/8192cu/parameters/rtw_power_mgnt
sudo nano /etc/modprobe.d/8192cu.conf
options 8192cu rtw_power_mgnt=0 rtw_enusbss=0

## sources

etc/apt/sources.list

## search package

apt-cache search package

## list installed packages

dpkg --get-selections

## files from a package

dpkg -L package

## convert binary <-> ascii
xxd binary
xxd -r ascii

# macOS 

## startup

/Library/StartupItems
/Library/LaunchAgents
/Library/LaunchDaemons
/System/Library/LaunchAgents
/System/Library/LaunchDaemons
