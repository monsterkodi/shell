
## mac

#### make bootable usb drive from clonezilla iso

hdiutil convert -format UDRW -o clonezilla.img clonezilla-live-20160210-wily-amd64.iso

#### identify usb drive

diskutil list

#### partition usb drive

diskutil partitionDisk /dev/disk3 1 "Free Space" "unused" "100%"

#### copy img to drive (ctrl+t for progress)

sudo dd if=clonezilla.img.dmg of=/dev/disk3 bs=1m