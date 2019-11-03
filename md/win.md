
## cmd

#### msys pacman upgrade

pacman -Syu

#### set buffer size
mode con lines=32766

#### create symlink

mklink -D c:\link\... c:\target\...

### p4

#### get curent changelist

p4 changes -m1 ...#have   

#### rename file (keeps history)

p4 rename fromFile toFile


### WSL (Ubuntu)

#### enable WSL (Admin PowerShell)

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

... install Ubuntu from Windows Store

#### install fish

sudo apt-add-repository ppa:fish-shell/release-2
sudo apt-get update
sudo apt-get install fish