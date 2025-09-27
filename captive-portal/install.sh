#!/bin/bash
# install.sh - Captive Portal Setup Script with SSL Support

set -e

echo "  Starting Captive Portal + Hotspot 2.0 Installation..."

echo "[*] Checking required files..."
if [ ! -f hostapd.conf ] || [ ! -f dnsmasq.conf ]; then
    echo "[ERROR] Required configuration files missing!"
    exit 1
fi

echo "[*] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "[*] Installing required packages..."
sudo apt install -y hostapd dnsmasq freeradius apache2 iptables-persistent openssl

echo "[*] Stopping services for configuration..."
sudo systemctl stop hostapd || true
sudo systemctl stop dnsmasq || true
sudo systemctl stop freeradius || true
sudo systemctl stop apache2 || true

echo "[*] Copying configuration files..."
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo sed -i 's|#DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

sudo cp dnsmasq.conf /etc/dnsmasq.conf

if [ -f freeradius/clients.conf ]; then
  sudo cp freeradius/clients.conf /etc/freeradius/3.0/clients.conf
fi

if [ -d www ]; then
  sudo mkdir -p /var/www/html/captive
  sudo cp -r www/* /var/www/html/captive/
fi

echo "[*] Configuring network interface..."
sudo bash -c 'cat > /etc/dhcpcd.conf << EOF
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
EOF'
sudo systemctl restart dhcpcd || true

echo "[*] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

echo "[*] Configuring firewall rules..."
if [ -f iptables-rules.sh ]; then
    chmod +x iptables-rules.sh
    sudo ./iptables-rules.sh
else
    echo "[!] Using default iptables rules..."
    sudo iptables -t nat -F
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
    sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:80
    sudo sh -c "iptables-save > /etc/iptables/rules.v4"
fi

echo "[*] Setting up SSL certificates..."
SSL_DIR="/etc/ssl/osu"
sudo mkdir -p $SSL_DIR

if [ ! -f ssl/osu.crt ] || [ ! -f ssl/osu.key ]; then
    echo "[!] No existing SSL found, generating self-signed certificate..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $SSL_DIR/osu.key -out $SSL_DIR/osu.crt \
        -subj "/C=EG/ST=Cairo/L=Cairo/O=Hotspot/CN=192.168.4.1"
else
    echo "[*] Installing provided SSL certificates..."
    sudo cp ssl/osu.crt $SSL_DIR/
    sudo cp ssl/osu.key $SSL_DIR/
fi

echo "[*] Configuring Apache VirtualHost..."
SSL_CONF="/etc/apache2/sites-available/osu-portal.conf"
sudo bash -c "cat > $SSL_CONF" << EOF
<VirtualHost *:80>
    ServerName 192.168.4.1
    Redirect permanent / https://192.168.4.1/
</VirtualHost>

<VirtualHost *:443>
    ServerName 192.168.4.1

    DocumentRoot /var/www/html/captive

    SSLEngine on
    SSLCertificateFile $SSL_DIR/osu.crt
    SSLCertificateKeyFile $SSL_DIR/osu.key

    <Directory /var/www/html/captive>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2enmod ssl
sudo a2ensite osu-portal.conf
sudo systemctl reload apache2

echo "[*] Starting services..."
sudo systemctl unmask hostapd
sudo systemctl restart hostapd
sudo systemctl restart dnsmasq
sudo systemctl restart freeradius
sudo systemctl restart apache2

echo "[*] Enabling services on boot..."
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl enable freeradius
sudo systemctl enable apache2

echo "[*] Finalizing installation..."
sleep 2

echo " Captive Portal + Hotspot 2.0 installation completed successfully!"
echo ""
echo " WiFi Network: Shop_Welcome_OSU"
echo " Password: SecurePass123!@#"
echo " OSU Portal: https://192.168.4.1"
echo ""
echo " Useful commands:"
echo "   sudo systemctl status hostapd"
echo "   sudo journalctl -u hostapd -f"
