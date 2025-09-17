#!/bin/bash
set -e

echo "[*] Flushing old iptables rules..."
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X

echo "[*] Setting up NAT forwarding..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

echo "[*] Redirecting HTTP/HTTPS traffic to local server..."
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:80
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j DNAT --to-destination 192.168.4.1:443

echo "[*] Saving iptables rules..."
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4

echo " iptables rules applied successfully!"
