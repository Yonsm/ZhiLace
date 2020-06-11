#!/bin/sh
if [ ! -z $1 ] ; then
	adb disconnect
	adb connect $1
fi

adb push addons.tar /sdcard
adb shell "tar -x -f /sdcard/addons.tar -C /sdcard/Android/data/org.xbmc.kodi/files/.kodi/"
adb shell "rm /sdcard/addons.tar"

adb push userdata.tar /sdcard
adb shell "tar -x -f /sdcard/userdata.tar -C /sdcard/Android/data/org.xbmc.kodi/files/.kodi/"
adb shell "rm /sdcard/userdata.tar"

adb shell "ls -la /sdcard/Android/data/org.xbmc.kodi/files/.kodi/userdata"
