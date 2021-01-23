#!/bin/bash
GADGET_PATH=/sys/kernel/config/usb_gadget/pi4

mkdir $GADGET_PATH


echo 0x1d6b > $GADGET_PATH/idVendor
echo 0x0104 > $GADGET_PATH/idProduct
echo 0x0100 > $GADGET_PATH/bcdDevice
echo 0x0200 > $GADGET_PATH/bcdUSB

echo 0xEF > $GADGET_PATH/bDeviceClass
echo 0x02 > $GADGET_PATH/bDeviceSubClass
echo 0x01 > $GADGET_PATH/bDeviceProtocol

mkdir $GADGET_PATH/strings/0x409
echo 100000000d2386db > $GADGET_PATH/strings/0x409/serialnumber
echo "Samsung" > $GADGET_PATH/strings/0x409/manufacturer
echo "PI4 USB Device" > $GADGET_PATH/strings/0x409/product
mkdir $GADGET_PATH/configs/c.2
mkdir $GADGET_PATH/configs/c.2/strings/0x409
echo 500 > $GADGET_PATH/configs/c.2/MaxPower
echo "UVC" > $GADGET_PATH/configs/c.2/strings/0x409/configuration

mkdir $GADGET_PATH/functions/uvc.usb0
mkdir $GADGET_PATH/functions/acm.usb0

# cat <<EOF $GADGET_PATH/functions/uvc.usb0/control/processing/default/bmControls
# 0
# 0
# EOF

mkdir -p $GADGET_PATH/functions/uvc.usb0/control/header/h
ln -s $GADGET_PATH/functions/uvc.usb0/control/header/h $GADGET_PATH/functions/uvc.usb0/control/class/fs/h
# ln -s $GADGET_PATH/functions/uvc.usb0/control/header/h $GADGET_PATH/functions/uvc.usb0/control/class/hs/h
# ln -s $GADGET_PATH/functions/uvc.usb0/control/header/h $GADGET_PATH/functions/uvc.usb0/control/class/ss/h

rm -f $GADGET_PATH/functions/uvc.usb0/streaming/mjpeg/m/360p
rm -f $GADGET_PATH/functions/uvc.usb0/streaming/mjpeg/m/720p
rm -f $GADGET_PATH/functions/uvc.usb0/streaming/mjpeg/m/900p
rm -f $GADGET_PATH/functions/uvc.usb0/streaming/mjpeg/m/1080p
rm -f $GADGET_PATH/functions/uvc.usb0/streaming/mjpeg/m/1200p
rm -f $GADGET_PATH/functions/uvc.usb0/streaming/mjpeg/m/1440p

FORMAT="mjpeg"
NAME="m"
WIDTH=1600
HEIGHT=900

framedir=$GADGET_PATH/functions/uvc.usb0/streaming/$FORMAT/$NAME/${HEIGHT}p

mkdir -p $framedir

echo $WIDTH > $framedir/wWidth
echo $HEIGHT > $framedir/wHeight
echo 333333 > $framedir/dwFrameInterval
echo 333333 > $framedir/dwDefaultFrameInterval
echo $(($WIDTH * $HEIGHT * 80)) > $framedir/dwMinBitRate
echo $(($WIDTH * $HEIGHT * 160)) > $framedir/dwMaxBitRate
echo $(($WIDTH * $HEIGHT * 2)) > $framedir/dwMaxVideoFrameBufferSize

mkdir $GADGET_PATH/functions/uvc.usb0/streaming/header/h
cd $GADGET_PATH/functions/uvc.usb0/streaming/header/h
ln -s ../../mjpeg/m
# ln -s ../../uncompressed/u
cd ../../class/fs
ln -s ../../header/h
cd ../../class/hs
ln -s ../../header/h
cd ../../../../..

ln -s $GADGET_PATH/functions/uvc.usb0 $GADGET_PATH/configs/c.2/uvc.usb0
ln -s $GADGET_PATH/functions/acm.usb0 $GADGET_PATH/configs/c.2/acm.usb0
udevadm settle -t 5 || :
ls /sys/class/udc > $GADGET_PATH/UDC
