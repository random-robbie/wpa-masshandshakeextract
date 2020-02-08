#!/bin/bash
for ip in `ls handshakes/*.pcap`; do
        timeout 10s bash handshakes.sh $ip
done
