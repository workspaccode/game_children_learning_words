import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/providers/words_provider.dart';

import '../../models/subscription_model.dart';
import '../../models/user_model.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      // FutureProviders load automatically when watched
      ref.read(parentChildrenProvider.notifier).loadChildren(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final stats = ref.watch(parentStatsProvider);
    final children = ref.watch(parentChildrenProvider);
    final subscriptions = ref.watch(parentSubscriptionsProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('مرحباً، ${user.displayName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showNotifications,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('الملف الشخصي'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('الإعدادات'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout_outlined),
                  title: Text('تسجيل الخروج'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboardData(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              _buildStatsCards(stats),
              SizedBox(height: 24.h),

              // Children Section
              _buildSectionHeader('أطفالي', Icons.child_care),
              SizedBox(height: 12.h),
              _buildChildrenSection(children),
              SizedBox(height: 24.h),

              // Subscriptions Section
              _buildSectionHeader('الاشتراكات', Icons.payment),
              SizedBox(height: 12.h),
              _buildSubscriptionsSection(subscriptions),
              SizedBox(height: 24.h),

              // Quick Actions
              _buildSectionHeader('إجراءات سريعة', Icons.flash_on),
              SizedBox(height: 12.h),
              _buildQuickActions(),
              SizedBox(height: 24.h),

              // Recent Activity
              _buildSectionHeader('الأنشطة الحديثة', Icons.timeline),
              SizedBox(height: 12.h),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddChildDialog,
        icon: const Icon(Icons.child_friendly),
        label: const Text('إضافة طفل'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStatsCards(AsyncValue<Map<String, dynamic>> stats) {
    return stats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('خطأ: $error'),
      data: (data) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'الأطفال',
              '${data['total_children'] ?? 0}',
              Icons.child_care,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'الأنشطة اليوم',
              '${data['today_activities'] ?? 0}',
              Icons.assignment,
              Colors.green,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'مُكتمل',
              '${((data['completion_rate'] ?? 0.0) * 100).toInt()}%',
              Icons.check_circle,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: Theme.of(context).primaryColor),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _navigateToSection(title),
          child: const Text('عرض الكل'),
        ),
      ],
    );
  }

  Widget _buildChildrenSection(AsyncValue<List<UserModel>> children) {
    return children.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('خطأ: $error'),
      data: (childrenList) => childrenList.isEmpty
          ? _buildEmptyState('لم تضف أي طفل بعد', 'اضغط لإضافة طفل جديد')
          : SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: childrenList.length,
                itemBuilder: (context, index) =>
                    _buildChildCard(childrenList[index]),
              ),
            ),
    );
  }

  Widget _buildChildCard(UserModel child) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _viewChildDetails(child),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              CircleAvatar(
                radius: 25.w,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                backgroundImage: child.profileImageUrl != null
                    ? NetworkImage(child.profileImageUrl!)
                    : null,
                child: child.profileImageUrl == null
                    ? Text(
                        child.initials,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 8.h),
              Text(
                child.displayName,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (child.age != null)
                Text(
                  '${child.age} سنة',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionsSection(
    AsyncValue<List<SubscriptionModel>> subscriptions,
  ) {
    return subscriptions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('خطأ: $error'),
      data: (subsList) => subsList.isEmpty
          ? _buildEmptyState('لا توجد اشتراكات', 'ابدأ اشتراك جديد مع معلم')
          : Column(
              children: subsList.take(2).map(_buildSubscriptionCard).toList(),
            ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: subscription.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              color: subscription.isActive ? Colors.green : Colors.grey,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلم: ${subscription.teacherId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${subscription.subscriptionType == SubscriptionType.monthly ? "شهري" : "نصف سنوي"} - ${subscription.amount} ريال',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(
                  subscription.isActive ? 'نشط' : 'منتهي',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: subscription.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (subscription.isActive)
            Chip(
              label: Text('${subscription.remainingDays} يوم'),
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: Colors.orange, fontSize: 10.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'إضافة طفل',
        'icon': Icons.child_friendly,
        'color': Colors.blue,
        'action': _showAddChildDialog,
      },
      {
        'title': 'اشتراك جديد',
        'icon': Icons.payment,
        'color': Colors.green,
        'action': _showSubscriptionDialog,
      },
      {
        'title': 'تقرير التقدم',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'action': _showProgressReport,
      },
      {
        'title': 'إعدادات',
        'icon': Icons.settings,
        'color': Colors.orange,
        'action': _openSettings,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: action['action']! as VoidCallback,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon']! as IconData,
                  size: 32.w,
                  color: action['color']! as Color,
                ),
                SizedBox(height: 8.h),
                Text(
                  action['title']! as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    // Mock data for now
    final activities = [
      {
        'child': 'أحمد',
        'activity': 'أكمل لعبة المطابقة',
        'time': 'منذ 10 دقائق',
      },
      {
        'child': 'فاطمة',
        'activity': 'حصل على 5 نجوم في القراءة',
        'time': 'منذ ساعة',
      },
      {'child': 'محمد', 'activity': 'بدأ درس جديد', 'time': 'منذ ساعتين'},
    ];

    return Column(children: activities.map(_buildActivityItem).toList());
  }

  Widget _buildActivityItem(Map<String, String> activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.w,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Text(
              activity['child']![0],
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['activity']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity['time']!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48.w, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // TODO: Implement notifications
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        context.pushNamed('profile');
        break;
      case 'settings':
        context.pushNamed('settings');
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _navigateToSection(String section) {
    switch (section) {
      case 'أطفالي':
        context.pushNamed('children_management');
        break;
      case 'الاشتراكات':
        context.pushNamed('subscriptions');
        break;
      // Add more navigation cases
    }
  }

  void _viewChildDetails(UserModel child) {
    context.pushNamed('child_details', pathParameters: {'childId': child.id});
  }

  void _showAddChildDialog() {
    showDialog(context: context, builder: (context) => const AddChildDialog());
  }

  void _showSubscriptionDialog() {
    context.pushNamed('subscription_plans');
  }

  void _showProgressReport() {
    context.pushNamed('progress_report');
  }

  void _openSettings() {
    context.pushNamed('settings');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = ref.read(authStateProvider.notifier);
              authService.signOut();
              if (context.mounted) {
                context.goNamed('login');
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class AddChildDialog extends ConsumerStatefulWidget {
  const AddChildDialog({super.key});

  @override
  ConsumerState<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends ConsumerState<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة طفل جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الطفل',
                hintText: 'أدخل اسم الطفل',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'الرجاء إدخال اسم الطفل';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'العمر',
                hintText: 'أدخل عمر الطفل',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(onPressed: _addChild, child: const Text('إضافة')),
      ],
    );
  }

  Future<void> _addChild() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement add child functionality
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إضافة الطفل بنجاح!')));
    }
  }
}
