#!/bin/bash
  
# Author: MiAl
# Script home page: https://miloserdov.org/?p=1047
  
AIRCRACK_TIMEOUT=2 # given time to the aircrack-ng program to read the file. Time is specified in seconds
# If you have a very large file or a very slow system, increase this value
DIR=`date +"%Y-%m-%d"`
ISDIRCREATED=0
  
if [[ "$1" && -f "$1" ]]; then
    FILE="$1"
else
    echo 'Specify a (p)cap file from which you want to extract the handshakes.';
    echo 'Usage:';
    echo -e "\tbash handshakes_extractor.sh wpa.cap";
    exit 1
fi
  
while read -r "line" ; do
if [ "$(echo "$line" | grep 'WPA' | grep -E -v '(0 handshake)' | grep -E 'WPA \(' | awk -F '  ' '{print $3}')" ]; then
    if [ $ISDIRCREATED -eq 0 ]; then
        mkdir ./$DIR || (echo "It is not possible to create a directory for saving handshakes. Quitting." && exit 1)
        ISDIRCREATED=1
    fi
    ESSID="$(echo "$line" | grep 'WPA' | grep -E -v '(0 handshake)' | grep -E 'WPA \(' | awk -F '  ' '{print $3}')"
    BSSID="$(echo "$line" | grep 'WPA' | grep -E -v '(0 handshake)' | grep -E 'WPA \(' | awk -F '  ' '{print $2}')"
    echo -e "\033[0;32mFound a handshake for the network $ESSID ($BSSID). Saved to file $DIR/\033[1m$ESSID.pcap\e[0m"
    tshark -r $FILE -R "(wlan.fc.type_subtype == 0x08 || wlan.fc.type_subtype == 0x05 || eapol) && wlan.addr == $BSSID" -2 2>/dev/null
    tshark -r $FILE -R "(wlan.fc.type_subtype == 0x08 || wlan.fc.type_subtype == 0x05 || eapol) && wlan.addr == $BSSID" -2 -w ./$DIR/"$ESSID.pcap" -F pcap 2>/dev/null
fi
done < <(timeout $AIRCRACK_TIMEOUT aircrack-ng $FILE)
