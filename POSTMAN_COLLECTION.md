# 🧪 Postman Collection - API Testing
## مجموعة اختبارات API شاملة للـ Backend

---

## 📦 **Postman Collection Structure:**

```
Game Children Learning Words API/
├── 🏥 Health Checks/
│   ├── Basic Health Check
│   └── Detailed Health Check
├── 🔐 Authentication/
│   ├── Login with Firebase
│   └── Refresh Token
├── 👤 User Management/
│   ├── Get Profile
│   ├── Update Profile
│   └── Create Child (Parent)
├── 💳 Payment System/
│   ├── Get Available Gateways
│   ├── Create Payment Intent
│   ├── Confirm Payment
│   ├── Payment History
│   └── Payment Gateway Tests/
│       ├── Stripe Test
│       ├── Fawry Test
│       ├── Vodafone Cash Test
│       ├── Orange Cash Test
│       ├── WE Cash Test
│       └── Etisalat Cash Test
├── 📋 Subscriptions/
│   ├── Create Subscription
│   ├── My Subscriptions (Parent)
│   ├── My Students (Teacher)
│   └── Cancel Subscription
├── 📚 Activities/
│   ├── Create Activity (Teacher)
│   ├── Get Today's Activities
│   ├── Complete Activity Item
│   └── Activity Progress
└── 📊 Dashboard/
    ├── Parent Dashboard Stats
    └── Teacher Dashboard Stats
```

---

## 🌐 **Environment Variables:**

### **Development Environment:**
```json
{
  "base_url": "http://127.0.0.1:5000",
  "api_base": "http://127.0.0.1:5000/api",
  "jwt_token": "",
  "firebase_token": "",
  "user_id": "",
  "user_type": "parent"
}
```

### **Production Environment:**
```json
{
  "base_url": "https://api.gamechildrenwords.com",
  "api_base": "https://api.gamechildrenwords.com/api", 
  "jwt_token": "",
  "firebase_token": "",
  "user_id": "",
  "user_type": "parent"
}
```

---

## 🏥 **Health Checks:**

### **1. Basic Health Check**
```http
GET {{base_url}}/
```

**Expected Response:**
```json
{
  "success": true,
  "timestamp": "2024-01-01T12:00:00.000Z",
  "data": {
    "service": "Game Children Learning Words API",
    "version": "1.0.0",
    "status": "healthy",
    "firebase_connected": true,
    "payment_gateways": {
      "stripe": true,
      "fawry": true,
      "vodafone_cash": false,
      "orange_cash": false
    }
  },
  "message": "API is running successfully"
}
```

### **2. Detailed Health Check**
```http
GET {{api_base}}/health
```

---

## 🔐 **Authentication:**

### **1. Login with Firebase Token**
```http
POST {{api_base}}/auth/login
Content-Type: application/json

{
  "firebase_token": "{{firebase_token}}"
}
```

**Test Script (JavaScript):**
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has JWT token", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data).to.have.property('access_token');
    
    // Save JWT token for future requests
    pm.environment.set("jwt_token", jsonData.data.access_token);
    pm.environment.set("user_id", jsonData.data.user.id);
    pm.environment.set("user_type", jsonData.data.user.userType);
});

pm.test("User data is present", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data.user).to.have.property('email');
    pm.expect(jsonData.data.user).to.have.property('userType');
});
```

### **2. Refresh Token**
```http
POST {{api_base}}/auth/refresh
Authorization: Bearer {{jwt_token}}
```

---

## 👤 **User Management:**

### **1. Get User Profile**
```http
GET {{api_base}}/users/profile
Authorization: Bearer {{jwt_token}}
```

**Test Script:**
```javascript
pm.test("Profile contains user data", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.success).to.be.true;
    pm.expect(jsonData.data).to.have.property('id');
    pm.expect(jsonData.data).to.have.property('email');
});

pm.test("User type matches environment", function () {
    var jsonData = pm.response.json();
    var expectedType = pm.environment.get("user_type");
    pm.expect(jsonData.data.userType).to.equal(expectedType);
});
```

### **2. Update Profile**
```http
PUT {{api_base}}/users/profile
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "displayName": "Updated Name",
  "profile": {
    "phoneNumber": "+201234567890",
    "language": "ar",
    "timezone": "Africa/Cairo"
  }
}
```

### **3. Create Child (Parent Only)**
```http
POST {{api_base}}/users/children
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "name": "طفل جديد",
  "age": 6,
  "grade": "الصف الأول"
}
```

**Pre-request Script:**
```javascript
// Only allow for parent user type
if (pm.environment.get("user_type") !== "parent") {
    console.log("Skipping - User is not a parent");
    pm.execution.setNextRequest(null);
}
```

---

## 💳 **Payment System:**

### **1. Get Available Payment Gateways**
```http
GET {{api_base}}/payments/gateways?country=EG
Authorization: Bearer {{jwt_token}}
```

**Test Script:**
```javascript
pm.test("Returns available gateways", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data.gateways).to.be.an('array');
    pm.expect(jsonData.data.gateways.length).to.be.above(0);
});

pm.test("Egyptian gateways included", function () {
    var jsonData = pm.response.json();
    var gatewayIds = jsonData.data.gateways.map(g => g.id);
    pm.expect(gatewayIds).to.include('fawry');
});
```

### **2. Create Payment Intent - Stripe**
```http
POST {{api_base}}/payments/create-intent
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "amount": 50.00,
  "currency": "SAR",
  "gateway": "stripe",
  "subscription_id": "sub_123456",
  "payment_method_details": {
    "card_number": "4242424242424242",
    "exp_month": 12,
    "exp_year": 2025,
    "cvc": "123"
  }
}
```

**Test Script:**
```javascript
pm.test("Payment intent created", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.success).to.be.true;
    pm.expect(jsonData.data.payment_intent).to.have.property('client_secret');
    
    // Save for next request
    pm.environment.set("payment_intent_id", jsonData.data.payment_intent.id);
});
```

### **3. Create Payment Intent - Fawry**
```http
POST {{api_base}}/payments/create-intent
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "amount": 50.00,
  "currency": "EGP",
  "gateway": "fawry",
  "subscription_id": "sub_123456",
  "payment_method_details": {
    "customer_name": "اسم العميل",
    "customer_email": "customer@example.com",
    "customer_phone": "+201234567890"
  }
}
```

### **4. Create Payment Intent - Mobile Wallet**
```http
POST {{api_base}}/payments/create-intent
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "amount": 50.00,
  "currency": "EGP",
  "gateway": "vodafone_cash",
  "subscription_id": "sub_123456",
  "payment_method_details": {
    "phone_number": "+201234567890"
  }
}
```

**Pre-request Script (Phone Validation):**
```javascript
var phone = "+201234567890";
var egyptianMobileRegex = /^(\+201|01)[0-9]{9}$/;

pm.test("Valid Egyptian mobile number", function () {
    pm.expect(egyptianMobileRegex.test(phone)).to.be.true;
});
```

### **5. Confirm Payment**
```http
POST {{api_base}}/payments/confirm
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "payment_intent_id": "{{payment_intent_id}}",
  "gateway_data": {
    "transaction_id": "stripe_pi_123456",
    "reference_number": "REF_123456"
  }
}
```

### **6. Payment History**
```http
GET {{api_base}}/payments/history?page=1&limit=10
Authorization: Bearer {{jwt_token}}
```

**Test Script:**
```javascript
pm.test("Returns paginated payments", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data).to.have.property('payments');
    pm.expect(jsonData.data).to.have.property('total_count');
    pm.expect(jsonData.data).to.have.property('page');
});
```

---

## 📋 **Subscriptions:**

### **1. Create Subscription**
```http
POST {{api_base}}/subscriptions/create
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "teacher_id": "teacher_uuid_123",
  "children_ids": ["child1_uuid", "child2_uuid"],
  "plan_type": "monthly"
}
```

**Test Script:**
```javascript
pm.test("Subscription created successfully", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.success).to.be.true;
    pm.expect(jsonData.data.subscription).to.have.property('id');
    pm.expect(jsonData.data.payment_intent).to.have.property('client_secret');
    
    pm.environment.set("subscription_id", jsonData.data.subscription.id);
});

pm.test("Children limit validation", function () {
    var jsonData = pm.response.json();
    if (jsonData.data.subscription.children_ids) {
        pm.expect(jsonData.data.subscription.children_ids.length).to.be.at.most(4);
    }
});
```

### **2. Get My Subscriptions (Parent)**
```http
GET {{api_base}}/subscriptions/my-subscriptions
Authorization: Bearer {{jwt_token}}
```

### **3. Get My Students (Teacher)**
```http
GET {{api_base}}/subscriptions/my-students
Authorization: Bearer {{jwt_token}}
```

**Pre-request Script:**
```javascript
// Only for teachers
if (pm.environment.get("user_type") !== "teacher") {
    console.log("Skipping - User is not a teacher");
    pm.execution.setNextRequest(null);
}
```

---

## 📚 **Activities:**

### **1. Create Activity (Teacher)**
```http
POST {{api_base}}/activities/create
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "child_id": "child_uuid_123",
  "title": "تعلم الحروف الهجائية",
  "target_date": "2024-01-01",
  "activities": [
    {
      "type": "word_matching",
      "title": "مطابقة الكلمات",
      "content": {
        "words": ["كتاب", "قلم", "مدرسة"],
        "images": ["book.jpg", "pen.jpg", "school.jpg"]
      }
    },
    {
      "type": "pronunciation",
      "title": "نطق الكلمات",
      "content": {
        "words": ["شمس", "قمر", "نجم"],
        "audio_files": ["sun.mp3", "moon.mp3", "star.mp3"]
      }
    }
  ]
}
```

### **2. Get Today's Activities**
```http
GET {{api_base}}/activities/child/{{child_id}}/today
Authorization: Bearer {{jwt_token}}
```

### **3. Complete Activity Item**
```http
POST {{api_base}}/activities/complete-item
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "activity_id": "activity_uuid_123",
  "item_id": "item_uuid_456",
  "score": 8,
  "time_spent": 120,
  "completion_data": {
    "correct_answers": 4,
    "total_questions": 5,
    "attempts": 1
  }
}
```

---

## 📊 **Dashboard:**

### **1. Parent Dashboard Stats**
```http
GET {{api_base}}/dashboard/parent/{{user_id}}/stats
Authorization: Bearer {{jwt_token}}
```

**Test Script:**
```javascript
pm.test("Parent stats complete", function () {
    var jsonData = pm.response.json();
    var stats = jsonData.data;
    
    pm.expect(stats).to.have.property('total_children');
    pm.expect(stats).to.have.property('active_subscriptions');
    pm.expect(stats).to.have.property('total_spent');
    pm.expect(stats).to.have.property('completion_rate');
});
```

### **2. Teacher Dashboard Stats**
```http
GET {{api_base}}/dashboard/teacher/{{user_id}}/stats
Authorization: Bearer {{jwt_token}}
```

**Pre-request Script:**
```javascript
// Only for teachers
if (pm.environment.get("user_type") !== "teacher") {
    console.log("Skipping - User is not a teacher");
    pm.execution.setNextRequest(null);
}
```

**Test Script:**
```javascript
pm.test("Teacher stats complete", function () {
    var jsonData = pm.response.json();
    var stats = jsonData.data;
    
    pm.expect(stats).to.have.property('total_students');
    pm.expect(stats).to.have.property('total_earnings');
    pm.expect(stats).to.have.property('monthly_earnings');
    pm.expect(stats).to.have.property('active_subscriptions');
});
```

---

## 🧪 **Test Suites:**

### **1. Authentication Test Suite**
```javascript
// Collection Pre-request Script
pm.test("Environment setup", function () {
    pm.expect(pm.environment.get("base_url")).to.not.be.empty;
    pm.expect(pm.environment.get("firebase_token")).to.not.be.empty;
});

// Collection Test Script  
pm.test("Response time acceptable", function () {
    pm.expect(pm.response.responseTime).to.be.below(5000);
});

pm.test("Response format valid", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
    pm.expect(jsonData).to.have.property('timestamp');
});
```

### **2. Payment Gateway Test Suite**
```javascript
// Test each gateway individually
var gateways = ['stripe', 'fawry', 'vodafone_cash', 'orange_cash', 'we_cash', 'etisalat_cash'];

gateways.forEach(function(gateway) {
    pm.test(`${gateway} gateway available`, function () {
        var jsonData = pm.response.json();
        var availableGateways = jsonData.data.gateways.map(g => g.id);
        
        // Check if gateway is configured
        if (pm.environment.get(`${gateway.toUpperCase()}_ENABLED`)) {
            pm.expect(availableGateways).to.include(gateway);
        }
    });
});
```

### **3. Load Testing Simulation**
```javascript
// Run in Postman Collection Runner
// Set iterations: 100, delay: 100ms

pm.test("Load test - response time", function () {
    pm.expect(pm.response.responseTime).to.be.below(2000); // 2 seconds max
});

pm.test("Load test - no errors", function () {
    pm.expect(pm.response.code).to.be.oneOf([200, 201, 204]);
});
```

---

## 🔧 **Utility Scripts:**

### **Global Pre-request Script:**
```javascript
// Auto-refresh JWT token if expired
var jwtToken = pm.environment.get("jwt_token");
if (jwtToken) {
    // Simple JWT expiration check (you might want to use a library)
    try {
        var payload = JSON.parse(atob(jwtToken.split('.')[1]));
        var exp = payload.exp;
        var now = Math.floor(Date.now() / 1000);
        
        if (exp < now) {
            console.log("JWT token expired, please refresh");
            // Could trigger refresh automatically here
        }
    } catch (e) {
        console.log("Invalid JWT token format");
    }
}

// Add common headers
pm.request.headers.add({
    key: 'X-API-Version',
    value: 'v1'
});

pm.request.headers.add({
    key: 'X-User-Type', 
    value: pm.environment.get("user_type")
});
```

### **Global Test Script:**
```javascript
// Common assertions for all requests
pm.test("Status code is successful", function () {
    pm.expect(pm.response.code).to.be.oneOf([200, 201, 204]);
});

pm.test("Response has success field", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
});

pm.test("Response time reasonable", function () {
    pm.expect(pm.response.responseTime).to.be.below(10000);
});

// Log response for debugging
if (pm.response.code >= 400) {
    console.log("Error Response:", pm.response.json());
}
```

---

## 📋 **Test Data Sets:**

### **Egyptian Phone Numbers (Valid):**
```json
[
  "+201234567890",
  "+201012345678", 
  "+201112345678",
  "+201212345678",
  "01034567890",
  "01534567890"
]
```

### **Egyptian Phone Numbers (Invalid):**
```json
[
  "1234567890",
  "+20234567890",
  "+201234567",
  "02012345678",
  "+1234567890"
]
```

### **Test Card Numbers:**
```json
{
  "visa_success": "4242424242424242",
  "visa_decline": "4000000000000002",
  "mastercard_success": "5555555555554444",
  "amex_success": "378282246310005"
}
```

### **Currency Codes:**
```json
{
  "saudi": "SAR",
  "egyptian": "EGP", 
  "usd": "USD",
  "euro": "EUR"
}
```

---

## 🚀 **Running the Tests:**

### **Manual Testing:**
1. Import collection في Postman
2. Set up environment variables
3. Run requests individually
4. Check test results

### **Automated Testing:**
```bash
# Install Newman (Postman CLI)
npm install -g newman

# Run collection
newman run collection.json -e environment.json --reporters html

# Run with specific folder
newman run collection.json -e environment.json --folder "Payment System"

# Run with iterations (load testing)
newman run collection.json -e environment.json --iteration-count 10 --delay-request 1000
```

### **CI/CD Integration:**
```yaml
# GitHub Actions
name: API Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Newman
        run: npm install -g newman
      - name: Run API Tests
        run: newman run tests/postman_collection.json -e tests/environment.json --reporters junit
```

---

## 📊 **Test Reports:**

### **Expected Test Coverage:**
- **Authentication:** 100% pass rate
- **User Management:** 95% pass rate
- **Payments:** 90% pass rate (some gateways may be disabled)
- **Subscriptions:** 95% pass rate
- **Activities:** 85% pass rate
- **Dashboard:** 90% pass rate

### **Performance Benchmarks:**
- **Health Check:** < 100ms
- **Authentication:** < 500ms
- **Payment Intent Creation:** < 2000ms
- **Database Queries:** < 1000ms
- **Dashboard Stats:** < 3000ms

---

**📅 Last Updated:** December 2024  
**🔧 Postman Version:** 10.0+  
**🧪 Newman Version:** 5.0+  
**📊 Coverage Target:** 90%+