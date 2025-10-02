import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/permission_service.dart';

class PermissionWidget extends StatefulWidget {
  const PermissionWidget({
    super.key,
    required this.child,
    required this.permissions,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.showDialog = true,
  });

  final Widget child;
  final List<Permission> permissions;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final bool showDialog;

  @override
  State<PermissionWidget> createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  final PermissionService _permissionService = PermissionService();
  bool _permissionsGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool allGranted = true;

    for (final permission in widget.permissions) {
      final status = await _permissionService.getPermissionStatus(permission);
      if (status != PermissionStatus.granted) {
        allGranted = false;
        break;
      }
    }

    setState(() {
      _permissionsGranted = allGranted;
      _isLoading = false;
    });

    if (allGranted) {
      widget.onPermissionGranted?.call();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final statuses = await _permissionService.requestMultiplePermissions(
      widget.permissions,
    );

    bool allGranted = true;
    for (final status in statuses.values) {
      if (status != PermissionStatus.granted) {
        allGranted = false;
        break;
      }
    }

    setState(() {
      _permissionsGranted = allGranted;
      _isLoading = false;
    });

    if (allGranted) {
      widget.onPermissionGranted?.call();
    } else {
      widget.onPermissionDenied?.call();
      if (widget.showDialog) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('صلاحيات مطلوبة'),
        content: const Text(
          'يحتاج التطبيق إلى هذه الصلاحيات للعمل بشكل صحيح. '
          'يمكنك تفعيلها من إعدادات التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _permissionService.openAppSettingsAsynchronous();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_permissionsGranted) {
      return _buildPermissionRequestWidget();
    }

    return widget.child;
  }

  Widget _buildPermissionRequestWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'صلاحيات مطلوبة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _getPermissionMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Icons.check),
              label: const Text('منح الصلاحيات'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPermissionMessage() {
    final permissionNames = <String>[];

    for (final permission in widget.permissions) {
      switch (permission) {
        case Permission.microphone:
          permissionNames.add('المايكروفون');
          break;
        case Permission.camera:
          permissionNames.add('الكاميرا');
          break;
        case Permission.storage:
          permissionNames.add('التخزين');
          break;
        case Permission.photos:
          permissionNames.add('الصور');
          break;
        default:
          permissionNames.add(permission.toString());
      }
    }

    if (permissionNames.length == 1) {
      return 'يحتاج التطبيق إلى صلاحية ${permissionNames.first} للعمل بشكل صحيح.';
    } else {
      final lastPermission = permissionNames.removeLast();
      return 'يحتاج التطبيق إلى صلاحيات ${permissionNames.join('، ')} و$lastPermission للعمل بشكل صحيح.';
    }
  }
}

/// Widget مبسط لطلب صلاحية المايكروفون
class MicrophonePermissionWidget extends StatelessWidget {
  const MicrophonePermissionWidget({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      permissions: const [Permission.microphone],
      onPermissionGranted: onPermissionGranted,
      onPermissionDenied: onPermissionDenied,
      child: child,
    );
  }
}

/// Widget مبسط لطلب صلاحية الكاميرا
class CameraPermissionWidget extends StatelessWidget {
  const CameraPermissionWidget({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      permissions: const [Permission.camera],
      onPermissionGranted: onPermissionGranted,
      onPermissionDenied: onPermissionDenied,
      child: child,
    );
  }
}

/// Widget لطلب صلاحيات متعددة
class MultiplePermissionsWidget extends StatelessWidget {
  const MultiplePermissionsWidget({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      permissions: const [
        Permission.microphone,
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ],
      onPermissionGranted: onPermissionGranted,
      onPermissionDenied: onPermissionDenied,
      child: child,
    );
  }
}
