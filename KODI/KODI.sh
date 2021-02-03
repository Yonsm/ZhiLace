#!/bin/sh
if [ ! -z $1 ] ; then
	adb disconnect
	adb connect $1
fi

adb push KODI.tar /sdcard/
adb shell "rm -rf /sdcard/Android/data/org.xbmc.kodi/files/.kodi/ && mkdir -p /sdcard/Android/data/org.xbmc.kodi/files/.kodi/"
adb shell "tar -x -f /sdcard/KODI.tar -C /sdcard/Android/data/org.xbmc.kodi/files/.kodi/"
adb shell "rm /sdcard/KODI.tar"
adb shell "ls -la /sdcard/Android/data/org.xbmc.kodi/files/.kodi/userdata"
