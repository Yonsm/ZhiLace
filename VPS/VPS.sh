#!/bin/sh

if [ "$1" == "VPS" ]; then
    sudo su

    echo -e "Asdftr30\nAsdftr30" | passwd
    mkdir ~/.ssh/
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgPSpcJ6yIHpbOSy9/YPs8CRIWzIHqi3xkzJ5Vb6Z/oH1eo5wFLps6uOL2EnljOkd0gKRMF5YzN5ahiCTrU65X2+RllYXHful9SNiWbRvg96Ciz0u7UsI0SB8OOZvMVPMLaAXtD7p/UsJdYonzswwPP2RCc7x8MPtKQlfakf2zhB6fYULEadh6p42RPmZ23+Xniotti+MxOyh1m24naM30VrXpvMfL4oRmE29J3Ry7pPdMDanp7T/3Iixix9F/D8bIl4ly5fn5jbBnFSyg0Yg1FJU1nECqc3Pnw9d3CxAB0KiTUoAx0Cn90m+8jXW3aiXDN3FtXeU2RCoyoLF5rCj9 YONSM@QQ.COM' > ~/.ssh/authorized_keys

    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
    systemctl restart sshd
fi

if [ $# != 2 ]; then
	echo "Usage: $0 <HOST> <NEW_PASS>"
	exit
fi

echo "PUT SSH KEY"
ssh root@$1 "mkdir ~/.ssh/"
scp ~/.ssh/authorized_keys root@$1:~/.ssh/

#echo "SET SSH PORT"
#ssh -p $2 root@v "sed -i 's/Port $2/Port 22/g' /etc/ssh/sshd_config"
#ssh -p $2 root@v "service sshd restart"

echo "SET PASSWORD"
ssh root@$1 "echo $2 | passwd --stdin root"
ssh root@$1

exit 0

#
echo 'Asia/Shanghai' > /etc/timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#
# echo "00 5 * * * root init 6" >> /etc/crontab
# crontab -e
# /etc/init.d/cron restart

exit 1

# HTTP
#chkconfig --levels 235 httpd on
#/etc/init.d/httpd start

# V2Ray: https://toutyrater.github.io/
# https://github.com/233boy/v2ray
# https://233blog.com/
# bash <(curl -s -L https://git.io/v2ray.sh)
# cat <<EOF > /etc/v2ray/config.json
# {
#     "log": {
#         "access": "/var/log/v2ray/access.log",
#         "error": "/var/log/v2ray/error.log",
#         "loglevel": "warning"
#     },
#     "inbound": {
#         "port": 62223,
#         "protocol": "vmess",
#         "settings": {
#             "udp": true,
#             "clients": [
#                 {
#                     "id": "3f9f18d6-9adc-49fc-a281-c5e9e2ce9f4f",
#                     "level": 1,
#                     "alterId": 233
#                 }
#             ]
#         },
#         "streamSettings": {
#             "network": "kcp",
#             "kcpSettings": {
#                 "mtu": 1350,
#                 "tti": 50,
#                 "uplinkCapacity": 100,
#                 "downlinkCapacity": 100,
#                 "congestion": false,
#                 "readBufferSize": 2,
#                 "writeBufferSize": 2,
#                 "header": {
#                     "type": "utp"
#                 }
#             }
#         }
#     },
#     "outbound": {
#         "protocol": "freedom",
#         "settings": {}
#     },
#     "outboundDetour": [
#         {
#             "protocol": "blackhole",
#             "settings": {},
#             "tag": "blocked"
#         }
#     ],
#     "routing": {
#         "strategy": "rules",
#         "settings": {
#             "rules": [
#                 {
#                     "type": "field",
#                     "ip": [
#                         "0.0.0.0/8",
#                         "10.0.0.0/8",
#                         "100.64.0.0/10",
#                         "127.0.0.0/8",
#                         "169.254.0.0/16",
#                         "172.16.0.0/12",
#                         "192.0.0.0/24",
#                         "192.0.2.0/24",
#                         "192.168.0.0/16",
#                         "198.18.0.0/15",
#                         "198.51.100.0/24",
#                         "203.0.113.0/24",
#                         "::1/128",
#                         "fc00::/7",
#                         "fe80::/10"
#                     ],
#                     "outboundTag": "blocked"
#                 }
#             ]
#         }
#     }
# }
# EOF

# Trojan
cd /opt
curl -L -o trojan.tar.xz https://github.com/trojan-gfw/trojan/releases/latest/download/trojan-1.16.0-linux-amd64.tar.xz
tar -xf trojan.tar.xz
cd trojan
rm -rf *.md LICENSE examples ../trojan.tar.xz
cat <<\EOF > config.json
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "Asdftr99"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "/opt/trojan/ssl.crt",
        "key": "/opt/trojan/ssl.key",
        "key_password": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 81
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF

#apt install psmisc

cd /etc/init.d
cat <<\EOF > trojan
#!/bin/sh
### BEGIN INIT INFO
# Provides:          trojan
# Required-Start:   $remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:    2 3 4 5
# Default-Stop:     
# Short-Description: starts the trojan daemon
# Description:       starts trojan using start-stop-daemon
### END INIT INFO

case "$1" in
    start)
        echo "Starting trojan daemon..."
        /opt/trojan/trojan -c /opt/trojan/config.json &
        ;;
    stop)
        echo "Stop trojan daemon..."
        killall trojan
        ;;
    reload|restart)
        $0 stop
        sleep 1
        $0 start $2
        ;;
    status)
        ps ax | grep trojan
        ;;
    *)
        $0 start $1
        ;;
esac
EOF
cd /etc/init.d
chmod 755 trojan
update-rc.d trojan defaults 95

scp ~/Sites/Yonsm/SSL/v.your.gq.key v.your.gq:/opt/trojan/ssl.key
scp ~/Sites/Yonsm/SSL/v.your.gq.crt v.your.gq:/opt/trojan/ssl.crt


# Nanling VPS
ssh -p27993 98.142.139.175 # 2O1ovKHW7AL6
cat <<\EOF > /etc/profile.d/trojan.sh
#!/bin/sh
/opt/trojan/trojan -c /opt/trojan/config.json &
EOF
chmod +x /etc/profile.d/trojan.sh

#
ssh root@45.77.146.204 # L8r,ok?U+8E_243!
