#!/bin/bash

IMAGE=rpb-console-image-lava-hikey960
BASE_URL=http://snapshots.linaro.org/reference-platform/embedded/morty/hikey960/latest/rpb/
BOOTLOADER_URL=${BASE_URL}bootloader/


DEVICE=`dmesg | grep ttyUSB | tail -1 | rev | awk '{print $1}' | rev`
if [ "$DEVICE" == "ttyUSB0" ]
then
	sudo ln -s /dev/ttyUSB0 /dev/ttyUSB1 && REMOVE=1
fi

git clone https://github.com/96boards-hikey/tools-images-hikey960.git

cd tools-images-hikey960
t=0
until sudo ./recovery-flash.sh /dev/$DEVICE
do
	sleep 5
	if [ "$t" -eq "4" ]
	then
		exit 1
	fi
	t+=1
done
cd ..


mkdir bootloader
cd bootloader
wget -A bin,config,efi,hikey_idt,img,txt -m -nd -np "$BOOTLOADER_URL"
cd ..


mkdir images
cd images
wget -A ${IMAGE}-*-130.rootfs.img.gz,uefi.img -m -nd -np "$BASE_URL"
cd ..

for i in `find images/ -name *.gz -type f`
do
	if [ ! -f $(echo $i | awk -F'.gz' '{print $1}') ]
	then
		gunzip -k $i
	fi
done

IMAGES=`find images/`
EMMC=`echo "$IMAGES" | grep $IMAGE | grep -e rootfs.img$`
UEFI=`echo "$IMAGES" | grep -e uefi.img$`

echo $EMMC
echo $UEFI

sudo fastboot reboot

sleep 30

cd bootloader/
echo Running hikey_idt...
sudo chmod +x hikey_idt
sudo ./hikey_idt -c config

sudo fastboot flash ptable prm_ptable.img
sudo fastboot flash xloader sec_xloader.img
sudo fastboot flash fastboot l-loader.bin
sudo fastboot flash fip fip.bin
cd ..

sudo fastboot flash boot $UEFI
sudo fastboot flash system $EMMC

if [ "$REMOVE" -eq "1" ] 
then
	sudo rm /dev/ttyUSB1
fi


