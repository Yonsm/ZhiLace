#!/bin/sh
cd "${0%/*}"
if [ -z $1 ]; then HOST=Router; else HOST=$1; fi

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

# SSH
scp ../SSH/authorized_keys $HOST:/etc/storage/
ssh $HOST "chmod 600 /etc/storage/authorized_keys; [ ! -d ~/.ssh ] && mkdir ~/.ssh; cp /etc/storage/authorized_keys ~/.ssh"

# SSL
ssh $HOST "[ ! -d /etc/storage/https ] && mkdir /etc/storage/https"
scp ../SSL/yonsm.tk/ca.crt $HOST:/etc/storage/https/
scp ../SSL/yonsm.tk/fullchain.pem $HOST:/etc/storage/https/server.crt
scp ../SSL/yonsm.tk/private.key $HOST:/etc/storage/https/server.key

# FILES
echo '#!/bin/sh\nsync && echo 3 > /proc/sys/vm/drop_caches' > storage/started_script.sh
if [ "$HOST" = "Router" ] || [ "$HOST" = "router" ]; then
	if [ "$HOST" = "Router" ]; then
		echo 'mdev -s\nwing 192.168.1.9 1080' >> storage/started_script.sh
	else
		echo 'wing 34.92.48.82 443 52488641' >> storage/started_script.sh
	fi
	echo '#!/bin/sh\nwing resume' > storage/post_iptables_script.sh
	copy_files storage
elif [ "$HOST" = "Router2" ] || [ "$HOST" = "router3" ]; then
	#echo 'iwpriv ra0 set KickStaRssiLow=-85\niwpriv ra0 set AssocReqRssiThres=-80' >> storage/started_script.sh
	echo 'iwpriv rai0 set KickStaRssiLow=-85\niwpriv rai0 set AssocReqRssiThres=-80' >> storage/started_script.sh
	scp storage/started_script.sh $HOST:/etc/storage/
fi

# NVRAM
scp nvram.sh $HOST:/tmp
if [ ! -z $2 ]; then IP=$2
elif [ "$HOST" = "router" ]; then IP=1
elif [ "$HOST" = "Router2" ] || [ "$HOST" = "router2" ]; then IP=2
elif [ "$HOST" = "Router3" ] || [ "$HOST" = "router3" ]; then IP=3
fi
ssh $HOST "/tmp/nvram.sh $IP"
