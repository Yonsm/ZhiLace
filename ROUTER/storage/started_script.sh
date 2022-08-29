#!/bin/sh
sync && echo 3 > /proc/sys/vm/drop_caches

mdev -s

wing start socks5:192.168.1.8
ipset add gfwlist 91.108.56.0/22
ipset add gfwlist 91.108.4.0/22
ipset add gfwlist 109.239.140.0/24
ipset add gfwlist 149.154.160.0/20
