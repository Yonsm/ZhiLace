#!/bin/sh
echo -e "Content-type: text/plain\n"
#QUERY_STRING=1234567890AB
TIME=$(date "+%Y-%m-%d_%H:%M:%S")

if [[ "$HTTP_USER_AGENT" =~ "Flak" ]]; then
KEY="dataWithContentsOfFile:"
echo "$TIME $QUERY_STRING $REMOTE_ADDR" >> /var/flak.log
else
KEY="athenaMessageBodyForPlaintext:"
echo "$TIME $QUERY_STRING $REMOTE_ADDR" >> /var/fdid.log
fi

function encrypt
{
	STR1=$1
	STR2=$2
	MAGIC=$3
	let SEQ1=1
	for SEQ2 in $( seq 1 ${#STR2} )
	do
		let IDX1=SEQ1-1
		let IDX2=SEQ2-1
		ASC1=$(printf "%d" "'${STR1:IDX1:1}")
		ASC2=$(printf "%d" "'${STR2:IDX2:1}")
		let RET=$ASC1^$ASC2
		let RET=$RET^$MAGIC
		printf "%02X" "$RET"
		#echo "${STR1:IDX1:1}^${STR2:IDX2:1}=$RET"

		if [ $SEQ1 -lt ${#STR1} ]; then
			let SEQ1+=1
		else
			let SEQ1=1
		fi
	done
}

if [ ${#QUERY_STRING} == 12 ]; then
	let MAGIC=$RANDOM%256
	printf "TCKT:%02X" "$MAGIC"
	encrypt "$QUERY_STRING" "$KEY" $MAGIC
else
	echo "$QUERY_STRING"
fi
