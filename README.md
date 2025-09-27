# HS2.0 / OSU Pack
- Configs:
  - /etc/hostapd/hostapd-main.conf
  - /etc/hostapd/hostapd-osu.conf
  - /etc/dnsmasq.conf
  - /etc/dnsmasq.d/osu.conf
  - /etc/wpa_supplicant/interworking.conf (+ osu-client.conf if present)
- Backups:
  - backups/dnsmasq-backup* (before modifications)
  - backups/iptables-rules.txt
  - backups/system-versions.txt, ip-addr.txt, ip-route.txt
- Script:
  - scripts/recreate-network.sh to restart bridge/NAT/hostapd quickly.
 🌐 Hotspot 2.0 (Passpoint) Captive Portal with OSU – Raspberry Pi

هذا المشروع يوفّر نظام **Hotspot 2.0 / Passpoint** مع دعم **Online Sign-Up (OSU)** باستخدام Raspberry Pi.  
النظام يوفّر واي فاي آمن مع صفحة تسجيل دخول (Captive Portal) ودعم الشهادات **SSL**.

---

## 📁 محتويات المشروع

- `install.sh` → سكربت إعداد تلقائي لكل المكونات (WiFi, DHCP, Firewall, Captive Portal).  
- `hostapd.conf` → إعدادات نقطة الوصول (SSID + Hotspot 2.0 + OSU).  
- `dnsmasq.conf` → إعدادات DHCP/DNS مع دعم Captive Portal Detection (Apple/Android/MS).  
- `iptables-rules.sh` → إعداد الجدار الناري وتحويل الطلبات (HTTP/HTTPS → Captive Portal).  
- `www/` → ملفات صفحة Captive Portal + OSU (signup.html + terms.html + assets).  
- `ssl/` → شهادات SSL وسكريبتات التوليد (`generate_ssl.sh`, `osu.key`, `osu.crt`).  

---

##  التثبيت والاستخدام

### 1️⃣ نسخ المشروع
```bash
git clone https://github.com/mohamedalgaml/sensora_arduino_hotspot.git
cd sensora_arduino_hotspot
2️ إعداد الشهادات (SSL)
للتجارب:

cd ssl
chmod +x generate_ssl.sh
./generate_ssl.sh
للإنتاج → استخدم شهادة من Let's Encrypt (generate_ssl_letsencrypt.sh) مع دومين حقيقي.

 تشغيل سكربت التثبيت

chmod +x install.sh
sudo ./install.sh
 التحقق من التشغيل
اسم الشبكة (SSID): Shop_Welcome_OSU

كلمة المرور: SecurePass123!@#

صفحة الدخول: http://192.168.4.1

OSU Server: https://192.168.4.1/osu/

 الحماية والأمان
SSL إلزامي: كل صفحات OSU تعمل عبر HTTPS.

iptables: يسمح فقط بتمرير حركة المرور المصرح بها.

Freeradius: متكامل لدعم المصادقة المركزية.

 إدارة النظام
التحقق من الخدمة:


sudo systemctl status hostapd
sudo systemctl status dnsmasq
sudo systemctl status freeradius
sudo systemctl status apache2
مراقبة السجلات:

sudo journalctl -u hostapd -f
sudo tail -f /var/log/syslog
تشغيل يدوي:


sudo ./start.sh   # تشغيل كل الخدمات
sudo ./stop.sh    # إيقاف كل الخدمات
 ملاحظات مهمة
التكوين الحالي للتجارب المحلية فقط (IP: 192.168.4.1).

للإنتاج يجب:

شراء دومين وربطه مع الجهاز.

توليد شهادات SSL موثوقة (Let's Encrypt).

إعداد OSU URI ليشير للدومين العام.

 المطور
المشروع: Hotspot 2.0 / OSU

المطور: Mohamed Al Gaml

 البريد: mo37533393@gmail.com.com

