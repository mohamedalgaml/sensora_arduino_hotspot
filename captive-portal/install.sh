#!/bin/bash
# install.sh - Captive Portal Setup Script

set -e

echo "[*] Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "[*] Installing required packages..."
sudo apt install -y hostapd dnsmasq freeradius apache2 iptables-persistent

echo "[*] Stopping services for configuration..."
sudo systemctl stop hostapd || true
sudo systemctl stop dnsmasq || true
sudo systemctl stop freeradius || true
sudo systemctl stop apache2 || true

echo "[*] Copying configuration files..."
# hostapd config
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo sed -i 's|#DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

# dnsmasq config
sudo cp dnsmasq.conf /etc/dnsmasq.conf

# freeradius config
if [ -f freeradius/clients.conf ]; then
  sudo cp freeradius/clients.conf /etc/freeradius/3.0/clients.conf
fi

# captive portal web page
if [ -d www ]; then
  sudo mkdir -p /var/www/html/captive
  sudo cp -r www/* /var/www/html/captive/
fi

echo "[*] Setting static IP for wlan0..."
sudo bash -c 'cat > /etc/dhcpcd.conf << EOF
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
EOF'
sudo systemctl restart dhcpcd || true

echo "[*] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

echo "[*] Applying iptables rules..."
if [ -f iptables-rules.sh ]; then
    chmod +x iptables-rules.sh
    sudo ./iptables-rules.sh
else
    echo "[!] iptables-rules.sh not found, applying default rules..."
    sudo iptables -t nat -F
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
    sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:80
    sudo sh -c "iptables-save > /etc/iptables/rules.v4"
fi

echo "[*] Restarting services..."
sudo systemctl restart hostapd
sudo systemctl restart dnsmasq
sudo systemctl restart freeradius
sudo systemctl restart apache2

echo "[*] Enabling services on boot..."
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl enable freeradius
sudo systemctl enable apache2

echo "Captive Portal setup complete!"
