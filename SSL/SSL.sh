#!/bin/sh
cd "${0%/*}"

# https://github.com/Neilpang/acme.sh/tree/master/dnsapi#2-use-dnspodcn-domain-api-to-automatically-issue-cert
#curl https://get.acme.sh | sh
#source ~/.bashrc

#!!!先停止 CNAME *
DP_Id=162986 DP_Key=e452aaab5e7ff709ff2f16c7be8e009d ~/.acme.sh/acme.sh --issue --dns dns_dp -d yonsm.gq -d \*.yonsm.gq -d yonsm.tk -d \*.yonsm.tk

#Renew
~/.acme.sh/acme.sh --renew -d yonsm.gq -d \*.yonsm.gq -d yonsm.tk -d \*.yonsm.tk

yonsm.gq,www.yonsm.gq,router.yonsm.gq,router2.yonsm.gq,router3.yonsm.gq,station.yonsm.gq,hass.yonsm.gq,test.yonsm.gq,none.yonsm.gq,a.yonsm.gq,b.yonsm.gq,c.yonsm.gq,x.yonsm.gq,y.yonsm.gq,z.yonsm.gq

cd ~/.acme.sh/yonsm.gq

# HomeAssistant
scp fullchain.pem root@hass.yonsm.tk:~/.homeassistant/
scp private.key root@hass.yonsm.tk:~/.homeassistant/

# Router

# Access

exit

# Merlin
cat a.yonsm.tk.crt ca.crt a.yonsm.tk.key > server.pem
scp server.pem a.yonsm.tk:/etc/server.pem

scp ca.crt a.yonsm.tk:/etc/cert.crt
scp a.yonsm.tk.crt a.yonsm.tk:/etc/cert.pem
scp a.yonsm.tk.key a.yonsm.tk:/etc/key.pem

ssh a.yonsm.tk

nvram set https_crt_save=0
nvram unset https_crt_file
service restart_httpd
nvram get https_crt_file
nvram set https_crt_save=1
nvram get https_crt_save
service restart_httpd
sleep 1
nvram get https_crt_file
nvram commit
