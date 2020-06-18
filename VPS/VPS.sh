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

# Trojan
apt-get install psmisc
cd /etc/init.d
cat <<\EOF > trojan

#!/bin/sh
### BEGIN INIT INFO
# Provides:          trojan
# Required-start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the trojan daemon
# Description:       starts trojan using start-stop-daemon
### END INIT INFO

case "$1" in
    start)
        echo "Starting trojan daemon..."
        nohup /opt/trojan/trojan -c /opt/trojan/config.json &> /opt/trojan/trojan.log &
        ;;
    stop)
        echo "Stop trojan daemon..."
        killall trojan
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start $2
        ;;
    *)
        $0 start $1
        ;;
esac
EOF
cd /etc/init.d
chmod 755 trojan
update-rc.d trojan defaults 95
