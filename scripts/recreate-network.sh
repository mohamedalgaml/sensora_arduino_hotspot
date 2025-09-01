#!/usr/bin/env bash
set -euo pipefail

sudo ip link add br-osu type bridge 2>/dev/null || true
sudo ip addr add 192.168.60.1/24 dev br-osu 2>/dev/null || true
sudo ip link set br-osu up

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -C FORWARD -i br-osu -o eth0 -j ACCEPT 2>/dev/null || sudo iptables -A FORWARD -i br-osu -o eth0 -j ACCEPT
sudo iptables -C FORWARD -i eth0 -o br-osu -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || sudo iptables -A FORWARD -i eth0 -o br-osu -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

sudo systemctl restart dnsmasq

sudo ip link set wlan0 down; sudo iw dev wlan0 set type __ap; sudo ip link set wlan0 up
sudo ip link set wlan2 down; sudo iw dev wlan2 set type __ap; sudo ip link set wlan2 up
sudo hostapd -B -t /etc/hostapd/hostapd-main.conf /etc/hostapd/hostapd-osu.conf
