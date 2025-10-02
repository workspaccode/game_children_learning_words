# 💳 إعداد خدمة الدفع

## 🚀 كيفية تكوين خدمة الدفع

### 1️⃣ تكوين Stripe

1. سجل في [Stripe](https://stripe.com) واحصل على المفاتيح
2. في ملف `lib/services/payment_service.dart`:
   ```dart
   static const String _stripePublishableKey = 'pk_test_your_actual_key_here';
   ```

### 2️⃣ تكوين فوري (Fawry) - للدفع المحلي في مصر

1. سجل في [Fawry](https://fawry.com) للتجار
2. احصل على:
   - Merchant Code
   - Secret Key
3. ضعهم في نفس الملف:
   ```dart
   static const String _fawryMerchantCode = 'your_merchant_code';
   static const String _fawrySecretKey = 'your_secret_key';
   ```

### 3️⃣ إعداد Backend API

1. قم بإنشاء API خاصة بك أو استخدم خدمة جاهزة
2. ضع رابط API الخاص بك:
   ```dart
   static const String _baseUrl = 'https://api.your-app.com';
   ```

## 🔒 الأمان

⚠️ **مهم جداً**: لا تضع المفاتيح السرية في الكود المصدري!

### استخدام متغيرات البيئة:

```bash
# في ملف .env أو متغيرات النظام
PAYMENT_BASE_URL=https://api.your-app.com
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
FAWRY_MERCHANT_CODE=your_code
FAWRY_SECRET_KEY=your_secret
```

## 🧪 الاختبار

1. ابدأ بمفاتيح الاختبار (تبدأ بـ `pk_test_`)
2. جرب المدفوعات الوهمية أولاً
3. انتقل للإنتاج بعد التأكد من كل شيء

## 📞 الدعم

- تحتاج مساعدة مع Stripe؟ راجع [توثيق Stripe](https://stripe.com/docs)
- مشاكل مع فوري؟ تواصل مع [دعم فوري](https://fawry.com/support)