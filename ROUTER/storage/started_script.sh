#!/bin/sh
sync && echo 3 > /proc/sys/vm/drop_caches

mdev -s

wing start socks5:192.168.1.8