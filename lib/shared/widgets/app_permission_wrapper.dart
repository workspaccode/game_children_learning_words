import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


/// Widget يلف التطبيق بأكمله ويتحقق من الصلاحيات المطلوبة
class AppPermissionWrapper extends StatelessWidget {
  const AppPermissionWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context,  ) {
    final permissionState = context.read().watch<PermissionState>();
    final permissionNotifier = ref.read(permissionProvider.notifier);

    // إذا كانت الصلاحيات المطلوبة ممنوحة، عرض التطبيق
    if (permissionState.allRequiredGranted) {
      return child;
    }

    // إذا كان هناك تحميل، عرض شاشة التحميل
    if (permissionState.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'permissions.checkingPermissions'.tr(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // عرض شاشة طلب الصلاحيات
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // مساحة إضافية في الأعلى
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              // أيقونة التطبيق
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.school,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // عنوان التطبيق
              Text(
                'app.appName'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // وصف التطبيق
              Text(
                'app.appDescription'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // قائمة الصلاحيات المطلوبة
              _buildPermissionsList(permissionState, context),
              const SizedBox(height: 32),

              // زر طلب الصلاحيات
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      permissionNotifier.requestAllRequired(context: context),
                  icon: const Icon(Icons.security),
                  label: Text(
                    'permissions.grantPermissions'.tr(),
                    style: const TextStyle(fontSize: 18, fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // زر تخطي (للصلاحيات الاختيارية)
              TextButton(
                onPressed: permissionNotifier.skipOptionalPermissions,
                child: Text(
                  'permissions.skipOptional'.tr(),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                ),
              ),

              // رسالة الخطأ إن وجدت
              if (permissionState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          permissionState.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Cairo',
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

  Widget _buildPermissionsList(PermissionState state, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'permissions.title'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            'permissions.microphone'.tr(),
            'permissions.microphoneDesc'.tr(),
            state.microphoneGranted,
            Icons.mic,
          ),
          const SizedBox(height: 8),
          _buildPermissionItem(
            'permissions.storage'.tr(),
            'permissions.storageDesc'.tr(),
            state.storageGranted,
            Icons.storage,
          ),
          const SizedBox(height: 16),
          Text(
            'permissions.optionalPermissions'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              // color: Colors.grey,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          _buildPermissionItem(
            'permissions.camera'.tr(),
            'permissions.cameraDesc'.tr(),
            state.cameraGranted,
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isGranted
                ? Colors.green.withValues(alpha: 0.1)
                : (isOptional
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isGranted ? Icons.check : icon,
            color: isGranted
                ? Colors.green
                : (isOptional ? Colors.orange : Colors.red),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'permissions.optional'.tr(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
