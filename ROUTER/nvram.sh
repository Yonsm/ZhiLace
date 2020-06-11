#!/bin/sh

if [ -z $1 ] || [ "$1" = "1" ]; then
	LAN_IP=1
	computer_name=Router
else
	LAN_IP=$1
	computer_name=Router$1
fi

if [ "$1" = "1" ]; then
	http_proto=0
	lan_domain=yonsm
else
	http_proto=2
	lan_domain=yonsm.tk
fi


NVRAMS="
computer_name=$computer_name
http_passwd=gjzgqz
http_proto=$http_proto
https_lport=8$lan_ip

lan_ipaddr=192.168.1.$lan_ip
dhcp_start=192.168.1.70
dhcp_end=192.168.1.99
lan_domain=$lan_domain

rt_ssid=Router
rt_ssid2=Router
rt_guest_ssid=Guest
wl_ssid=Router5
wl_ssid2=Router5
wl_guest_ssid=Guest
rt_wpa_psk=asdfqwer
wl_wpa_psk=asdfqwer
"

if [ -z $1 ]; then
	NVRAMS="$NVRAMS
wan_proto=pppoe
wan_pppoe_username=057101258602
wan_pppoe_passwd=08065222

vts_enable_x=1
vts_num_x=4
vts_desc_x0=DSM
vts_port_x0=5001
vts_proto_x0=TCP
vts_ipaddr_x0=192.168.1.4
vts_desc_x1=HASS
vts_port_x1=8123
vts_proto_x1=TCP
vts_ipaddr_x1=192.168.1.9
vts_desc_x2=SSH
vts_port_x2=22
vts_proto_x2=TCP
vts_ipaddr_x2=192.168.1.9
vts_desc_x3=VNC
vts_port_x3=5900
vts_proto_x3=TCP
vts_ipaddr_x3=192.168.1.10

udpxy_enable_x=4000
viptv_mode=$viptv_mode
vlan_vid_iptv=9
vlan_vid_lan4=9
viptv_ipaddr=10.198.137.188
viptv_netmask=255.255.192.0
viptv_gateway=10.198.128.1

ddns_server_x=CUSTOM
ddns_cst_url=/dyndns/update?system=dyndns&hostname=
ddns_cst_svr=members.3322.net
ddns_username_x=yonsmguo
ddns_passwd_x=Gzczqu30
ddns_hostname_x=yonsm.f3322.net

https_wopen=1
ftpd_wopen=1
udpxy_wopen=1
trmd_ropen=1
aria_ropen=1

enable_samba=1
enable_ftp=1
trmd_enable=1
aria_enable=1
acc_username0=admin
acc_password0=gjzgqz
"
else
	NVRAMS="$NVRAMS
wan_proto=dhcp
"
fi

if [ "$1" = "1" ]; then
	NVRAMS="$NVRAMS
wl_mode_x=3
wl_sta_wisp=1
wl_sta_ssid=alibaba-guest
wl_channel=157
wl_sta_auto=1
"
fi

for NVRAM in $NVRAMS
do
	nvram set $NVRAM
done
nvram commit
reboot

