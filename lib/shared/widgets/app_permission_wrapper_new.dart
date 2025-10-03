import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget يلف التطبيق بأكمله ويتحقق من الصلاحيات المطلوبة
class AppPermissionWrapper extends ConsumerStatefulWidget {
  const AppPermissionWrapper({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppPermissionWrapper> createState() => _AppPermissionWrapperState();
}

class _AppPermissionWrapperState extends ConsumerState<AppPermissionWrapper> {
  bool _isLoading = false;
  bool _microphoneGranted = false;
  bool _storageGranted = false;
  bool _cameraGranted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mock permission check - في التطبيق الحقيقي ستكون permission_handler
      await Future<void>.delayed(const Duration(seconds: 1));
      
      setState(() {
        _microphoneGranted = true; // Mock: assume granted
        _storageGranted = true;    // Mock: assume granted
        _cameraGranted = false;    // Mock: assume not granted (optional)
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في فحص الصلاحيات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool get _allRequiredGranted => _microphoneGranted && _storageGranted;

  @override
  Widget build(BuildContext context) {
    // إذا كانت الصلاحيات المطلوبة ممنوحة، عرض التطبيق
    if (_allRequiredGranted) {
      return widget.child;
    }

    // إذا كان هناك تحميل، عرض شاشة التحميل
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'فحص الصلاحيات...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // عرض شاشة طلب الصلاحيات
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // مساحة إضافية في الأعلى
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              // أيقونة التطبيق
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Icon(
                  Icons.school,
                  size: 60.w,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 32.h),

              // عنوان التطبيق
              Text(
                'ReadingQuest',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // وصف التطبيق
              Text(
                'تطبيق تعليمي تفاعلي لتعلم الكلمات باللغتين العربية والإنجليزية',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),

              // قائمة الصلاحيات المطلوبة
              _buildPermissionsList(),
              SizedBox(height: 32.h),

              // زر طلب الصلاحيات
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.security, color: Colors.white),
                  label: Text(
                    'منح الصلاحيات',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // زر تخطي (للصلاحيات الاختيارية)
              TextButton(
                onPressed: _skipOptionalPermissions,
                child: Text(
                  'تخطي الصلاحيات الاختيارية',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              // رسالة الخطأ إن وجدت
              if (_error != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // مساحة إضافية في الأسفل
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsList() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصلاحيات المطلوبة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Required permissions
          _buildPermissionItem(
            'الميكروفون',
            'لتسجيل النطق وتحسين التعلم',
            _microphoneGranted,
            Icons.mic,
          ),
          SizedBox(height: 12.h),
          _buildPermissionItem(
            'التخزين',
            'لحفظ التقدم والملفات الصوتية',
            _storageGranted,
            Icons.storage,
          ),
          
          SizedBox(height: 20.h),
          Text(
            'الصلاحيات الاختيارية',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
          ),
          SizedBox(height: 12.h),
          _buildPermissionItem(
            'الكاميرا',
            'لالتقاط الصور والتفاعل البصري',
            _cameraGranted,
            Icons.camera_alt,
            isOptional: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    String title,
    String description,
    bool isGranted,
    IconData icon, {
    bool isOptional = false,
  }) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: isGranted
                ? Colors.green.withValues(alpha: 0.1)
                : (isOptional
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(
            isGranted ? Icons.check_circle : icon,
            color: isGranted
                ? Colors.green
                : (isOptional ? Colors.orange : Colors.red),
            size: 24.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isOptional) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'اختيارية',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mock permission request - في التطبيق الحقيقي ستكون permission_handler
      await Future<void>.delayed(const Duration(seconds: 2));
      
      setState(() {
        _microphoneGranted = true;
        _storageGranted = true;
        _cameraGranted = true; // Grant camera too for demo
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم منح جميع الصلاحيات بنجاح!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'فشل في طلب الصلاحيات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _skipOptionalPermissions() {
    setState(() {
      _microphoneGranted = true;
      _storageGranted = true;
      // Keep camera as false (optional)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تخطي الصلاحيات الاختيارية'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
