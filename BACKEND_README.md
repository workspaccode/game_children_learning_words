# 🐍 Flask Backend - تطبيق تعليم الأطفال الكلمات

Backend API متكامل مع نظام دفع متعدد البوابات للسوق المصري والخليجي

---

## 🚀 **Quick Start:**

### 1. **إنشاء البيئة الافتراضية:**
```bash
# إنشاء virtual environment
python -m venv venv

# تفعيل البيئة (Windows)
venv\Scripts\activate

# تفعيل البيئة (Mac/Linux)
source venv/bin/activate
```

### 2. **تثبيت المتطلبات:**
```bash
pip install -r backend_requirements.txt
```

### 3. **إعداد متغيرات البيئة:**
```bash
# انسخ ملف البيئة التجريبية
copy backend_env_example.txt .env

# عدّل القيم في .env حسب مشروعك
```

### 4. **إعداد Firebase:**
```bash
# 1. اذهب إلى Firebase Console
# 2. إنشاء Service Account Key
# 3. حمّل ملف JSON وضعه في مجلد credentials/
# 4. عدّل مسار الملف في .env
```

### 5. **تشغيل الخادم:**
```bash
python flask_app_starter.py
```

**🎉 الخادم يعمل على:** `http://127.0.0.1:5000`

---

## 📁 **هيكل المشروع المقترح:**

```
backend/
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── extensions.py
│   │
│   ├── auth/
│   │   ├── __init__.py
│   │   ├── routes.py
│   │   └── decorators.py
│   │
│   ├── users/
│   │   ├── __init__.py
│   │   ├── routes.py
│   │   └── models.py
│   │
│   ├── payments/
│   │   ├── __init__.py
│   │   ├── routes.py
│   │   ├── gateways/
│   │   │   ├── __init__.py
│   │   │   ├── stripe_handler.py
│   │   │   ├── fawry_handler.py
│   │   │   ├── vodafone_cash.py
│   │   │   ├── orange_cash.py
│   │   │   ├── we_cash.py
│   │   │   ├── etisalat_cash.py
│   │   │   └── mada_handler.py
│   │   └── webhooks.py
│   │
│   ├── subscriptions/
│   │   ├── __init__.py
│   │   └── routes.py
│   │
│   ├── activities/
│   │   ├── __init__.py
│   │   └── routes.py
│   │
│   ├── dashboard/
│   │   ├── __init__.py
│   │   └── routes.py
│   │
│   └── utils/
│       ├── firebase_client.py
│       ├── decorators.py
│       ├── validators.py
│       └── helpers.py
│
├── credentials/
│   └── serviceAccountKey.json
├── logs/
├── tests/
├── .env
├── requirements.txt
├── run.py
└── wsgi.py
```

---

## 🔧 **إعداد Firebase:**

### 1. **إنشاء مشروع Firebase:**
```
1. اذهب إلى https://console.firebase.google.com/
2. إنشاء مشروع جديد
3. تفعيل Authentication (Email/Password + Google)
4. تفعيل Firestore Database
5. إنشاء Service Account Key:
   - Project Settings > Service Accounts
   - Generate New Private Key
   - حفظ الملف في credentials/serviceAccountKey.json
```

### 2. **قواعد الأمان Firestore:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        (resource.data.user_type == 'child' && 
         request.auth.uid == resource.data.parent_id);
    }
    
    // Payments - user can only access their own
    match /payments/{paymentId} {
      allow read, write: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
    }
    
    // Subscriptions  
    match /subscriptions/{subscriptionId} {
      allow read, write: if request.auth != null && 
        (resource.data.parent_id == request.auth.uid || 
         resource.data.teacher_id == request.auth.uid);
    }
  }
}
```

---

## 🏦 **إعداد بوابات الدفع:**

### 🌍 **Stripe (عالمية):**
```bash
# 1. إنشاء حساب على https://stripe.com/
# 2. الحصول على API Keys من Dashboard
# 3. إضافة في .env:
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 🇪🇬 **فوري (Fawry):**
```bash
# 1. التسجيل كتاجر على https://fawry.com/
# 2. الحصول على:
FAWRY_MERCHANT_CODE=your_merchant_code
FAWRY_SECRET_KEY=your_secret_key
```

### 📱 **المحافظ المصرية:**

#### **فودافون كاش:**
```bash
VODAFONE_CASH_API_KEY=your_api_key
VODAFONE_CASH_MERCHANT_ID=your_merchant_id
```

#### **أورانج كاش:**
```bash  
ORANGE_CASH_CLIENT_ID=your_client_id
ORANGE_CASH_CLIENT_SECRET=your_client_secret
```

#### **WE كاش:**
```bash
WE_CASH_APP_ID=your_app_id
WE_CASH_APP_SECRET=your_app_secret
```

#### **اتصالات كاش:**
```bash
ETISALAT_CASH_MERCHANT_CODE=your_merchant_code
ETISALAT_CASH_SECRET=your_secret_key
```

### 🇸🇦 **مدى (السعودية):**
```bash
MADA_MERCHANT_ID=your_merchant_id  
MADA_TERMINAL_ID=your_terminal_id
MADA_SECRET_KEY=your_secret_key
```

---

## 🔗 **API Endpoints:**

### **🏥 Health Check:**
```http
GET /
GET /api/health
```

### **🔐 Authentication:**
```http
POST /api/auth/login
POST /api/auth/refresh  
```

### **👤 User Management:**
```http
GET    /api/users/profile
PUT    /api/users/profile
POST   /api/users/children
```

### **💳 Payments:**
```http
GET    /api/payments/gateways
POST   /api/payments/create-intent
POST   /api/payments/confirm
GET    /api/payments/history
```

### **📋 Subscriptions:**
```http
POST   /api/subscriptions/create
GET    /api/subscriptions/my-subscriptions
GET    /api/subscriptions/my-students
```

### **📚 Activities:**
```http
POST   /api/activities/create
GET    /api/activities/child/{id}/today
POST   /api/activities/complete-item
```

### **📊 Dashboard:**
```http
GET    /api/dashboard/parent/{id}/stats
GET    /api/dashboard/teacher/{id}/stats
```

---

## 🧪 **اختبار API:**

### **1. Health Check:**
```bash
curl http://127.0.0.1:5000/
```

### **2. Get Payment Gateways:**
```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://127.0.0.1:5000/api/payments/gateways?country=EG
```

### **3. Create Payment Intent:**
```bash
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -d '{"amount":50,"currency":"SAR","gateway":"stripe","subscription_id":"sub_123"}' \
     http://127.0.0.1:5000/api/payments/create-intent
```

---

## 🔍 **Authentication Flow:**

### **1. من تطبيق Flutter:**
```dart
// 1. Login with Firebase
final user = await FirebaseAuth.instance.signInWithEmailAndPassword(...);
final idToken = await user.user!.getIdToken();

// 2. Send to backend
final response = await http.post(
  Uri.parse('$backendUrl/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'firebase_token': idToken}),
);

// 3. Get JWT token
final data = json.decode(response.body);
final jwtToken = data['data']['access_token'];
```

### **2. استخدام JWT في الطلبات:**
```dart
final response = await http.get(
  Uri.parse('$backendUrl/api/users/profile'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $jwtToken',
  },
);
```

---

## 📊 **قاعدة البيانات (Firestore Collections):**

### **users:**
```
users/{userId}
├── email: string
├── displayName: string  
├── userType: "parent"|"teacher"|"child"
├── profile: object
├── parentId: string (for children)
├── isActive: boolean
└── timestamps: created_at, updated_at
```

### **subscriptions:**
```
subscriptions/{subscriptionId}
├── parentId: string
├── teacherId: string
├── childrenIds: array
├── planType: "monthly"|"semi_annual"
├── amount: number
├── currency: string
├── status: "active"|"expired"|"cancelled"
└── timestamps: startDate, endDate, created_at
```

### **payments:**
```
payments/{paymentId}
├── userId: string
├── subscriptionId: string
├── amount: number
├── currency: string
├── gateway: string
├── status: "pending"|"completed"|"failed"
├── gatewayTransactionId: string
└── timestamps: created_at, completed_at
```

---

## 🔧 **تطوير متقدم:**

### **1. إضافة Redis للـ Caching:**
```bash
# تثبيت Redis
pip install redis

# في التطبيق
import redis
redis_client = redis.Redis.from_url(os.getenv('REDIS_URL'))

@cache_result(expiration=300)
def get_user_data(user_id):
    # Cache user data for 5 minutes
    pass
```

### **2. إضافة Celery للمهام الخلفية:**
```bash
pip install celery

# إنشاء worker
celery -A app.celery worker --loglevel=info

# مهام مثل إرسال emails، معالجة payments
@celery.task
def process_payment_webhook(payment_data):
    # Background processing
    pass
```

### **3. إضافة Monitoring:**
```bash
pip install sentry-sdk

import sentry_sdk
sentry_sdk.init(dsn="YOUR_SENTRY_DSN")
```

---

## 🚀 **الانتشار Production:**

### **1. Gunicorn WSGI Server:**
```bash
pip install gunicorn

# تشغيل
gunicorn -w 4 -b 0.0.0.0:5000 wsgi:app
```

### **2. Docker Container:**
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "wsgi:app"]
```

### **3. Environment Variables Production:**
```bash
# Set in production
DEBUG=False
FLASK_ENV=production
STRIPE_SECRET_KEY=sk_live_...
JWT_SECRET_KEY=super-secure-production-key
SESSION_COOKIE_SECURE=True
FAWRY_IS_SANDBOX=False
# etc...
```

---

## 📋 **Checklist للإطلاق:**

### **Development:**
- [ ] Firebase project setup
- [ ] Environment variables configured  
- [ ] Payment gateway sandbox testing
- [ ] Authentication flow working
- [ ] Basic CRUD operations
- [ ] Error handling implemented

### **Staging:**
- [ ] Production Firebase project
- [ ] Real payment gateway credentials (test mode)
- [ ] Full API testing with Postman
- [ ] Performance testing  
- [ ] Security audit
- [ ] Logging and monitoring

### **Production:**
- [ ] SSL certificate configured
- [ ] Production payment gateways activated
- [ ] Database backups scheduled
- [ ] Rate limiting activated
- [ ] Health monitoring alerts
- [ ] Documentation finalized

---

## 🆘 **Troubleshooting:**

### **مشاكل شائعة:**

**1. Firebase Connection:**
```
Error: Could not connect to Firebase
Solution: تحقق من مسار serviceAccountKey.json في .env
```

**2. Stripe Integration:**
```
Error: No API key provided
Solution: تأكد من STRIPE_SECRET_KEY في .env
```

**3. CORS Issues:**
```
Error: CORS policy blocked
Solution: أضف domain التطبيق في CORS_ORIGINS
```

**4. JWT Token Expired:**
```
Error: Token has expired
Solution: تطبيق refresh token mechanism
```

---

## 📞 **الدعم والمساعدة:**

- **الوثائق:** `BACKEND_API_SPECS.md`
- **أمثلة:** `flask_app_starter.py`  
- **اختبار:** Postman collection في المستندات
- **البيئة:** `.env.example` للإعداد

**تاريخ آخر تحديث:** ديسمبر 2024  
**الإصدار:** v1.0.0  
**متطلبات Python:** 3.9+