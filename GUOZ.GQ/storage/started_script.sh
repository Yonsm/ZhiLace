#!/bin/sh
sync && echo 3 > /proc/sys/vm/drop_caches

wing start trojan://Asdftr99@45.77.146.204

nginx.sh
