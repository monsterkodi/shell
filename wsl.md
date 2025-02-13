

sudo systemctl start graphical.target
sudo systemctl enable wslg-tmp-x11
sudo systemctl --global enable wslg-runtime-dir


gnome-tweaks
gsettings list-schemas
gsettings list-keys
gsettings list-keys org.gnome.desktop
gsettings list-recursively | rg theme 'prefer-dark' color-scheme


/var/lib/gdm3
/usr/bin/Xorg
/tmp/.X11-unix
/mnt/wslg/run/user/1000
/mnt/wslg/runtime-dir
/usr/lib/systemd
/usr/lib/systemd/user

XGD_RUNTIME_DIR
XDG_CONFIG_HOME
XDG_DATA_DIRS
