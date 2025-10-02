# 🐍 Flask Backend API Specifications
## تطبيق تعليم الأطفال الكلمات - مواصفات الـ Backend

---

## 📋 **معلومات المشروع:**

**اسم التطبيق:** game_children_learning_words  
**نوع التطبيق:** تعليمي تفاعلي للأطفال  
**Framework:** Flask + Firebase  
**قاعدة البيانات:** Firebase Firestore + Cache Redis (اختياري)  
**المصادقة:** Firebase Authentication  
**الدفع:** متعدد البوابات (مصرية + عالمية)  

---

## 🏗️ **Architecture Overview:**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │───▶│   Flask API     │───▶│   Firebase      │
│                 │    │                 │    │                 │
│ - Authentication│    │ - Payment Proc. │    │ - Firestore DB  │
│ - UI/UX         │    │ - Business Logic│    │ - Auth Service  │
│ - Local Storage │    │ - Gateway APIs  │    │ - Cloud Storage │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Payment Gateways│
                    │                 │
                    │ - Stripe        │
                    │ - Fawry         │
                    │ - Mobile Wallets│
                    │ - Bank Transfer │
                    └─────────────────┘
```

---

## 📦 **Required Dependencies:**

```python
# Flask Core
Flask==2.3.0
Flask-CORS==4.0.0
Flask-RESTful==0.3.10
Flask-JWT-Extended==4.5.2

# Firebase
firebase-admin==6.2.0
google-cloud-firestore==2.11.1

# Payment Processing
stripe==5.5.0
requests==2.31.0

# Utilities
python-decouple==3.8
uuid==1.30
python-dateutil==2.8.2
pytz==2023.3

# Security & Validation
werkzeug==2.3.0
marshmallow==3.20.1
bcrypt==4.0.1

# Optional - Performance
redis==4.6.0
celery==5.3.1

# Development
python-dotenv==1.0.0
```

---

## 🌐 **API Base Configuration:**

```python
# config.py
import os
from decouple import config

class Config:
    # Flask Settings
    SECRET_KEY = config('SECRET_KEY', default='dev-secret-key-change-in-production')
    DEBUG = config('DEBUG', default=False, cast=bool)
    
    # Firebase Configuration
    FIREBASE_PROJECT_ID = config('FIREBASE_PROJECT_ID')
    FIREBASE_CREDENTIALS_PATH = config('FIREBASE_CREDENTIALS_PATH')
    
    # Payment Gateway Settings
    STRIPE_SECRET_KEY = config('STRIPE_SECRET_KEY')
    STRIPE_PUBLISHABLE_KEY = config('STRIPE_PUBLISHABLE_KEY')
    STRIPE_WEBHOOK_SECRET = config('STRIPE_WEBHOOK_SECRET')
    
    # Fawry Settings
    FAWRY_MERCHANT_CODE = config('FAWRY_MERCHANT_CODE')
    FAWRY_SECRET_KEY = config('FAWRY_SECRET_KEY')
    FAWRY_SANDBOX_URL = config('FAWRY_SANDBOX_URL', default='https://atfawry.fawrystaging.com')
    FAWRY_PRODUCTION_URL = config('FAWRY_PRODUCTION_URL', default='https://www.atfawry.com')
    
    # Mobile Wallets
    VODAFONE_CASH_API_KEY = config('VODAFONE_CASH_API_KEY', default='')
    ORANGE_CASH_CLIENT_ID = config('ORANGE_CASH_CLIENT_ID', default='')
    WE_CASH_APP_ID = config('WE_CASH_APP_ID', default='')
    ETISALAT_CASH_MERCHANT_CODE = config('ETISALAT_CASH_MERCHANT_CODE', default='')
    
    # Security
    JWT_SECRET_KEY = config('JWT_SECRET_KEY', default='jwt-secret-key-change-in-production')
    JWT_ACCESS_TOKEN_EXPIRES = 86400  # 24 hours
    
    # Redis (Optional)
    REDIS_URL = config('REDIS_URL', default='redis://localhost:6379/0')
```

---

## 🔐 **Authentication & Authorization:**

### Headers Required:
```http
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
X-User-Type: parent|teacher|child
```

### User Types & Permissions:
- **Parent**: CRUD children, subscribe to teachers, view progress
- **Teacher**: CRUD classrooms, create activities, view earnings  
- **Child**: Limited to gameplay, requires parent authentication
- **Admin**: Full system access (future feature)

---

## 📊 **Data Models (Firestore Collections):**

### 1. **Users Collection:**
```json
{
  "id": "firebase_uid",
  "email": "user@example.com",
  "displayName": "User Name",
  "userType": "parent|teacher|child",
  "profile": {
    "avatar": "https://...",
    "phoneNumber": "+201234567890",
    "country": "EG",
    "language": "ar|en",
    "timezone": "Africa/Cairo"
  },
  "parentId": "parent_uid",  // for children only
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 2. **Subscriptions Collection:**
```json
{
  "id": "subscription_uuid",
  "parentId": "parent_uid",
  "teacherId": "teacher_uid", 
  "childrenIds": ["child1_uid", "child2_uid"],
  "planType": "monthly|semi_annual",
  "amount": 50.00,
  "currency": "SAR",
  "status": "active|expired|cancelled|pending",
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-01-31T23:59:59Z",
  "autoRenew": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 3. **Payments Collection:**
```json
{
  "id": "payment_uuid",
  "userId": "user_uid",
  "subscriptionId": "subscription_uuid",
  "amount": 50.00,
  "currency": "SAR",
  "gateway": "stripe|fawry|vodafone_cash|orange_cash|we_cash|etisalat_cash|mada|bank_transfer",
  "status": "pending|completed|failed|cancelled",
  "gatewayTransactionId": "stripe_pi_xxx",
  "gatewayReference": "gateway_ref_123",
  "type": "subscription|one_time",
  "failureReason": "insufficient_funds",
  "createdAt": "2024-01-01T00:00:00Z",
  "completedAt": "2024-01-01T00:05:00Z",
  "expiresAt": "2024-01-01T01:00:00Z"
}
```

### 4. **Daily Activities Collection:**
```json
{
  "id": "activity_uuid",
  "teacherId": "teacher_uid",
  "childId": "child_uid",
  "title": "اليوم نتعلم الحروف",
  "description": "أنشطة تعليمية متنوعة",
  "targetDate": "2024-01-01",
  "activities": [
    {
      "id": "item_uuid",
      "type": "word_matching|sentence_building|pronunciation|spelling|listening",
      "title": "مطابقة الكلمات",
      "content": {
        "words": ["كتاب", "قلم", "مدرسة"],
        "images": ["book.jpg", "pen.jpg", "school.jpg"]
      },
      "isCompleted": false,
      "score": 0,
      "completedAt": null
    }
  ],
  "totalScore": 0,
  "isCompleted": false,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 5. **Classrooms Collection:**
```json
{
  "id": "classroom_uuid",
  "teacherId": "teacher_uid",
  "name": "فصل الأطفال المبتدئين",
  "description": "تعليم الحروف والكلمات الأساسية",
  "studentIds": ["student1_uid", "student2_uid"],
  "maxStudents": 4,
  "studentCount": 2,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

## 🛣️ **API Endpoints:**

### **🔐 Authentication:**

#### POST `/api/auth/login`
```json
// Request
{
  "firebase_token": "firebase_id_token_here"
}

// Response  
{
  "success": true,
  "data": {
    "access_token": "jwt_token_here",
    "user": {
      "id": "user_uid",
      "email": "user@example.com",
      "userType": "parent",
      "profile": {...}
    }
  }
}
```

#### POST `/api/auth/refresh`
```json
// Request
{
  "refresh_token": "jwt_refresh_token"
}

// Response
{
  "success": true,
  "data": {
    "access_token": "new_jwt_token"
  }
}
```

---

### **👥 User Management:**

#### GET `/api/users/profile`
```json
// Response
{
  "success": true,
  "data": {
    "id": "user_uid",
    "email": "user@example.com",
    "userType": "parent",
    "profile": {...},
    "children": [...],  // if parent
    "subscriptions": [...]
  }
}
```

#### PUT `/api/users/profile`
```json
// Request
{
  "displayName": "New Name",
  "profile": {
    "phoneNumber": "+201234567890",
    "avatar": "https://...",
    "language": "ar"
  }
}
```

#### POST `/api/users/children` (Parent only)
```json
// Request
{
  "name": "Child Name",
  "age": 6,
  "grade": "Grade 1"
}

// Response
{
  "success": true,
  "data": {
    "child": {
      "id": "child_uid",
      "name": "Child Name",
      "parentId": "parent_uid",
      ...
    }
  }
}
```

---

### **💰 Payment Processing:**

#### POST `/api/payments/create-intent`
```json
// Request
{
  "amount": 50.00,
  "currency": "SAR",
  "gateway": "stripe",
  "subscription_id": "subscription_uuid",
  "payment_method_details": {
    // Gateway specific data
    "card_number": "4242424242424242",  // for cards
    "phone_number": "+201234567890"     // for mobile wallets
  }
}

// Response
{
  "success": true,
  "data": {
    "payment_intent": {
      "id": "intent_uuid",
      "client_secret": "stripe_secret_or_payment_url",
      "amount": 50.00,
      "gateway": "stripe",
      "expires_at": "2024-01-01T01:00:00Z"
    }
  }
}
```

#### POST `/api/payments/confirm`
```json
// Request
{
  "payment_intent_id": "intent_uuid",
  "gateway_data": {
    // Gateway specific confirmation data
  }
}

// Response
{
  "success": true,
  "data": {
    "payment": {
      "id": "payment_uuid",
      "status": "completed",
      "transaction_id": "gateway_tx_id",
      ...
    }
  }
}
```

#### GET `/api/payments/history`
```json
// Response
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": "payment_uuid",
        "amount": 50.00,
        "gateway": "stripe",
        "status": "completed",
        "createdAt": "2024-01-01T00:00:00Z",
        ...
      }
    ],
    "total_count": 10,
    "page": 1,
    "per_page": 20
  }
}
```

---

### **🏦 Gateway-Specific Endpoints:**

#### POST `/api/payments/stripe/create-intent`
```json
// Internal endpoint for Stripe processing
{
  "amount": 5000,  // in cents
  "currency": "sar",
  "metadata": {
    "user_id": "user_uid",
    "subscription_id": "sub_uuid"
  }
}
```

#### POST `/api/payments/fawry/create-intent`  
```json
// Internal endpoint for Fawry processing
{
  "merchantCode": "merchant_code",
  "merchantRefNum": "unique_ref",
  "amount": 50.00,
  "signature": "sha256_signature",
  "description": "Education App Subscription"
}
```

#### POST `/api/payments/mobile-wallet/create-intent`
```json
// For Egyptian mobile wallets
{
  "gateway": "vodafone_cash",
  "phone_number": "+201234567890",
  "amount": 50.00,
  "currency": "EGP"
}
```

---

### **🎓 Subscription Management:**

#### POST `/api/subscriptions/create`
```json
// Request (Parent subscribes to Teacher)
{
  "teacher_id": "teacher_uid",
  "children_ids": ["child1_uid", "child2_uid"],
  "plan_type": "monthly",
  "payment_method": "stripe"
}

// Response
{
  "success": true,
  "data": {
    "subscription": {
      "id": "subscription_uuid",
      "amount": 50.00,
      "status": "pending_payment",
      ...
    },
    "payment_intent": {
      "id": "intent_uuid",
      "client_secret": "...",
      ...
    }
  }
}
```

#### GET `/api/subscriptions/my-subscriptions`
```json
// Response (for Parents)
{
  "success": true,
  "data": {
    "subscriptions": [
      {
        "id": "subscription_uuid",
        "teacher": {
          "id": "teacher_uid",
          "name": "Teacher Name",
          "specialization": "Early Learning"
        },
        "children": [...],
        "status": "active",
        "expires_at": "2024-01-31T23:59:59Z",
        ...
      }
    ]
  }
}
```

#### GET `/api/subscriptions/my-students` (Teacher only)
```json
// Response
{
  "success": true,
  "data": {
    "subscriptions": [
      {
        "id": "subscription_uuid",
        "parent": {
          "name": "Parent Name",
          "email": "parent@example.com"
        },
        "children": [...],
        "amount": 50.00,
        "status": "active",
        ...
      }
    ]
  }
}
```

---

### **📚 Educational Content:**

#### POST `/api/activities/create` (Teacher only)
```json
// Request
{
  "child_id": "child_uid",
  "title": "تعلم الحروف",
  "target_date": "2024-01-01",
  "activities": [
    {
      "type": "word_matching",
      "title": "مطابقة الكلمات",
      "content": {
        "words": ["كتاب", "قلم"],
        "images": ["book.jpg", "pen.jpg"]
      }
    }
  ]
}
```

#### GET `/api/activities/child/{child_id}/today`
```json
// Response
{
  "success": true,
  "data": {
    "activities": [
      {
        "id": "activity_uuid",
        "title": "تعلم الحروف",
        "activities": [...],
        "total_score": 85,
        "is_completed": false
      }
    ]
  }
}
```

#### POST `/api/activities/complete-item`
```json
// Request
{
  "activity_id": "activity_uuid",
  "item_id": "item_uuid",
  "score": 8,
  "time_spent": 120  // seconds
}
```

---

### **📊 Analytics & Dashboard:**

#### GET `/api/dashboard/parent/{parent_id}/stats`
```json
// Response
{
  "success": true,
  "data": {
    "total_children": 3,
    "active_subscriptions": 2,
    "total_spent": 150.00,
    "today_activities": 5,
    "completed_activities": 3,
    "completion_rate": 0.6,
    "children_progress": [
      {
        "child_id": "child_uid",
        "name": "Child Name",
        "total_score": 450,
        "activities_completed": 15,
        "last_activity": "2024-01-01T10:30:00Z"
      }
    ]
  }
}
```

#### GET `/api/dashboard/teacher/{teacher_id}/stats`
```json
// Response  
{
  "success": true,
  "data": {
    "total_classrooms": 3,
    "total_students": 8,
    "active_subscriptions": 5,
    "total_revenue": 300.00,
    "monthly_revenue": 250.00,
    "avg_students_per_classroom": 2.67,
    "earnings_breakdown": {
      "monthly_plans": 200.00,
      "semi_annual_plans": 100.00
    }
  }
}
```

---

### **🔔 Webhook Endpoints:**

#### POST `/api/webhooks/stripe`
```python
# Stripe webhook handler
@app.route('/api/webhooks/stripe', methods=['POST'])
def stripe_webhook():
    payload = request.data
    sig_header = request.headers.get('Stripe-Signature')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, app.config['STRIPE_WEBHOOK_SECRET']
        )
        
        if event['type'] == 'payment_intent.succeeded':
            # Handle successful payment
            pass
        elif event['type'] == 'payment_intent.payment_failed':
            # Handle failed payment  
            pass
            
        return jsonify({'status': 'success'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400
```

#### POST `/api/webhooks/fawry`
```python
# Fawry webhook handler
@app.route('/api/webhooks/fawry', methods=['POST'])
def fawry_webhook():
    # Handle Fawry payment notifications
    pass
```

---

## 🚀 **Flask App Structure:**

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
│   │   │   ├── stripe_handler.py
│   │   │   ├── fawry_handler.py
│   │   │   └── mobile_wallets.py
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
│       ├── firebase_admin.py
│       ├── decorators.py
│       ├── validators.py
│       └── helpers.py
│
├── migrations/
├── tests/
├── requirements.txt
├── .env
├── .env.example  
├── run.py
└── wsgi.py
```

---

## ⚙️ **Environment Variables (.env):**

```env
# Flask Configuration
SECRET_KEY=your-super-secret-key-here
DEBUG=True
FLASK_ENV=development

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CREDENTIALS_PATH=path/to/serviceAccountKey.json

# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Fawry
FAWRY_MERCHANT_CODE=your_merchant_code
FAWRY_SECRET_KEY=your_secret_key
FAWRY_SANDBOX_URL=https://atfawry.fawrystaging.com
FAWRY_PRODUCTION_URL=https://www.atfawry.com

# Mobile Wallets
VODAFONE_CASH_API_KEY=your_api_key
VODAFONE_CASH_MERCHANT_ID=your_merchant_id
ORANGE_CASH_CLIENT_ID=your_client_id
ORANGE_CASH_CLIENT_SECRET=your_secret
WE_CASH_APP_ID=your_app_id
WE_CASH_APP_SECRET=your_secret
ETISALAT_CASH_MERCHANT_CODE=your_merchant_code
ETISALAT_CASH_SECRET=your_secret

# Mada (Saudi)
MADA_MERCHANT_ID=your_merchant_id
MADA_TERMINAL_ID=your_terminal_id  
MADA_SECRET_KEY=your_secret

# JWT
JWT_SECRET_KEY=jwt-super-secret-key

# Redis (Optional)
REDIS_URL=redis://localhost:6379/0

# CORS
CORS_ORIGINS=http://localhost:3000,https://yourapp.com
```

---

## 🧪 **Testing Endpoints:**

### Postman Collection Structure:
```
Game Learning Words API/
├── Authentication/
│   ├── Login with Firebase
│   └── Refresh Token
├── Users/
│   ├── Get Profile
│   ├── Update Profile
│   └── Create Child
├── Payments/
│   ├── Create Payment Intent
│   ├── Confirm Payment
│   ├── Payment History
│   └── Gateway Tests/
│       ├── Stripe Test
│       ├── Fawry Test
│       └── Mobile Wallet Test
├── Subscriptions/
│   ├── Create Subscription
│   ├── My Subscriptions
│   └── Teacher Students
├── Activities/
│   ├── Create Activity
│   ├── Get Today's Activities
│   └── Complete Activity Item
└── Dashboard/
    ├── Parent Stats
    └── Teacher Stats
```

---

## 🔒 **Security Considerations:**

### 1. **Firebase Authentication:**
```python
from firebase_admin import auth

def verify_firebase_token(token):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise ValueError(f'Invalid token: {str(e)}')
```

### 2. **Rate Limiting:**
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/payments/create-intent', methods=['POST'])
@limiter.limit("10 per minute")
def create_payment_intent():
    pass
```

### 3. **Input Validation:**
```python
from marshmallow import Schema, fields, validate

class PaymentIntentSchema(Schema):
    amount = fields.Decimal(required=True, validate=validate.Range(min=1, max=10000))
    currency = fields.Str(required=True, validate=validate.OneOf(['SAR', 'EGP', 'USD']))
    gateway = fields.Str(required=True, validate=validate.OneOf([
        'stripe', 'fawry', 'vodafone_cash', 'orange_cash', 'we_cash'
    ]))
```

---

## 📈 **Performance & Monitoring:**

### 1. **Logging:**
```python
import logging
from logging.handlers import RotatingFileHandler

if not app.debug:
    file_handler = RotatingFileHandler('logs/app.log', maxBytes=10240, backupCount=10)
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
```

### 2. **Caching (Redis):**
```python
import redis
from functools import wraps

redis_client = redis.Redis.from_url(app.config['REDIS_URL'])

def cache_result(expiration=300):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            cache_key = f"{func.__name__}:{str(args)}:{str(kwargs)}"
            
            # Try to get from cache
            cached = redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            
            # Execute function and cache result
            result = func(*args, **kwargs)
            redis_client.setex(cache_key, expiration, json.dumps(result))
            return result
        return wrapper
    return decorator
```

---

## 🚀 **Deployment:**

### 1. **Docker Configuration:**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
```

### 2. **Docker Compose:**
```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
    volumes:
      - ./logs:/app/logs
    depends_on:
      - redis

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - api
```

---

## 📝 **Development Checklist:**

### **Phase 1: Core Setup (Week 1)**
- [ ] Flask app initialization
- [ ] Firebase Admin SDK integration  
- [ ] Authentication system
- [ ] User management endpoints
- [ ] Basic error handling

### **Phase 2: Payment Integration (Week 2)**
- [ ] Stripe integration
- [ ] Fawry integration (sandbox)
- [ ] Payment intent creation
- [ ] Webhook handling
- [ ] Payment status tracking

### **Phase 3: Business Logic (Week 3)**  
- [ ] Subscription management
- [ ] Activity creation/completion
- [ ] Dashboard analytics
- [ ] Mobile wallet integration

### **Phase 4: Testing & Deployment (Week 1)**
- [ ] Unit tests
- [ ] Integration tests
- [ ] Security testing
- [ ] Production deployment
- [ ] Monitoring setup

---

## 📞 **Support Information:**

**Documentation:** This file + inline code comments  
**Testing:** Use Postman collection for API testing  
**Issues:** Check logs in `logs/app.log`  
**Database:** Firebase Console for data inspection  
**Payments:** Each gateway has sandbox/test modes  

---

**Last Updated:** December 2024  
**API Version:** v1.0  
**Flask Version:** 2.3.0+  
**Python Version:** 3.9+