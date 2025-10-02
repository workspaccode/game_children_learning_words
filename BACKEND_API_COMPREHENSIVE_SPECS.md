# تطبيق تعليم الكلمات للأطفال - مواصفات الـ Backend API الشاملة

## نظرة عامة على النظام

### الهيكل الأساسي للمستخدمين
```
Parent (ولي الأمر)
├── Child 1 (الطفل الأول)
├── Child 2 (الطفل الثاني) 
├── Child 3 (الطفل الثالث)
└── Child 4 (الطفل الرابع) - الحد الأقصى
```

### أنواع المستخدمين
1. **Parent (ولي الأمر)** - المستخدم الرئيسي
2. **Child (الطفل)** - مرتبط بولي الأمر
3. **Teacher (المعلم/المعلمة)** - يمكن الاشتراك معه
4. **Admin (الإدارة)** - إدارة النظام

## 1. نظام المصادقة والحسابات (Authentication & Accounts)

### 1.1 تسجيل ولي الأمر (Parent Registration)

```http
POST /api/auth/parent/register
Content-Type: application/json

{
  "email": "parent@example.com",
  "password": "password123",
  "full_name": "أحمد محمد علي",
  "phone": "+201234567890",
  "country_code": "EG",
  "preferred_language": "ar",
  "notification_preferences": {
    "email_notifications": true,
    "sms_notifications": true,
    "push_notifications": true,
    "daily_reports": true,
    "weekly_reports": true
  },
  "children_data": [
    {
      "name": "محمد أحمد",
      "age": 6,
      "grade_level": "grade_1",
      "learning_language": "en",
      "native_language": "ar",
      "learning_preferences": {
        "difficulty_level": "beginner",
        "daily_goals": 30,
        "preferred_game_types": ["word_matching", "pronunciation"],
        "study_time_preference": "evening"
      }
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تسجيل الحساب بنجاح",
  "data": {
    "parent_id": "parent_123456",
    "email": "parent@example.com",
    "verification_required": true,
    "children": [
      {
        "child_id": "child_789012",
        "name": "محمد أحمد",
        "account_status": "active"
      }
    ]
  },
  "tokens": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "def50200b8c3f...",
    "expires_in": 3600
  }
}
```

### 1.2 إضافة طفل جديد (Add Child)

```http
POST /api/parent/children
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "فاطمة أحمد",
  "age": 8,
  "grade_level": "grade_2",
  "learning_language": "en",
  "native_language": "ar",
  "profile_picture": "base64_encoded_image_or_url",
  "learning_preferences": {
    "difficulty_level": "intermediate",
    "daily_goals": 45,
    "preferred_game_types": ["sentence_building", "spelling"],
    "study_time_preference": "morning",
    "interests": ["animals", "colors", "food"]
  }
}
```

### 1.3 تسجيل دخول ولي الأمر

```http
POST /api/auth/parent/login
Content-Type: application/json

{
  "email": "parent@example.com",
  "password": "password123"
}
```

## 2. إدارة الأطفال (Children Management)

### 2.1 الحصول على بيانات الأطفال

```http
GET /api/parent/children
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "children": [
      {
        "child_id": "child_789012",
        "name": "محمد أحمد",
        "age": 6,
        "grade_level": "grade_1",
        "profile_picture": "https://storage.app.com/profiles/child_123.jpg",
        "learning_stats": {
          "words_learned": 150,
          "games_played": 45,
          "average_score": 85,
          "current_streak": 5,
          "total_study_time": 1200,
          "level_progress": {
            "current_level": 3,
            "progress_percentage": 65
          }
        },
        "recent_activity": {
          "last_session": "2024-01-15T16:30:00Z",
          "session_duration": 25,
          "games_played_today": 3,
          "words_learned_today": 8
        }
      }
    ],
    "parent_stats": {
      "total_children": 2,
      "active_children_today": 1,
      "total_family_study_time": 2400
    }
  }
}
```

### 2.2 الأنشطة اليومية للطفل (Daily Activities)

```http
GET /api/parent/children/{child_id}/daily-activities
Authorization: Bearer {access_token}
Query Parameters:
- date: 2024-01-15 (optional, defaults to today)
- period: week|month (optional)
```

**Response:**
```json
{
  "success": true,
  "data": {
    "child_id": "child_789012",
    "date": "2024-01-15",
    "daily_summary": {
      "total_study_time": 35,
      "games_completed": 4,
      "words_learned": 12,
      "accuracy_rate": 88,
      "goals_achieved": {
        "daily_time_goal": true,
        "words_goal": true,
        "games_goal": false
      }
    },
    "activities": [
      {
        "activity_id": "act_001",
        "activity_type": "word_matching_game",
        "start_time": "2024-01-15T16:00:00Z",
        "end_time": "2024-01-15T16:12:00Z",
        "duration": 12,
        "score": 85,
        "words_practiced": ["cat", "dog", "house", "car"],
        "accuracy": 90,
        "difficulty_level": "beginner",
        "performance": {
          "correct_answers": 9,
          "wrong_answers": 1,
          "total_questions": 10
        }
      },
      {
        "activity_id": "act_002", 
        "activity_type": "pronunciation_practice",
        "start_time": "2024-01-15T16:15:00Z",
        "end_time": "2024-01-15T16:23:00Z",
        "duration": 8,
        "words_practiced": ["apple", "banana", "orange"],
        "pronunciation_scores": [
          {"word": "apple", "score": 95},
          {"word": "banana", "score": 78},
          {"word": "orange", "score": 88}
        ]
      }
    ],
    "achievements_unlocked": [
      {
        "achievement_id": "streak_5",
        "title": "5 أيام متتالية",
        "description": "لعب لمدة 5 أيام متتالية",
        "badge_url": "https://storage.app.com/badges/streak_5.png"
      }
    ]
  }
}
```

### 2.3 تقرير أداء مفصل (Detailed Performance Report)

```http
GET /api/parent/children/{child_id}/performance-report
Authorization: Bearer {access_token}
Query Parameters:
- period: week|month|quarter
- include_comparisons: true|false
```

**Response:**
```json
{
  "success": true,
  "data": {
    "child_id": "child_789012",
    "report_period": "month",
    "report_date_range": {
      "start_date": "2024-01-01",
      "end_date": "2024-01-31"
    },
    "overall_performance": {
      "improvement_percentage": 23,
      "consistency_score": 85,
      "engagement_level": "high",
      "recommended_next_steps": [
        "زيادة مستوى الصعوبة في ألعاب التهجي",
        "التركيز على الكلمات المتعلقة بالعلوم"
      ]
    },
    "subject_breakdown": {
      "vocabulary": {
        "words_learned": 85,
        "retention_rate": 92,
        "strongest_categories": ["animals", "colors"],
        "needs_improvement": ["numbers", "time"]
      },
      "pronunciation": {
        "average_score": 87,
        "improvement_trend": "increasing",
        "challenging_sounds": ["th", "r"]
      },
      "grammar": {
        "sentence_building_accuracy": 78,
        "common_mistakes": ["verb conjugation", "article usage"]
      }
    },
    "learning_patterns": {
      "most_active_time": "16:00-18:00",
      "preferred_game_types": ["word_matching", "pronunciation"],
      "optimal_session_length": 15,
      "attention_span_trends": "improving"
    },
    "peer_comparison": {
      "rank_in_age_group": 15,
      "percentile": 78,
      "area_of_strength": "vocabulary",
      "area_for_improvement": "grammar"
    }
  }
}
```

## 3. نظام المعلمين (Teachers System)

### 3.1 البحث عن المعلمين

```http
GET /api/teachers/search
Authorization: Bearer {access_token}
Query Parameters:
- specialization: english|arabic|math
- experience_level: beginner|intermediate|expert
- rating_min: 4.5
- price_range: 100-500
- availability: morning|afternoon|evening
- location: cairo|alexandria|online
```

**Response:**
```json
{
  "success": true,
  "data": {
    "teachers": [
      {
        "teacher_id": "teacher_001",
        "full_name": "د. سارة أحمد محمد",
        "profile_picture": "https://storage.app.com/teachers/sara_001.jpg",
        "specialization": ["english", "pronunciation"],
        "experience_years": 8,
        "rating": 4.8,
        "total_reviews": 156,
        "hourly_rate": 250,
        "currency": "EGP",
        "bio": "معلمة لغة إنجليزية معتمدة مع خبرة 8 سنوات في تعليم الأطفال",
        "qualifications": [
          "بكالوريوس تربية إنجليزي",
          "دبلوم تعليم الأطفال",
          "شهادة TEFL"
        ],
        "teaching_methods": [
          "التعلم التفاعلي",
          "الألعاب التعليمية",
          "القصص المصورة"
        ],
        "availability": {
          "timezone": "Africa/Cairo",
          "weekly_schedule": {
            "sunday": ["09:00-12:00", "14:00-17:00"],
            "monday": ["09:00-12:00", "14:00-17:00"],
            "tuesday": ["14:00-17:00"],
            "wednesday": ["09:00-12:00", "14:00-17:00"],
            "thursday": ["09:00-12:00"],
            "friday": [],
            "saturday": ["09:00-12:00", "14:00-17:00"]
          }
        },
        "subscription_plans": [
          {
            "plan_id": "monthly_basic",
            "name": "خطة شهرية أساسية",
            "sessions_count": 8,
            "session_duration": 30,
            "price": 1800,
            "features": [
              "8 جلسات شهرياً",
              "متابعة يومية للتقدم",
              "تقارير أسبوعية"
            ]
          },
          {
            "plan_id": "monthly_premium",
            "name": "خطة شهرية مميزة",
            "sessions_count": 12,
            "session_duration": 45,
            "price": 2500,
            "features": [
              "12 جلسة شهرياً",
              "متابعة يومية للتقدم",
              "تقارير أسبوعية",
              "واجبات مخصصة",
              "جلسات إضافية للمراجعة"
            ]
          }
        ]
      }
    ],
    "filters_applied": {
      "specialization": "english",
      "rating_min": 4.5
    },
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_teachers": 47
    }
  }
}
```

### 3.2 اشتراك مع معلم

```http
POST /api/parent/subscribe-teacher
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "teacher_id": "teacher_001",
  "child_id": "child_789012", 
  "subscription_plan_id": "monthly_premium",
  "payment_method": "fawry",
  "preferred_schedule": {
    "days": ["sunday", "tuesday", "thursday"],
    "time_slot": "16:00-16:45"
  },
  "special_requests": "التركيز على النطق وبناء الجمل",
  "payment_gateway": "fawry"
}
```

### 3.3 جلسات المعلم المجدولة

```http
GET /api/parent/teacher-sessions
Authorization: Bearer {access_token}
Query Parameters:
- child_id: child_789012
- status: upcoming|completed|cancelled
- date_range: week|month
```

**Response:**
```json
{
  "success": true,
  "data": {
    "sessions": [
      {
        "session_id": "session_001",
        "teacher_id": "teacher_001",
        "teacher_name": "د. سارة أحمد",
        "child_id": "child_789012",
        "child_name": "محمد أحمد",
        "scheduled_date": "2024-01-20",
        "scheduled_time": "16:00-16:45",
        "status": "upcoming",
        "session_type": "individual",
        "topic": "كلمات الألوان والأشكال",
        "preparation_materials": [
          "كتاب الألوان",
          "بطاقات الأشكال",
          "أنشطة تفاعلية"
        ],
        "zoom_link": "https://zoom.us/j/1234567890",
        "session_notes": null
      },
      {
        "session_id": "session_002",
        "teacher_id": "teacher_001", 
        "teacher_name": "د. سارة أحمد",
        "child_id": "child_789012",
        "child_name": "محمد أحمد",
        "scheduled_date": "2024-01-18",
        "scheduled_time": "16:00-16:45",
        "status": "completed",
        "session_type": "individual",
        "topic": "أسماء الحيوانات",
        "actual_duration": 42,
        "session_notes": {
          "teacher_notes": "أداء ممتاز في حفظ أسماء الحيوانات. يحتاج تحسين في النطق",
          "homework_assigned": "مراجعة 15 كلمة حيوان يومياً",
          "strengths": ["الحفظ السريع", "الاستجابة الجيدة"],
          "areas_for_improvement": ["النطق", "الثقة في التحدث"],
          "next_session_focus": "النطق والممارسة الشفوية"
        },
        "session_recording": "https://storage.app.com/sessions/session_002_recording.mp4",
        "rating": {
          "parent_rating": 5,
          "child_engagement": 4,
          "teacher_rating": 5
        }
      }
    ],
    "upcoming_count": 3,
    "completed_count": 8,
    "total_hours_completed": 6.2
  }
}
```

## 4. نظام الدفع المتقدم (Advanced Payment System)

### 4.1 البوابات المصرية المدعومة

```json
{
  "egyptian_gateways": {
    "fawry": {
      "gateway_id": "fawry",
      "name": "فوري",
      "logo": "https://storage.app.com/gateways/fawry.png",
      "fees": "2.5%",
      "processing_time": "instant",
      "supported_methods": ["fawry_code", "mobile_wallet", "bank_card"],
      "min_amount": 10,
      "max_amount": 50000,
      "currency": "EGP"
    },
    "vodafone_cash": {
      "gateway_id": "vodafone_cash",
      "name": "فودافون كاش",
      "logo": "https://storage.app.com/gateways/vodafone.png",
      "fees": "1.5%",
      "processing_time": "instant",
      "min_amount": 5,
      "max_amount": 30000,
      "currency": "EGP"
    },
    "we_cash": {
      "gateway_id": "we_cash",
      "name": "WE Cash",
      "fees": "1.5%",
      "processing_time": "instant"
    },
    "orange_cash": {
      "gateway_id": "orange_cash", 
      "name": "Orange Cash",
      "fees": "1.5%"
    },
    "etisalat_cash": {
      "gateway_id": "etisalat_cash",
      "name": "اتصالات كاش",
      "fees": "1.5%"
    },
    "bank_transfer": {
      "gateway_id": "bank_transfer",
      "name": "التحويل البنكي",
      "supported_banks": [
        "NBE", "CIB", "ADIB", "QNB", "Banque Misr", "AAIB"
      ],
      "fees": "0%",
      "processing_time": "24-48 hours"
    }
  },
  "international_gateways": {
    "stripe": {
      "gateway_id": "stripe",
      "name": "Stripe",
      "supported_countries": ["US", "UK", "EU", "CA", "AU"],
      "fees": "2.9% + $0.30"
    },
    "paypal": {
      "gateway_id": "paypal", 
      "name": "PayPal",
      "fees": "3.4% + fixed_fee"
    }
  }
}
```

### 4.2 معالج الدفع الموحد (Unified Payment Processor)

```http
POST /api/payments/process
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "payment_type": "teacher_subscription|app_subscription|premium_features",
  "amount": 2500,
  "currency": "EGP",
  "gateway": "fawry",
  "payment_method": "mobile_wallet",
  "child_id": "child_789012",
  "subscription_details": {
    "teacher_id": "teacher_001",
    "plan_id": "monthly_premium",
    "start_date": "2024-01-20",
    "sessions_count": 12
  },
  "billing_info": {
    "name": "أحمد محمد علي",
    "email": "parent@example.com",
    "phone": "+201234567890",
    "address": {
      "street": "شارع التحرير",
      "city": "القاهرة",
      "country": "EG"
    }
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء طلب الدفع بنجاح",
  "data": {
    "payment_id": "pay_123456789",
    "gateway_response": {
      "fawry_reference": "FWY123456789",
      "payment_code": "123456789",
      "expiry_time": "2024-01-20T23:59:59Z",
      "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
      "instructions": {
        "ar": "ادفع باستخدام رقم الكود: 123456789 في أي فرع فوري أو تطبيق فوري",
        "en": "Pay using code: 123456789 at any Fawry branch or Fawry app"
      }
    },
    "payment_status": "pending",
    "callback_url": "https://app.example.com/payment-callback",
    "webhook_url": "https://api.example.com/webhooks/payment"
  }
}
```

### 4.3 تأكيد الدفع والـ Webhook

```http
POST /api/webhooks/payment-confirmation
Content-Type: application/json
X-Gateway-Signature: sha256=...

{
  "event_type": "payment.completed",
  "payment_id": "pay_123456789",
  "gateway": "fawry",
  "status": "completed",
  "amount": 2500,
  "currency": "EGP",
  "gateway_transaction_id": "FWY123456789",
  "completed_at": "2024-01-20T14:30:00Z",
  "fees": 62.50
}
```

### 4.4 تاريخ المدفوعات والفواتير

```http
GET /api/parent/payments
Authorization: Bearer {access_token}
Query Parameters:
- status: completed|pending|failed
- date_from: 2024-01-01
- date_to: 2024-01-31
- type: teacher_subscription|app_subscription
```

## 5. نظام التقارير والإحصائيات المتقدم

### 5.1 لوحة معلومات ولي الأمر الرئيسية

```http
GET /api/parent/dashboard
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "active_children": 2,
      "total_study_hours_this_month": 45.5,
      "words_learned_this_month": 156,
      "active_subscriptions": {
        "teachers": 1,
        "premium_features": true
      },
      "upcoming_sessions": 3
    },
    "children_summary": [
      {
        "child_id": "child_789012",
        "name": "محمد أحمد",
        "today_progress": {
          "study_time": 25,
          "games_played": 3,
          "accuracy": 88,
          "mood": "happy"
        },
        "weekly_trend": "improving",
        "current_level": 3,
        "next_milestone": "إكمال 200 كلمة"
      }
    ],
    "recent_achievements": [
      {
        "child_name": "محمد أحمد",
        "achievement": "أسبوع متتالي من التعلم",
        "date": "2024-01-20",
        "badge_url": "https://storage.app.com/badges/week_streak.png"
      }
    ],
    "teacher_updates": [
      {
        "teacher_name": "د. سارة أحمد",
        "child_name": "محمد أحمد",
        "message": "تحسن ملحوظ في النطق هذا الأسبوع",
        "date": "2024-01-19"
      }
    ],
    "recommendations": [
      {
        "type": "study_schedule",
        "message": "وقت الدراسة المثالي لمحمد هو الساعة 4 مساءً",
        "priority": "high"
      },
      {
        "type": "content",
        "message": "محمد مستعد لمستوى صعوبة أعلى في ألعاب التهجي",
        "priority": "medium"
      }
    ]
  }
}
```

### 5.2 تقارير التقدم المقارنة

```http
GET /api/parent/progress-comparison
Authorization: Bearer {access_token}
Query Parameters:
- child_id: child_789012
- comparison_type: peer_group|previous_period|siblings
- period: month|quarter
```

**Response:**
```json
{
  "success": true,
  "data": {
    "child_performance": {
      "child_id": "child_789012",
      "current_metrics": {
        "words_learned": 156,
        "average_accuracy": 88,
        "study_consistency": 0.85,
        "engagement_score": 92
      }
    },
    "peer_comparison": {
      "age_group": "6-7 years",
      "total_peers": 1247,
      "child_rank": 156,
      "percentile": 87,
      "benchmarks": {
        "words_learned": {
          "child_value": 156,
          "peer_average": 124,
          "top_10_percent": 180,
          "status": "above_average"
        },
        "accuracy": {
          "child_value": 88,
          "peer_average": 82,
          "top_10_percent": 94,
          "status": "above_average"
        }
      }
    },
    "improvement_areas": [
      "زيادة وقت الدراسة اليومي",
      "التركيز على ألعاب بناء الجمل"
    ],
    "strengths": [
      "النطق الممتاز",
      "حفظ المفردات بسرعة"
    ]
  }
}
```

## 6. نظام الألعاب والمحتوى

### 6.1 الحصول على ألعاب مخصصة

```http
GET /api/games/personalized
Authorization: Bearer {access_token}
Query Parameters:
- child_id: child_789012
- difficulty: auto|beginner|intermediate|advanced
- focus_area: vocabulary|pronunciation|grammar|spelling
```

### 6.2 حفظ نتائج الألعاب

```http
POST /api/games/results
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "child_id": "child_789012",
  "game_type": "word_matching",
  "session_id": "session_123",
  "start_time": "2024-01-20T16:00:00Z",
  "end_time": "2024-01-20T16:15:00Z",
  "duration": 15,
  "performance": {
    "correct_answers": 18,
    "wrong_answers": 2,
    "skipped_answers": 1,
    "total_questions": 21,
    "accuracy": 90,
    "score": 1800
  },
  "words_practiced": [
    {"word": "cat", "attempts": 1, "correct": true, "response_time": 2.3},
    {"word": "dog", "attempts": 2, "correct": true, "response_time": 3.1}
  ],
  "difficulty_level": "beginner",
  "game_settings": {
    "timer_enabled": true,
    "hints_enabled": false,
    "voice_guidance": true
  }
}
```

## 7. نظام الإشعارات المتقدم

### 7.1 إعدادات الإشعارات

```http
PUT /api/parent/notification-settings
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "email_notifications": {
    "enabled": true,
    "daily_reports": true,
    "weekly_summaries": true,
    "achievement_alerts": true,
    "payment_reminders": true,
    "teacher_messages": true
  },
  "push_notifications": {
    "enabled": true,
    "study_reminders": true,
    "session_reminders": true,
    "achievement_celebrations": true,
    "low_activity_alerts": true
  },
  "sms_notifications": {
    "enabled": false,
    "emergency_only": true
  },
  "quiet_hours": {
    "start": "20:00",
    "end": "08:00",
    "timezone": "Africa/Cairo"
  },
  "frequency": {
    "daily_summary": "18:00",
    "weekly_report": "friday_18:00"
  }
}
```

## 8. نظام الإدارة (Admin System)

### 8.1 لوحة معلومات الإدارة

```http
GET /api/admin/dashboard
Authorization: Bearer {admin_access_token}
```

### 8.2 إحصائيات النظام الشاملة

```http
GET /api/admin/system-stats
Authorization: Bearer {admin_access_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "users": {
      "total_parents": 15420,
      "total_children": 28156,
      "total_teachers": 342,
      "active_this_month": 12458,
      "new_registrations_this_month": 1456
    },
    "engagement": {
      "daily_active_users": 5678,
      "average_session_duration": 18.5,
      "games_played_today": 15678,
      "words_learned_today": 45623
    },
    "revenue": {
      "monthly_revenue": 456780,
      "teacher_subscriptions_revenue": 345678,
      "app_subscriptions_revenue": 111102,
      "revenue_by_gateway": {
        "fawry": 234567,
        "vodafone_cash": 123456,
        "bank_transfer": 98765
      }
    },
    "teacher_metrics": {
      "average_rating": 4.6,
      "total_sessions_completed": 5678,
      "teacher_earnings": 234567
    }
  }
}
```

## 9. الأمان والخصوصية

### 9.1 حماية بيانات الأطفال

```json
{
  "privacy_measures": {
    "data_encryption": "AES-256",
    "api_encryption": "TLS 1.3",
    "data_anonymization": true,
    "parental_consent_required": true,
    "data_retention_policy": "delete_after_account_closure",
    "third_party_sharing": false,
    "coppa_compliance": true,
    "gdpr_compliance": true
  },
  "security_features": {
    "jwt_token_expiry": 3600,
    "refresh_token_rotation": true,
    "rate_limiting": "100_requests_per_minute",
    "ip_whitelisting": false,
    "two_factor_auth": "optional",
    "session_timeout": 1800
  }
}
```

## 10. متطلبات التشغيل

### 10.1 البيئة التقنية المطلوبة

```yaml
backend_requirements:
  python_version: "3.11+"
  framework: "Flask 3.0+"
  database: 
    primary: "PostgreSQL 15+"
    cache: "Redis 7+"
    search: "Elasticsearch 8+"
  storage:
    files: "AWS S3 Compatible"
    cdn: "CloudFlare"
  queue_system: "Celery + Redis"
  monitoring: "Prometheus + Grafana"
  
external_services:
  payment_gateways:
    - Fawry API
    - Vodafone Cash API
    - We Pay API
    - Stripe API
    - PayPal API
  communication:
    - Firebase Cloud Messaging
    - Twilio (SMS)
    - SendGrid (Email)
  ai_services:
    - Speech-to-Text API
    - Text-to-Speech API
    - Translation API
```

### 10.2 معدلات الـ API والحدود

```json
{
  "rate_limits": {
    "authentication": "5 requests per minute",
    "general_api": "100 requests per minute",
    "file_upload": "10 uploads per minute",
    "payment_processing": "3 requests per minute"
  },
  "data_limits": {
    "file_upload_size": "10MB",
    "children_per_parent": 4,
    "session_duration": "60 minutes",
    "daily_api_calls": 10000
  }
}
```

---

## مخطط قاعدة البيانات المقترح

### الجداول الرئيسية

```sql
-- Parents Table
CREATE TABLE parents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    country_code VARCHAR(5),
    preferred_language VARCHAR(10) DEFAULT 'ar',
    subscription_status VARCHAR(20) DEFAULT 'free',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Children Table  
CREATE TABLE children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES parents(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    age INTEGER NOT NULL,
    grade_level VARCHAR(20),
    learning_language VARCHAR(10) DEFAULT 'en',
    native_language VARCHAR(10) DEFAULT 'ar',
    profile_picture_url TEXT,
    difficulty_level VARCHAR(20) DEFAULT 'beginner',
    daily_goals INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Teachers Table
CREATE TABLE teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    bio TEXT,
    specialization TEXT[],
    experience_years INTEGER,
    hourly_rate DECIMAL(10,2),
    currency VARCHAR(5) DEFAULT 'EGP',
    rating DECIMAL(3,2) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions Table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES parents(id),
    child_id UUID REFERENCES children(id),
    teacher_id UUID REFERENCES teachers(id),
    plan_id VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    sessions_total INTEGER,
    sessions_used INTEGER DEFAULT 0,
    amount DECIMAL(10,2),
    currency VARCHAR(5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Game Sessions Table
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID REFERENCES children(id),
    game_type VARCHAR(50),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration INTEGER, -- in seconds
    score INTEGER,
    accuracy DECIMAL(5,2),
    correct_answers INTEGER,
    wrong_answers INTEGER,
    words_practiced JSONB,
    difficulty_level VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments Table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES parents(id),
    subscription_id UUID REFERENCES subscriptions(id),
    amount DECIMAL(10,2),
    currency VARCHAR(5),
    gateway VARCHAR(50),
    gateway_transaction_id VARCHAR(255),
    status VARCHAR(20),
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);
```

هذا المستند الشامل يغطي جميع جوانب النظام المطلوب. هل تريد مني الآن البدء في إصلاح الأخطاء الموجودة في التطبيق؟