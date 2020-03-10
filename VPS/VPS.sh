#!/bin/sh

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
echo "00 5 * * * root init 6" >> /etc/crontab
crontab -e
/etc/init.d/cron restart

exit 1

# HTTP
chkconfig --levels 235 httpd on
#/etc/init.d/httpd start

touch /var/fdid.log
touch /var/flak.log
chmod 666 /var/fdid.log
chmod 666 /var/flak.log

# SS: https://teddysun.com/486.html
cd /opt
wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
chmod +x shadowsocks-all.sh
./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log

cat <<EOF > /etc/shadowsocks-libev/config.json
{
    "server":"0.0.0.0",
    "server_port":20,
    "password":"Asdfss20",
    "timeout":300,
    "user":"nobody",
    "method":"chacha20-ietf-poly1305",
    "fast_open":false,
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http"
}
EOF

/etc/init.d/shadowsocks-libev restart

# MAC: https://medium.com/@yanlong/macos%E4%BD%BF%E7%94%A8shadowsocks-libev-simple-obfs%E6%95%99%E7%A8%8B-c10eba9c0758
brew install shadowsocks-libev
brew install simple-obfs
cat <<EOF > /usr/local/etc/shadowsocks-libev.json
{
    "server":"v.yonsm.ga",
    "server_port":20,
    "local_port":1080,
    "password":"Asdfss20",
    "method":"chacha20-ietf-poly1305",
    "mode":"tcp_and_udp",
    "plugin": "obfs-local",
    "plugin_opts": "obfs=http;obfs-host=www.bing.com"
}

EOF

cat <<EOF > /Users/Yonsm/Library/Application\ Support/ShadowsocksX-NG/ss-local-config.json
{
    "server":"v.yonsm.ga",
    "server_port":20,
    "local_port":1086,
    "password":"Asdfss20",
    "method":"chacha20-ietf-poly1305",
    "mode":"tcp_and_udp",
    "plugin": "obfs-local",
    "plugin_opts": "obfs=http;obfs-host=www.bing.com"
}

EOF

# BBR
# https://www.bandwagonhost.net/1082.html
wget https://raw.githubusercontent.com/kuoruan/shell-scripts/master/ovz-bbr/ovz-bbr-installer.sh
chmod +x ovz-bbr-installer.sh
./ovz-bbr-installer.sh

# KCPTUN
echo "INSTALL KCP"
wget --no-check-certificate https://github.com/kuoruan/shell-scripts/raw/master/kcptun/kcptun.sh
chmod +x ./kcptun.sh
./kcptun.sh

cat <<EOF > /usr/local/kcptun/server-config.json
{
    "listen": ":21",
    "target": "127.0.0.1:20",
    "key":"Asdfkc21"
}

EOF


#yum update

# V2Ray: https://toutyrater.github.io/
# https://github.com/233boy/v2ray
# https://233blog.com/
bash <(curl -s -L https://git.io/v2ray.sh)
cat <<EOF > /etc/v2ray/config.json
{
    "log": {
        "access": "/var/log/v2ray/access.log",
        "error": "/var/log/v2ray/error.log",
        "loglevel": "warning"
    },
    "inbound": {
        "port": 62223,
        "protocol": "vmess",
        "settings": {
            "udp": true,
            "clients": [
                {
                    "id": "3f9f18d6-9adc-49fc-a281-c5e9e2ce9f4f",
                    "level": 1,
                    "alterId": 233
                }
            ]
        },
        "streamSettings": {
            "network": "kcp",
            "kcpSettings": {
                "mtu": 1350,
                "tti": 50,
                "uplinkCapacity": 100,
                "downlinkCapacity": 100,
                "congestion": false,
                "readBufferSize": 2,
                "writeBufferSize": 2,
                "header": {
                    "type": "utp"
                }
            }
        }
    },
    "outbound": {
        "protocol": "freedom",
        "settings": {}
    },
    "outboundDetour": [
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
    "routing": {
        "strategy": "rules",
        "settings": {
            "rules": [
                {
                    "type": "field",
                    "ip": [
                        "0.0.0.0/8",
                        "10.0.0.0/8",
                        "100.64.0.0/10",
                        "127.0.0.0/8",
                        "169.254.0.0/16",
                        "172.16.0.0/12",
                        "192.0.0.0/24",
                        "192.0.2.0/24",
                        "192.168.0.0/16",
                        "198.18.0.0/15",
                        "198.51.100.0/24",
                        "203.0.113.0/24",
                        "::1/128",
                        "fc00::/7",
                        "fe80::/10"
                    ],
                    "outboundTag": "blocked"
                }
            ]
        }
    }
}
EOF
