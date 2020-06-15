#!/bin/sh

LAN_DOMAIN=yonsm.tk
PPOE_NAME=057101258602
PPPOE_PASS=08065222
ADMIN_PASS=gjzgqz
WIFI_PASS=asdfqwer
WIFI_STA_SSID=alibaba-guest
DDNS_NAME=yonsmguo
DDNS_PASS=Gzczqu30
DDNS_HOST=yonsm.f3322.net


[ -z $1 ] && echo "Usage: $0 <NAME> [SSID]" && exit
[ "${1::1}" != "R" ] && ADMIN_PASS=$WIFI_PASS

# WIFI
if [ -z $2 ]; then SSID=Router; else SSID=$2; fi
if [ ! -z `nvram get rt_wpa_psk` ]; then
	nvram set rt_ssid=$SSID
	nvram set rt_ssid2=$SSID
	nvram set rt_wpa_psk=$WIFI_PASS
fi
if [ ! -z `nvram get wl_wpa_psk` ]; then
	nvram set wl_ssid=${SSID}5
	nvram set wl_ssid2=${SSID}5
	nvram set wl_wpa_psk=$WIFI_PASS
fi

# WISP
if [ "$1" = "ROUTER" ]; then
	nvram set wl_mode_x=3
	nvram set wl_sta_wisp=1
	nvram set wl_sta_ssid=$WIFI_STA_SSID
	nvram set wl_channel=157
	nvram set wl_sta_auto=1
fi

# LAN
LEN=$((${#1}-1))
lan_ip=${1:$LEN:1}
expr $lan_ip "+" 0 &> /dev/null || lan_ip=1
nvram set lan_ipaddr=192.168.1.$lan_ip
nvram set dhcp_start=192.168.1.70
nvram set dhcp_end=192.168.1.99
[ "${1::6}" = "Router" ] && nvram set lan_domain=$LAN_DOMAIN

if [ "$1" = "Router" ]; then
	# WAN
	nvram set wan_proto=pppoe
	nvram set wan_pppoe_username=$PPOE_NAME
	nvram set wan_pppoe_passwd=$PPPOE_PASS

	# VTS
	MAPS="RT2,82,2 RT3,83,3 DSM,5001,4 SSH,22,9 HAS,8123,9 VNC,5900,10 "
	nvram set vts_enable_x=1
	nvram set vts_num_x=`echo "$MAPS" | tr -cd ' ' | wc -c`
	IDX="0"
	for MAP in $MAPS; do
		nvram set vts_proto_x$IDX=TCP
		nvram set vts_desc_x$IDX=`echo $MAP | cut -d , -f 1`
		nvram set vts_port_x$IDX=`echo $MAP | cut -d , -f 2`
		nvram set vts_ipaddr_x$IDX=192.168.1.`echo $MAP | cut -d , -f 3`
		IDX=`expr $IDX + 1`
	done

	# IPTV
	nvram set udpxy_enable_x=4000
	nvram set viptv_mode=2
	nvram set vlan_vid_iptv=9
	nvram set vlan_vid_lan4=9
	nvram set viptv_ipaddr=10.198.137.188
	nvram set viptv_netmask=255.255.192.0
	nvram set viptv_gateway=10.198.128.1
	nvram set udpxy_wopen=1

	# DDNS
	nvram set ddns_server_x=CUSTOM
	nvram set ddns_username_x=$DDNS_NAME
	nvram set ddns_passwd_x=$DDNS_PASS
	nvram set ddns_hostname_x=$DDNS_HOST
fi

if [ "$lan_ip" = "1" ] && [ "$1" != "ROUTER" ]; then
	# FW
	nvram set https_wopen=1
	nvram set trmd_ropen=1
	nvram set aria_ropen=1
	nvram set ftpd_wopen=1

	# USB
	nvram set enable_samba=1
	nvram set enable_ftp=1
	nvram set trmd_enable=1
	nvram set aria_enable=1
	nvram set acc_username0=admin
	nvram set acc_password0=$ADMIN_PASS
	nvram set acc_num=1
fi

# SYS
nvram set computer_name=`echo ${1::1} | tr  '[a-z]' '[A-Z]'``echo ${1:1} | tr  '[A-Z]' '[a-z]'`
nvram set http_passwd=$ADMIN_PASS
if [ "$1" != "ROUTER" ]; then
	nvram set http_proto=2
	nvram set https_lport=8$lan_ip
fi

nvram commit
reboot
