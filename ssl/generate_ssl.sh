#!/bin/bash
# سكريبت إنشاء شهادات SSL للتجارب والاختبار

set -e

echo "🛡️  إنشاء شهادات SSL لـ Hotspot 2.0"

# إنشاء مجلد SSL إذا لم يكن موجوداً
mkdir -p ssl
cd ssl

# مسح الشهادات القديمة إذا وجدت
rm -f osu.key osu.crt osu.csr

echo " إنشاء المفتاح الخاص..."
openssl genrsa -out osu.key 2048

echo " إنشاء طلب التوقيع (CSR)..."
openssl req -new -key osu.key -out osu.csr -subj "/C=EG/ST=Cairo/L=Cairo/O=Shop Welcome/CN=192.168.4.1"

echo " إنشاء الشهادة الذاتية (Self-Signed)..."
openssl x509 -req -days 365 -in osu.csr -signkey osu.key -out osu.crt

echo " التحقق من الشهادة..."
openssl x509 -in osu.crt -text -noout

echo " إنشاء معلومات الشهادة..."
cat > certificate_info.txt << EOF
معلومات الشهادة:
- النوع: Self-Signed Certificate
- الصلاحية: 365 يوم
- الخوارزمية: RSA 2048-bit
- الاستخدام: OSU Server - Hotspot 2.0
- النطاق: 192.168.4.1
- التاريخ: $(date)
EOF

echo " تم إنشاء الشهادات بنجاح!"
echo ""
echo " الملفات المنشأة:"
echo "    osu.key    - المفتاح الخاص"
echo "   osu.crt    - الشهادة العامة" 
echo "    osu.csr    - طلب التوقيع"
echo "    certificate_info.txt - معلومات الشهادة"
echo ""
echo "  ملاحظة: هذه شهادة ذاتية للتجارب فقط"
echo "   للإنتاج استخدم شهادة من جهة موثوقة مثل Let's Encrypt"