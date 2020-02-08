#!/bin/bash
for ip in `ls *.pcap`; do
        timeout 10s bash handshakes.sh $ip
done
