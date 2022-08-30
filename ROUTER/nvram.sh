#!/bin/sh

HOST=$1
SSID=$2
#LAN_DOMAIN=guoz.ga
PPOE_NAME=057101258602
PPPOE_PASS=08065222
ADMIN_PASS=gjzgqz
WIFI_PASS=asdfqwer
WIFI_STA_SSID=alibaba-guest
DDNS_NAME=311788
DDNS_PASS=e9b28f4e9ccf52fc7c91b2a9e835733b
DDNS_HOST=guoz.ga
DDNS_HOST=guoz.ml

[ -z $HOST ] && echo "Usage: $0 <NAME> [SSID]" && exit
[ "${HOST::1}" != "R" ] && ADMIN_PASS=asdfzxcv

# WIFI
if [ -z $SSID ]; then SSID=Router; else SSID=$2; fi
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
if [ "$HOST" = "ROUTER" ]; then
	nvram set wl_mode_x=3
	nvram set wl_sta_wisp=1
	nvram set wl_sta_ssid=$WIFI_STA_SSID
	nvram set wl_channel=157
	nvram set wl_sta_auto=1
fi

# LAN
LEN=$((${#HOST}-1))
lan_ip=${HOST:$LEN:1}
if [ "$HOST" = "router" ]; then
	lan_pre=192.168.2
	nvram set dhcp_start=$lan_pre.10
else
	lan_pre=192.168.1
	nvram set dhcp_start=$lan_pre.70
fi
expr $lan_ip "+" 0 &> /dev/null || lan_ip=1
nvram set lan_ipaddr=$lan_pre.$lan_ip
nvram set dhcp_end=$lan_pre.99
#[ "${HOST::6}" = "Router" ] && nvram set lan_domain=$LAN_DOMAIN

if [ "$HOST" = "Router" ]; then
	# WAN
	nvram set wan_proto=pppoe
	nvram set wan_pppoe_username=$PPOE_NAME
	nvram set wan_pppoe_passwd=$PPPOE_PASS

	# VTS
	MAPS="HASS,82:89,8  "
	nvram set vts_enable_x=1
	nvram set vts_num_x=`echo "$MAPS" | tr -cd ' ' | wc -c`
	IDX="0"
	for MAP in $MAPS; do
		nvram set vts_proto_x$IDX=TCP
		nvram set vts_desc_x$IDX=`echo $MAP | cut -d , -f 1`
		nvram set vts_port_x$IDX=`echo $MAP | cut -d , -f 2`
		nvram set vts_ipaddr_x$IDX=$lan_pre.`echo $MAP | cut -d , -f 3`
		IDX=`expr $IDX + 1`
	done

	# IPTV
	nvram set udpxy_enable_x=4000
	nvram set vlan_filter=1
	nvram set viptv_mode=2
	nvram set vlan_vid_iptv=9
	nvram set vlan_vid_lan4=9
	nvram set viptv_ipaddr=10.198.137.188
	nvram set viptv_netmask=255.255.192.0
	nvram set viptv_gateway=10.198.128.1
	nvram set udpxy_wopen=1
	nvram set wan_stb_x=4
	nvram set wan_src_phy=0
	nvram set wan_stb_iso=2

	# DDNS
	nvram set ddns_ssl=1
	nvram set ddns_enable_x=1
	nvram set ddns_server_x=DNSPOD.CN
	nvram set ddns_username_x=$DDNS_NAME
	nvram set ddns_passwd_x=$DDNS_PASS
	nvram set ddns_hostname_x=$DDNS_HOST
	nvram set ddns_hostname2_x=$DDNS_HOST2
fi

if [ "$lan_ip" = "1" ] && [ "$HOST" != "ROUTER" ]; then
	# FW
	nvram set https_wopen=1
	nvram set trmd_ropen=1
	nvram set aria_ropen=1
	nvram set sshd_wopen=1
	nvram set https_wport=81

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
nvram set computer_name=`echo ${HOST::1} | tr  '[a-z]' '[A-Z]'``echo ${HOST:1} | tr  '[A-Z]' '[a-z]'`
nvram set http_passwd=$ADMIN_PASS
if [ "$HOST" != "ROUTER" ]; then
	nvram set http_proto=2
	nvram set https_lport=8$lan_ip
fi

nvram commit
#sleep 2
#reboot
exit
