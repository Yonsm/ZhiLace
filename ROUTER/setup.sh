#!/bin/sh
cd "${0%/*}"

# Router: Main Router (XY-C1)
# Router2/Router3: WIFI AP (K2P)
# ROUTER: Office Router (NEWIFI-MINI)
# router: Friends' Router (NEWIFI3)
if [ -z $1 ]; then HOST=Router; else HOST=$1; fi
if [ -z $2 ]; then NAME=$HOST; else NAME=$2; fi

if [ "$NAME" = "Router" ]; then
	WING_HOST=192.168.1.8
	WING_PASS=
elif [ "$NAME" = "router" ] ||  [ "$NAME" = "ROUTER" ]; then
	WING_HOST=yonsm.cf
	WING_PASS=" Asdftr99"
fi

# SSH
scp ../SSH/authorized_keys $HOST:/etc/storage/ || (echo "Usage: $0 [HOST] [NAME] [SSID]"; exit 1)
ssh $HOST "chmod 600 /etc/storage/authorized_keys; [ ! -d ~/.ssh ] && mkdir ~/.ssh; cp /etc/storage/authorized_keys ~/.ssh"

# SSL
ssh $HOST "[ ! -d /etc/storage/https ] && mkdir /etc/storage/https"
scp ../SSL/yonsm.tk/ca.crt $HOST:/etc/storage/https/
scp ../SSL/yonsm.tk/fullchain.pem $HOST:/etc/storage/https/server.crt
scp ../SSL/yonsm.tk/private.key $HOST:/etc/storage/https/server.key


copy_files()
{
	for FILE in `ls -F $1`
	do
		if [ "${FILE: -1}" = "/" ]; then
			ssh $HOST "[ ! -d /etc/$1/${FILE%?} ] && mkdir /etc/$1/${FILE%?}"
			copy_files $1/${FILE%?}
		else
			[ "${FILE: -1}" = "*" ] && FILE=${FILE%?}
			scp $1/$FILE $HOST:/etc/$1/$FILE
		fi
	done
}

# FILES
if [ "$NAME" = "ROUTER" ] || [ "$NAME" = "Router" ] || [ "$NAME" = "router" ]; then
	echo '#!/bin/sh\nsync && echo 3 > /proc/sys/vm/drop_caches' > storage/started_script.sh
	echo '#!/bin/sh' > storage/post_iptables_script.sh
	if [ "$NAME" = "Router" ]; then
		echo "mdev -s" >> storage/started_script.sh
	fi
	if [ ! -z "$WING_HOST" ]; then
		echo "wing $WING_HOST$WING_PASS" >> storage/started_script.sh
		echo "wing resume" >> storage/post_iptables_script.sh
	fi
	# Copy https/dnsmasq/scripts to storage
	if [ "$NAME" = "router" ]; then
		ssh $HOST "[ ! -d /etc/storage/dnsmasq/ ] && mkdir /etc/storage/dnsmasq/"
		scp storage/started_script.sh $HOST:/etc/storage/
		scp storage/post_iptables_script.sh $HOST:/etc/storage/
		scp storage/dnsmasq/dnsmasq.conf $HOST:/etc/storage/dnsmasq/
	else
		copy_files storage
	fi
elif [ "$NAME" = "Router2" ] || [ "$NAME" = "Router3" ]; then
	#echo 'iwpriv ra0 set KickStaRssiLow=-85\niwpriv ra0 set AssocReqRssiThres=-80' >> storage/started_script.sh
	echo 'iwpriv rai0 set KickStaRssiLow=-85\niwpriv rai0 set AssocReqRssiThres=-80' >> storage/started_script.sh
	scp storage/started_script.sh $HOST:/etc/storage/
fi

# NVRAM
scp nvram.sh $HOST:/tmp
ssh $HOST "/tmp/nvram.sh $NAME $3"
