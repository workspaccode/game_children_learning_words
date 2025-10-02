import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';

import '../../models/user_model.dart';
import '../../providers/parent_provider.dart';
import '../../services/auth_service.dart';

class ChildrenManagementScreen extends StatefulWidget {
  const ChildrenManagementScreen({super.key});

  @override
  State<ChildrenManagementScreen> createState() => _ChildrenManagementScreenState();}
     


class _ChildrenManagementScreenState
    extends State<ChildrenManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
    });
  }

  void _loadChildren() {
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      ref.read(parentChildrenProvider.notifier).loadChildren(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final children = ref.watch(parentChildrenProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('إدارة الأطفال'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadChildren(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(),
              SizedBox(height: 24.h),

              // Children List
              _buildChildrenSection(children, user?.id),
              SizedBox(height: 24.h),

              // Guidelines Card
              _buildGuidelinesCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _checkAndAddChild(user?.id),
        icon: const Icon(Icons.child_friendly),
        label: const Text('إضافة طفل'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.family_restroom, color: Colors.white, size: 32.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أطفالي',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'إدارة حسابات الأطفال ومتابعة تقدمهم',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 16.w),
                SizedBox(width: 8.w),
                Text(
                  'يمكنك إضافة حتى 4 أطفال كحد أقصى',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection(
    AsyncValue<List<UserModel>> children,
    String? parentId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.child_care,
              color: Theme.of(context).primaryColor,
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'قائمة الأطفال',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        children.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorCard(error.toString()),
          data: (childrenList) => childrenList.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: childrenList
                      .map((child) => _buildChildCard(child, parentId))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildChildCard(UserModel child, String? parentId) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.w,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                backgroundImage: child.profileImageUrl != null
                    ? NetworkImage(child.profileImageUrl!)
                    : null,
                child: child.profileImageUrl == null
                    ? Text(
                        child.initials,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.displayName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (child.age != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${child.age} سنة',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: child.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                child.isActive
                                    ? Icons.check_circle
                                    : Icons.pause_circle,
                                size: 12.w,
                                color: child.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                child.isActive ? 'نشط' : 'متوقف',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: child.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleChildAction(value, child, parentId),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(Icons.visibility),
                      title: Text('عرض التفاصيل'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('تعديل البيانات'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'activities',
                    child: ListTile(
                      leading: Icon(Icons.assignment),
                      title: Text('الأنشطة'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'progress',
                    child: ListTile(
                      leading: Icon(Icons.analytics),
                      title: Text('تقرير التقدم'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: child.isActive ? 'deactivate' : 'activate',
                    child: ListTile(
                      leading: Icon(
                        child.isActive ? Icons.pause : Icons.play_arrow,
                        color: child.isActive ? Colors.orange : Colors.green,
                      ),
                      title: Text(
                        child.isActive ? 'إيقاف مؤقت' : 'تنشيط',
                        style: TextStyle(
                          color: child.isActive ? Colors.orange : Colors.green,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('حذف', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'عرض التقدم',
                  Icons.trending_up,
                  Colors.green,
                  () => _viewChildProgress(child),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionButton(
                  'الأنشطة',
                  Icons.assignment,
                  Colors.blue,
                  () => _viewChildActivities(child),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.w, color: color),
            SizedBox(width: 4.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_friendly,
              size: 48.w,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'لم تضف أي طفل بعد',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ بإضافة أول طفل لك لمتابعة رحلته التعليمية',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () =>
                _checkAndAddChild(ref.read(authStateProvider).user?.id),
            icon: const Icon(Icons.add),
            label: const Text('إضافة طفل الآن'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  error,
                  style: TextStyle(fontSize: 12.sp, color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'نصائح مهمة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._buildGuidelineItems([
            'يمكنك إضافة حتى 4 أطفال كحد أقصى لكل حساب ولي أمر',
            'تأكد من دقة البيانات المدخلة لضمان أفضل تجربة تعليمية',
            'راقب تقدم طفلك يومياً من خلال تقارير التقدم',
            'تواصل مع المعلمين لمتابعة أداء طفلك',
            'يمكنك إيقاف حساب الطفل مؤقتاً دون فقدان البيانات',
          ]),
        ],
      ),
    );
  }

  List<Widget> _buildGuidelineItems(List<String> guidelines) {
    return guidelines.map((guideline) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 6.h, left: 8.w),
              width: 4.w,
              height: 4.h,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                guideline,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _checkAndAddChild(String? parentId) async {
    if (parentId == null) return;

    // Check if parent can add more children
    final canAdd = await ref
        .read(parentChildrenProvider.notifier)
        .canAddMoreChildren(parentId);

    if (!canAdd) {
      _showMaxChildrenDialog();
      return;
    }

    _showAddChildDialog(parentId);
  }

  void _showAddChildDialog(String parentId) {
    showDialog(
      context: context,
      builder: (context) => AddChildDialog(parentId: parentId),
    );
  }

  void _showMaxChildrenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تجاوز الحد الأقصى'),
        content: const Text(
          'لقد وصلت إلى الحد الأقصى لعدد الأطفال (4 أطفال).\n'
          'يمكنك حذف أحد الأطفال غير النشطين لإضافة طفل جديد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  void _handleChildAction(String action, UserModel child, String? parentId) {
    if (parentId == null) return;

    switch (action) {
      case 'view':
        _viewChildDetails(child);
        break;
      case 'edit':
        _editChild(child);
        break;
      case 'activities':
        _viewChildActivities(child);
        break;
      case 'progress':
        _viewChildProgress(child);
        break;
      case 'activate':
      case 'deactivate':
        _toggleChildStatus(child, parentId);
        break;
      case 'delete':
        _confirmDeleteChild(child, parentId);
        break;
    }
  }

  void _viewChildDetails(UserModel child) {
    context.pushNamed('child_details', pathParameters: {'childId': child.id});
  }

  void _editChild(UserModel child) {
    context.pushNamed('edit_child', pathParameters: {'childId': child.id});
  }

  void _viewChildActivities(UserModel child) {
    context.pushNamed(
      'child_activities',
      pathParameters: {'childId': child.id},
    );
  }

  void _viewChildProgress(UserModel child) {
    context.pushNamed('child_progress', pathParameters: {'childId': child.id});
  }

  Future<void> _toggleChildStatus(UserModel child, String parentId) async {
    try {
      final updatedChild = child.copyWith(isActive: !child.isActive);
      // TODO: Implement update user in provider
      // await ref.read(parentChildrenProvider.notifier).updateChild(updatedChild);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم ${updatedChild.isActive ? 'تنشيط' : 'إيقاف'} حساب ${child.displayName}',
          ),
          backgroundColor: updatedChild.isActive ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteChild(UserModel child, String parentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف حساب الطفل'),
        content: Text(
          'هل أنت متأكد من حذف حساب "${child.displayName}"؟\n'
          'سيتم حذف جميع البيانات والتقدم نهائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteChild(child, parentId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChild(UserModel child, String parentId) async {
    try {
      await ref
          .read(parentChildrenProvider.notifier)
          .removeChild(parentId, child.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف حساب ${child.displayName} بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة'),
        content: const Text(
          'إدارة الأطفال:\n\n'
          '• يمكنك إضافة حتى 4 أطفال\n'
          '• يمكن تعديل بيانات الطفل في أي وقت\n'
          '• يمكن إيقاف الحساب مؤقتاً\n'
          '• تابع تقدم كل طفل من خلال التقارير\n'
          '• تواصل مع المعلمين لمتابعة الأداء',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }
}

class AddChildDialog extends ConsumerStatefulWidget {

  const AddChildDialog({super.key, required this.parentId});
  final String parentId;

  @override
  ConsumerState<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends ConsumerState<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة طفل جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الطفل',
                  hintText: 'أدخل اسم الطفل الكامل',
                  prefixIcon: Icon(Icons.child_friendly),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'الرجاء إدخال اسم الطفل';
                  }
                  if (value!.trim().length < 2) {
                    return 'اسم الطفل قصير جداً';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني (اختياري)',
                  hintText: 'child@example.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    if (!value!.contains('@') || !value.contains('.')) {
                      return 'تنسيق البريد الإلكتروني غير صحيح';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'العمر',
                  hintText: 'أدخل عمر الطفل بالسنوات',
                  prefixIcon: Icon(Icons.cake),
                  suffixText: 'سنة',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'الرجاء إدخال عمر الطفل';
                  }
                  final age = int.tryParse(value!);
                  if (age == null || age < 3 || age > 12) {
                    return 'يجب أن يكون العمر بين 3-12 سنة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'سيتم إنشاء حساب للطفل تلقائياً وربطه بحسابك',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addChild,
          child: _isLoading
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('إضافة'),
        ),
      ],
    );
  }

  Future<void> _addChild() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final childEmail = _emailController.text.trim().isEmpty
            ? '${_nameController.text.trim().toLowerCase().replaceAll(' ', '.')}@child.local'
            : _emailController.text.trim();

        final child = UserModel(
          id: 'child_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          email: childEmail,
          userType: UserType.child,
          age: int.parse(_ageController.text),
          parentId: widget.parentId,
          createdAt: DateTime.now(),
        );

        await ref
            .read(parentChildrenProvider.notifier)
            .addChild(widget.parentId, child);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة ${child.displayName} بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
