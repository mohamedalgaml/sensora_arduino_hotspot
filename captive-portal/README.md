# 🛜 مشروع Captive Portal

مشروع كامل لإنشاء شبكة واي فاي مع بوابة تسجيل دخول تلقائية (Captive Portal) على Raspberry Pi.

![Captive Portal](https://img.shields.io/badge/Status-Ready-green.svg)
![Raspberry Pi](https://img.shields.io/badge/Platform-Raspberry%20Pi-red.svg)
![WiFi](https://img.shields.io/badge/WiFi-Hotspot%202.0-blue.svg)

---

## ✨ المميزات
- إنشاء نقطة وصول لاسلكية (WiFi Access Point)  
- إشعار اتصال تلقائي على الأجهزة (Captive Portal)  
- إعادة توجيه تلقائي لصفحة الترحيب  
- دعم Hotspot 2.0 (لأحدث الأجهزة)  
- واجهة مستخدم عربية متجاوبة  
- إعدادات أمان متقدمة (WPA2)  

---

## 📂 هيكل المشروع
sensora_arduino_hotspot/
│── captive-portal/
│ ├── captive.html ← صفحة البوابة (Landing Page)
│ ├── dnsmasq.conf ← إعداد DHCP + DNS
│ ├── hostapd.conf ← إعداد شبكة الـ Wi-Fi
│ ├── install.sh ← سكربت التنصيب والتشغيل
│ ├── iptables-rules.sh← سكربت تفعيل NAT (اختياري)
│ └── README.md ← هذا الملف

yaml
نسخ الكود

---

## ⚙️ المكونات المطلوبة
- جهاز **Raspberry Pi** (أو أي جهاز Linux مع كارت Wi-Fi يدعم وضع AP).  
- نظام تشغيل **Debian / Raspberry Pi OS / Kali Linux**.  
- حزم مثبتة تلقائيًا:
  - `hostapd` لإنشاء شبكة واي فاي  
  - `dnsmasq` لتوزيع عناوين IP + DNS  
  - `apache2` أو أي Web Server لعرض صفحة البوابة  
  - (اختياري) `freeradius` لو محتاج مصادقة متقدمة  

---

## 🚀 خطوات التشغيل

### 1️⃣ تثبيت المشروع
```bash
chmod +x install.sh
sudo ./install.sh
2️⃣ إعداد IP ثابت لواجهة Wi-Fi
bash
sudo bash -c 'cat >> /etc/dhcpcd.conf << EOF
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
EOF'
sudo systemctl restart dhcpcd
3️⃣ تفعيل NAT (مشاركة الإنترنت مع العملاء)
bash
sudo ./iptables-rules.sh
4️⃣ إعادة تشغيل الخدمات يدويًا (لو لزم)

bash
sudo systemctl restart hostapd
sudo systemctl restart dnsmasq
sudo systemctl restart apache2