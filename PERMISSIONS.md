# دليل الصلاحيات - تطبيق تعلم الكلمات للأطفال

## الصلاحيات المضافة في AndroidManifest.xml

### 1. صلاحيات الإنترنت والشبكة
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```
**الغرض:** 
- الاتصال بـ Firebase للمصادقة
- استدعاء APIs للترجمة
- تحميل المحتوى والصور
- التحقق من حالة الاتصال

### 2. صلاحيات الصوت والمايكروفون
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MICROPHONE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```
**الغرض:**
- التعرف على الكلام (Speech to Text)
- تسجيل نطق الأطفال لتقييم النطق
- تشغيل الأصوات والموسيقى
- منع إيقاف الجهاز أثناء التشغيل

### 3. صلاحيات التخزين
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```
**الغرض:**
- حفظ الملفات الصوتية المحملة
- تخزين بيانات التقدم
- حفظ الصور والرسوم المتحركة

### 4. صلاحيات إضافية
```xml
<uses-permission android:name="android.permission.VIBRATE" />
```
**الغرض:**
- ردود فعل لمسية للأطفال
- تحسين تجربة المستخدم

## كيفية استخدام الصلاحيات في الكود

### 1. خدمة الصلاحيات (PermissionService)
```dart
final permissionService = PermissionService();

// طلب صلاحية المايكروفون
final hasPermission = await permissionService.requestMicrophonePermission();

// طلب صلاحية مع حوار توضيحي
final hasPermission = await permissionService.requestMicrophoneWithDialog(context);
```

### 2. استخدام Provider للصلاحيات
```dart
// في Widget
final permissionState = ref.watch(permissionProvider);
final permissionNotifier = ref.read(permissionProvider.notifier);

// طلب صلاحية
await permissionNotifier.requestMicrophone(context: context);
```

### 3. استخدام Permission Widgets
```dart
// لصلاحية المايكروفون فقط
MicrophonePermissionWidget(
  child: YourWidget(),
  onPermissionGranted: () => print('تم منح الصلاحية'),
  onPermissionDenied: () => print('تم رفض الصلاحية'),
)

// لصلاحيات متعددة
MultiplePermissionsWidget(
  child: YourWidget(),
  onPermissionGranted: () => print('تم منح جميع الصلاحيات'),
)
```

## أمثلة الاستخدام

### 1. في لعبة النطق
```dart
void _startListening() async {
  final permissionNotifier = ref.read(permissionProvider.notifier);
  final hasPermission = await permissionNotifier.requestMicrophone(context: context);
  
  if (!hasPermission) {
    // عرض رسالة خطأ
    return;
  }
  
  // بدء الاستماع
  await audioService.startListening(context: context);
}
```

### 2. في الشاشة الرئيسية
```dart
@override
Widget build(BuildContext context) {
  return AppPermissionWrapper(
    child: MainApp(),
  );
}
```

## إعدادات إضافية

### 1. Network Security Config
تم إنشاء ملف `network_security_config.xml` للسماح بـ:
- الاتصالات المحلية للتطوير
- APIs الترجمة
- Firebase

### 2. Proguard Rules
تم إنشاء ملف `proguard-rules.pro` لحماية:
- Flutter framework
- Firebase
- Audio libraries
- Model classes

### 3. Gradle Optimizations
تم إضافة تحسينات في `gradle.properties`:
- تحسين الأداء
- تفعيل R8
- تحسين البناء

## نصائح مهمة

### 1. طلب الصلاحيات في الوقت المناسب
- لا تطلب جميع الصلاحيات عند بدء التطبيق
- اطلب الصلاحية عند الحاجة إليها فقط
- اشرح للمستخدم سبب الحاجة للصلاحية

### 2. التعامل مع رفض الصلاحيات
- وفر بدائل عند رفض الصلاحيات الاختيارية
- اشرح كيفية تفعيل الصلاحية من الإعدادات
- لا تجعل التطبيق غير قابل للاستخدام

### 3. اختبار الصلاحيات
- اختبر التطبيق مع وبدون الصلاحيات
- تأكد من عمل البدائل بشكل صحيح
- اختبر على أجهزة مختلفة وإصدارات Android مختلفة

## الصلاحيات حسب الميزة

| الميزة | الصلاحيات المطلوبة | نوع الصلاحية |
|--------|-------------------|---------------|
| لعبة النطق | MICROPHONE, RECORD_AUDIO | مطلوبة |
| تشغيل الأصوات | MODIFY_AUDIO_SETTINGS, WAKE_LOCK | مطلوبة |
| حفظ التقدم | WRITE_EXTERNAL_STORAGE | مطلوبة |
| التقاط الصور | CAMERA | اختيارية |
| الترجمة | INTERNET, ACCESS_NETWORK_STATE | مطلوبة |
| Firebase | INTERNET | مطلوبة |

## استكشاف الأخطاء

### 1. الصلاحية مرفوضة نهائياً
```dart
final status = await Permission.microphone.status;
if (status.isPermanentlyDenied) {
  // فتح إعدادات التطبيق
  await openAppSettings();
}
```

### 2. الصلاحية غير متاحة على الجهاز
```dart
if (!await Permission.microphone.isRestricted) {
  // الصلاحية متاحة
}
```

### 3. التحقق من إصدار Android
```dart
// للصلاحيات التي تتطلب إصدارات معينة
if (Platform.isAndroid) {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  if (androidInfo.version.sdkInt >= 23) {
    // طلب الصلاحية
  }
}
```