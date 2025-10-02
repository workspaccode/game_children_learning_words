// Application Strings - Single source of truth for all text
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();
}

// Authentication Strings
class AuthStrings {
  static const String signUp = 'إنشاء حساب';
  static const String signIn = 'تسجيل الدخول';
  static const String signOut = 'تسجيل الخروج';
  static const String createAccount = 'إنشاء حساب جديد';
  static const String welcomeBack = 'مرحباً بعودتك';
  static const String forgotPassword = 'نسيت كلمة المرور؟';

  // Fields
  static const String name = 'الاسم الكامل';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String username = 'اسم المستخدم';
  static const String age = 'العمر';
  static const String parentEmail = 'بريد ولي الأمر';

  // User Types
  static const String userType = 'نوع المستخدم';
  static const String parent = 'ولي أمر';
  static const String teacher = 'معلم';
  static const String child = 'طفل';

  // Terms
  static const String termsOfService = 'الشروط والأحكام';
  static const String privacyPolicy = 'سياسة الخصوصية';
  static const String acceptTerms = 'أوافق على';
  static const String alreadyHaveAccount = 'لديك حساب بالفعل؟';
}

// Validation Messages
class ValidationStrings {
  static const String nameRequired = 'يرجى إدخال الاسم';
  static const String nameMinLength = 'الاسم يجب أن يكون حرفين على الأقل';
  static const String emailRequired = 'يرجى إدخال البريد الإلكتروني';
  static const String emailInvalid = 'البريد الإلكتروني غير صحيح';
  static const String passwordRequired = 'يرجى إدخال كلمة المرور';
  static const String passwordMinLength =
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  static const String passwordMismatch = 'كلمة المرور غير متطابقة';
  static const String usernameRequired = 'يرجى إدخال اسم المستخدم';
  static const String usernameMinLength =
      'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
  static const String usernameNoSpaces =
      'اسم المستخدم لا يجب أن يحتوي على مسافات';
  static const String ageRequired = 'يرجى إدخال العمر';
  static const String ageInvalid = 'العمر يجب أن يكون بين 3 و 18 سنة';
  static const String parentEmailRequired = 'يرجى إدخال بريد ولي الأمر';
  static const String termsRequired = 'يجب الموافقة على الشروط والأحكام';
}

// Error Messages
class ErrorStrings {
  static const String unexpected = 'حدث خطأ غير متوقع';
  static const String networkError = 'خطأ في الشبكة، يرجى المحاولة مرة أخرى';
  static const String parentNotFound =
      'لم يتم العثور على حساب ولي أمر بهذا البريد الإلكتروني';
  static const String parentCheckError = 'خطأ في التحقق من حساب ولي الأمر';
  static const String registrationFailed = 'فشل في إنشاء الحساب';
  static const String loginFailed = 'فشل في تسجيل الدخول';
}

// Success Messages
class SuccessStrings {
  const SuccessStrings();
  static const String registrationComplete = 'تم إنشاء الحساب بنجاح';
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String parentFound = 'تم العثور على حساب ولي الأمر';
}

// Common Strings
class CommonStrings {
  static const String loading = 'جاري التحميل...';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String complete = 'إكمال';
  static const String next = 'التالي';
  static const String previous = 'السابق';
  static const String done = 'تم';
  static const String retry = 'إعادة المحاولة';
}

// Hints
class HintStrings {
  static const String enterFullName = 'أدخل اسمك الكامل';
  static const String enterEmail = 'example@email.com';
  static const String enterPassword = '••••••••';
  static const String enterUsername = 'اختر اسم مستخدم فريد';
  static const String enterAge = '8';
  static const String enterParentEmail = 'parent@example.com';
}

// Tooltips
class TooltipStrings {
  static const String checkParent = 'التحقق من حساب ولي الأمر';
  static const String showPassword = 'إظهار كلمة المرور';
  static const String hidePassword = 'إخفاء كلمة المرور';
}
