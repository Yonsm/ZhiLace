#!/bin/sh
if [ ! -z $1 ] ; then
	adb disconnect
	adb connect $1
fi

adb shell "cd /sdcard/Android/data/org.xbmc.kodi/files/.kodi && tar -c -f /sdcard/BKODI.tar addons userdata"
adb pull /sdcard/BKODI.tar
adb shell rm /sdcard/BKODI.tar
