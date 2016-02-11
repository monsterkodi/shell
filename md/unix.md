# map hostname to ip in local network

/private/etc/hosts

# raspi

## rename

/etc/hostname
/etc/hosts

## set timezone

sudo dpkg-reconfigure tzdata

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

## sources

etc/apt/sources.list

## search package

apt-cache search package

## list installed packages

dpkg --get-selections

## files from a package

dpkg -L package
