import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  factory PermissionService() => _instance;
  PermissionService._internal();
  static final PermissionService _instance = PermissionService._internal();

  Future<void> inits() async {
    Future.wait(
      [
        requestMicrophonePermission(),
        requestCameraPermission(),
        requestStoragePermission(),
        requestPhotosPermission(),
        
      ]

    );
  }

  /// طلب صلاحية المايكروفون
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('خطأ في طلب صلاحية المايكروفون: $e');
      return false;
    }
  }

  /// طلب صلاحية الكاميرا
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('خطأ في طلب صلاحية الكاميرا: $e');
      return false;
    }
  }

  /// طلب صلاحية التخزين
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('خطأ في طلب صلاحية التخزين: $e');
      return false;
    }
  }

  /// طلب صلاحية الصور
  Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('خطأ في طلب صلاحية الصور: $e');
      return false;
    }
  }

  /// التحقق من صلاحية المايكروفون
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// التحقق من صلاحية الكاميرا
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  /// التحقق من صلاحية التخزين
  Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }

  /// التحقق من صلاحية الصور
  Future<bool> checkPhotosPermission() async {
    final status = await Permission.photos.status;
    return status == PermissionStatus.granted;
  }

  /// طلب صلاحيات متعددة
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    try {
      return await permissions.request();
    } catch (e) {
      debugPrint('خطأ في طلب الصلاحيات المتعددة: $e');
      return {};
    }
  }

  /// التحقق من حالة الصلاحية
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return permission.status;
  }

  /// فتح إعدادات التطبيق
  Future<bool> openAppSettingsAsynchronous() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('خطأ في فتح إعدادات التطبيق: $e');
      return false;
    }
  }

  /// عرض حوار طلب الصلاحية مع رسالة توضيحية
  Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Permission permission,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      final status = await permission.request();
      return status == PermissionStatus.granted;
    }

    return false;
  }

  /// طلب صلاحية المايكروفون مع حوار توضيحي
  Future<bool> requestMicrophoneWithDialog(BuildContext context) async {
    final hasPermission = await checkMicrophonePermission();
    if (hasPermission) return true;

    return showPermissionDialog(
      context: context,
      title: 'صلاحية المايكروفون',
      message:
          'يحتاج التطبيق إلى صلاحية المايكروفون للتعرف على صوتك وتحسين تجربة التعلم.',
      permission: Permission.microphone,
    );
  }

  /// طلب صلاحية الكاميرا مع حوار توضيحي
  Future<bool> requestCameraWithDialog(BuildContext context) async {
    final hasPermission = await checkCameraPermission();
    if (hasPermission) return true;

    return showPermissionDialog(
      context: context,
      title: 'صلاحية الكاميرا',
      message:
          'يحتاج التطبيق إلى صلاحية الكاميرا لالتقاط الصور والتفاعل مع المحتوى.',
      permission: Permission.camera,
    );
  }

  /// طلب صلاحية التخزين مع حوار توضيحي
  Future<bool> requestStorageWithDialog(BuildContext context) async {
    final hasPermission = await checkStoragePermission();
    if (hasPermission) return true;

    return showPermissionDialog(
      context: context,
      title: 'صلاحية التخزين',
      message: 'يحتاج التطبيق إلى صلاحية التخزين لحفظ التقدم والملفات الصوتية.',
      permission: Permission.storage,
    );
  }

  /// عرض حوار عند رفض الصلاحية نهائياً
  Future<void> showPermissionDeniedDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'يمكنك تفعيل الصلاحية من إعدادات التطبيق.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        );
      },
    );
  }

  /// التحقق من جميع الصلاحيات المطلوبة للتطبيق
  Future<Map<String, bool>> checkAllRequiredPermissions() async {
    return {
      'microphone': await checkMicrophonePermission(),
      'camera': await checkCameraPermission(),
      'storage': await checkStoragePermission(),
      'photos': await checkPhotosPermission(),
    };
  }

  /// طلب جميع الصلاحيات المطلوبة
  Future<bool> requestAllRequiredPermissions(BuildContext context) async {
    final permissions = [
      Permission.microphone,
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ];

    final statuses = await requestMultiplePermissions(permissions);

    // التحقق من النتائج
    bool allGranted = true;
    for (final entry in statuses.entries) {
      if (entry.value != PermissionStatus.granted) {
        allGranted = false;
        break;
      }
    }

    return allGranted;
  }
}
