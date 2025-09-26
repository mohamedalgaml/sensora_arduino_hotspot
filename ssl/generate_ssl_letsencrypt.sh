set -e
DOMAIN="hotspot.mydomain.com"
EMAIL="admin@mydomain.com"
echo "🛡️  إصدار شهادات SSL لـ $DOMAIN باستخدام Let's Encrypt"

# تثبيت Certbot لو مش موجود
if ! command -v certbot &> /dev/null; then
    echo "📦 تثبيت Certbot..."
    sudo apt update
    sudo apt install -y certbot
fi
# إصدار الشهادة
echo "📑 إنشاء شهادة SSL..."
sudo certbot certonly --standalone \
    --agree-tos \
    --non-interactive \
    --preferred-challenges http \
    -m "$EMAIL" \
    -d "$DOMAIN"

# تحديد المسارات
SSL_PATH="/etc/letsencrypt/live/$DOMAIN"

echo " تم إصدار الشهادة بنجاح!"
echo ""
echo " الملفات موجودة في:"
echo "    Private Key:   $SSL_PATH/privkey.pem"
echo "    Certificate:   $SSL_PATH/fullchain.pem"
echo "    Chain:         $SSL_PATH/chain.pem"
echo ""
echo "  ملاحظة: الشهادة صالحة 90 يوم فقط"
echo "   يُفضل إعداد تجديد تلقائي باستخدام:"
echo "   sudo certbot renew --dry-run"
