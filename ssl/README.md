 وثائق شهادات SSL لنظام Hotspot 2.0
مجلد الشهادات الأمنية لنظام OSU (Online Sign-Up) في بيئة Hotspot 2.0.
هذا المجلد يحتوي على جميع الملفات اللازمة لتأمين اتصالات HTTPS بين الأجهزة وخادم OSU، وهو مطلب أساسي لعمل نظام Hotspot 2.0 بشكل صحيح.

 هيكل الملفات
text
ssl/
├──  osu.crt                 # الشهادة العامة (Public Certificate)
├──  osu.key                 # المفتاح الخاص (Private Key) - ملف سري
├──  osu.csr                 # طلب توقيع الشهادة (CSR)
├──  generate_ssl.sh          # سكريبت إنشاء شهادات تجريبية
├──  generate_letsencrypt.sh # سكريبت شهادات إنتاجية (Let's Encrypt)
├──  certificate_info.txt    # معلومات تفصيلية عن الشهادة
└──  README.md               # هذه الوثائق
 لماذا SSL ضروري لـ Hotspot 2.0؟
الأمان والحماية
تشفير البيانات: منع اعتراض المعلومات الحساسة

مصادقة الخادم: التأكد من هوية مزود الخدمة

حماية الخصوصية: منع التطفل على اتصالات المستخدمين

متطلبات المعايير
Hotspot 2.0 يتطلب HTTPS للإتصال الآمن

المتصفحات الحديثة ترفض الاتصال بخوادم غير آمنة

أنظمة التشغيل تتحقق من صلاحية الشهادات تلقائياً

تجربة المستخدم
 بدون SSL: تحذيرات أمان واتصالات مرفوضة

 مع SSL: اتصال سلس وموثوق بدون عوائق

 بدء الاستخدام
 الخيار 1: للتطوير والاختبار (سريع)

# الانتقال إلى مجلد SSL
cd ssl

# منح صلاحيات التنفيذ
chmod +x generate_ssl.sh

# إنشاء الشهادات التجريبية
./generate_ssl.sh

# تثبيت الشهادات على النظام
sudo cp osu.crt /etc/ssl/certs/
sudo cp osu.key /etc/ssl/private/

# تأمين صلاحيات الملفات
sudo chmod 600 /etc/ssl/private/osu.key
sudo chmod 644 /etc/ssl/certs/osu.crt
 الخيار 2: للإنتاج (موثوق)
# يتطلب نطاقاً عاماً (مثل: hotspot.mydomain.com)
chmod +x generate_letsencrypt.sh

# إنشاء شهادة معتمدة من Let's Encrypt
./generate_letsencrypt.sh hotspot.mydomain.com admin@mydomain.com
 التهيئة على الخادم
إعداد Apache لاستخدام الشهادات
apache
<VirtualHost *:443>
    ServerName 192.168.4.1
    DocumentRoot /var/www/html/osu
    
    # إعدادات SSL
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/osu.crt
    SSLCertificateKeyFile /etc/ssl/private/osu.key
    
    # إعدادات أمان متقدمة
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    SSLHonorCipherOrder off
    SSLSessionTickets off
</VirtualHost>
تمكين SSL في Apache
bash
# تمكين وحدة SSL
sudo a2enmod ssl
sudo a2enmod headers

# تمكين الموقع الآمن
sudo a2ensite osu-ssl

# إعادة تشغيل Apache
sudo systemctl restart apache2
 اختبار التهيئة
فحص الشهادة
bash
# التحقق من صحة الشهادة
openssl x509 -in osu.crt -text -noout

# فحص المفتاح الخاص
openssl rsa -in osu.key -check

# مطابقة المفتاح مع الشهادة
openssl x509 -noout -modulus -in osu.crt | openssl md5
openssl rsa -noout -modulus -in osu.key | openssl md5
اختبار الاتصال
bash
# اختبار HTTPS الأساسي
curl -I https://192.168.4.1/osu/

# اختبار مفصل مع SSL
openssl s_client -connect 192.168.4.1:443 -servername 192.168.4.1
 إرشادات الأمان
 حماية المفاتيح الخاصة
bash
# المفتاح الخاص يجب أن يكون مقروءاً للمالك فقط
sudo chmod 600 /etc/ssl/private/osu.key
sudo chown root:root /etc/ssl/private/osu.key

# لا تشارك المفتاح الخاص أبداً
# احتفظ بنسخ احتياطية آمنة
 إدارة دورة الحياة
الشهادات التجريبية: صالحة لمدة 365 يوم

شهادات Let's Encrypt: صالحة لمدة 90 يوم (تتطلب تجديداً)

مراقبة الصلاحية: إعداد تنبيهات قبل انتهاء الصلاحية

 استكشاف الأخطاء الشائعة
المشكلة: تحذير "شهادة غير موثوقة"
الحل:

للتطوير: قبول الشهادة يدوياً في المتصفح

للإنتاج: استخدام Let's Encrypt أو شهادة تجارية

المشكلة: Apache يرفض البدء
# فحص تكوين SSL
sudo apache2ctl configtest

# التحقق من وجود الملفات
sudo ls -la /etc/ssl/certs/osu.crt
sudo ls -la /etc/ssl/private/osu.key

# فحص السجلات
sudo tail -f /var/log/apache2/error.log
المشكلة: اتصال HTTPS فاشل
bash
# فتح المنفذ 443 في الجدار الناري
sudo ufw allow 443/tcp

# التحقق من أن Apache يستمع على المنفذ 443
sudo netstat -tlnp | grep 443
 الدعم والمراجع
مصادر إضافية
وثائق Let's Encrypt

أفضل ممارسات SSL

أدوات فحص SSL

طلب المساعدة
إذا واجهتك أي مشاكل:

راجع ملف certificate_info.txt لمعلومات الشهادة

تحقق من السجلات في /var/log/apache2/

تأكد من مطابقة أسماء النطاق في الشهادة

ملاحظة أخيرة: الأمان مسار وليس وجهة. حافظ على تحديث شهاداتك ومراجعة إعدادات الأمان بانتظام. 

