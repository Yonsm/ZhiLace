#!/bin/sh
cd "${0%/*}"

# https://github.com/Neilpang/acme.sh/tree/master/dnsapi#2-use-dnspodcn-domain-api-to-automatically-issue-cert
#curl https://get.acme.sh | sh
#source ~/.bashrc

#!!!先停止 CNAME *
DP_Id=49107 DP_Key=d03203ee7cd81a57a89e9bee2ae257e4 ~/.acme.sh/acme.sh --issue --dns dns_dp -d yonsm.gq -d \*.yonsm.gq -d yonsm.tk -d \*.yonsm.tk

#Renew
~/.acme.sh/acme.sh --renew -d yonsm.gq -d \*.yonsm.gq -d yonsm.tk -d \*.yonsm.tk

cd ~/.acme.sh/yonsm.gq

# HomeAssistant
scp fullchain.cer root@hassbian.yonsm.tk:~/.homeassistant/
scp yonsm.gq.key root@hassbian.yonsm.tk:~/.homeassistant/privkey.pem

# Router

# Access

exit

# Merlin
cat fullchain.cer yonsm.ga.key > server.pem
scp server.pem bridge:/etc/server.pem
scp fullchain.cer bridge:/etc/cert.pem
scp yonsm.ga.key bridge:/etc/key.pem

ssh bridge

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
