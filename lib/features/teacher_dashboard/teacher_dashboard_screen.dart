import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';

import '../../models/classroom_model.dart';
import '../../models/subscription_model.dart';
import '../../models/user_model.dart';
import '../../providers/teacher_provider.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
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
      ref.read(teacherStatsProvider.notifier).loadStats(user.id);
      ref.read(teacherClassroomsProvider.notifier).loadClassrooms(user.id);
      ref
          .read(teacherSubscriptionsProvider.notifier)
          .loadSubscriptions(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final stats = ref.watch(teacherStatsProvider);
    final classrooms = ref.watch(teacherClassroomsProvider);
    final subscriptions = ref.watch(teacherSubscriptionsProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('أهلاً أستاذ ${user.displayName}'),
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
                value: 'earnings',
                child: ListTile(
                  leading: Icon(Icons.attach_money_outlined),
                  title: Text('الأرباح'),
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
              // Teacher Welcome Card
              _buildWelcomeCard(user),
              SizedBox(height: 24.h),

              // Statistics Cards
              _buildStatsCards(stats),
              SizedBox(height: 24.h),

              // Quick Actions
              _buildSectionHeader('إجراءات سريعة', Icons.flash_on),
              SizedBox(height: 12.h),
              _buildQuickActions(),
              SizedBox(height: 24.h),

              // Classrooms Section
              _buildSectionHeader('فصولي الدراسية', Icons.school),
              SizedBox(height: 12.h),
              _buildClassroomsSection(classrooms),
              SizedBox(height: 24.h),

              // Active Subscriptions
              _buildSectionHeader('الاشتراكات النشطة', Icons.payment),
              SizedBox(height: 12.h),
              _buildSubscriptionsSection(subscriptions),
              SizedBox(height: 24.h),

              // Recent Student Activity
              _buildSectionHeader('نشاط الطلاب الأخير', Icons.timeline),
              SizedBox(height: 12.h),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateClassroomDialog,
        icon: const Icon(Icons.add),
        label: const Text('فصل جديد'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.w,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                  'مرحباً ${user.displayName}!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'لنساعد الأطفال على التعلم اليوم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.school, color: Colors.white.withOpacity(0.7), size: 40.w),
        ],
      ),
    );
  }

  Widget _buildStatsCards(AsyncValue<Map<String, dynamic>> stats) {
    return stats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('خطأ: $error'),
      data: (data) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final stats = [
            {
              'title': 'الفصول',
              'value': '${data['total_classrooms'] ?? 0}',
              'icon': Icons.school,
              'color': Colors.blue,
            },
            {
              'title': 'الطلاب',
              'value': '${data['total_students'] ?? 0}',
              'icon': Icons.people,
              'color': Colors.green,
            },
            {
              'title': 'الاشتراكات',
              'value': '${data['active_subscriptions'] ?? 0}',
              'icon': Icons.payment,
              'color': Colors.orange,
            },
            {
              'title': 'الإيرادات',
              'value': '${(data['total_revenue'] ?? 0.0).toInt()} ريال',
              'icon': Icons.attach_money,
              'color': Colors.purple,
            },
          ];

          final stat = stats[index];
          return _buildStatCard(
            stat['title']! as String,
            stat['value']! as String,
            stat['icon']! as IconData,
            stat['color']! as Color,
          );
        },
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
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

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'فصل جديد',
        'icon': Icons.add_box,
        'color': Colors.blue,
        'action': _showCreateClassroomDialog,
      },
      {
        'title': 'إنشاء نشاط',
        'icon': Icons.assignment_add,
        'color': Colors.green,
        'action': _showCreateActivityDialog,
      },
      {
        'title': 'تقارير الطلاب',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'action': _viewStudentReports,
      },
      {
        'title': 'إعدادات الفصل',
        'icon': Icons.settings,
        'color': Colors.orange,
        'action': _openClassroomSettings,
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
                  color: Colors.black.withOpacity(0.05),
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

  Widget _buildClassroomsSection(AsyncValue<List<ClassroomModel>> classrooms) {
    return classrooms.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('خطأ: $error'),
      data: (classroomsList) => classroomsList.isEmpty
          ? _buildEmptyState('لم تنشئ أي فصل بعد', 'ابدأ بإنشاء فصل دراسي جديد')
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classroomsList.length,
              itemBuilder: (context, index) =>
                  _buildClassroomCard(classroomsList[index]),
            ),
    );
  }

  Widget _buildClassroomCard(ClassroomModel classroom) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _viewClassroomDetails(classroom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classroom.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${classroom.gradeLevelName} - ${classroom.subject}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (classroom.hasSchedule)
                  Chip(
                    label: Text('مجدول', style: TextStyle(fontSize: 10.sp)),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildInfoChip(
                  '${classroom.studentCount} طالب',
                  Icons.people,
                  Colors.blue,
                ),
                SizedBox(width: 8.w),
                if (classroom.isFull)
                  _buildInfoChip('مكتمل', Icons.warning, Colors.red),
                const Spacer(),
                Text(
                  classroom.description,
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          ? _buildEmptyState(
              'لا توجد اشتراكات نشطة',
              'انتظر انضمام أولياء الأمور',
            )
          : Column(
              children: subsList.take(3).map(_buildSubscriptionCard).toList(),
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
            color: Colors.black.withOpacity(0.05),
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
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom,
              color: subscription.isActive ? Colors.green : Colors.grey,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ولي أمر: ${subscription.parentId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${subscription.childrenIds.length} أطفال - ${subscription.amount} ريال',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (subscription.isActive)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  subscription.subscriptionType == SubscriptionType.monthly
                      ? 'شهري'
                      : 'نصف سنوي',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${subscription.remainingDays} يوم متبقي',
                  style: TextStyle(fontSize: 10.sp, color: Colors.orange),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Mock data for now
    final activities = [
      {
        'student': 'أحمد محمد',
        'activity': 'أكمل درس الحروف',
        'classroom': 'الصف الأول أ',
        'time': 'منذ 15 دقيقة',
      },
      {
        'student': 'فاطمة أحمد',
        'activity': 'حصل على 5 نجوم',
        'classroom': 'الصف الثاني ب',
        'time': 'منذ 30 دقيقة',
      },
      {
        'student': 'محمد علي',
        'activity': 'بدأ نشاط جديد',
        'classroom': 'الصف الأول أ',
        'time': 'منذ ساعة',
      },
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.w,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              activity['student']![0],
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
                  activity['student']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity['activity']!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                ),
                Text(
                  '${activity['classroom']} • ${activity['time']}',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
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
            color: Colors.black.withOpacity(0.05),
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
      case 'earnings':
        context.pushNamed('earnings');
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
      case 'فصولي الدراسية':
        context.pushNamed('classrooms_management');
        break;
      case 'الاشتراكات النشطة':
        context.pushNamed('teacher_subscriptions');
        break;
      // Add more navigation cases
    }
  }

  void _showCreateClassroomDialog() {
    context.pushNamed('create_classroom');
  }

  void _showCreateActivityDialog() {
    context.pushNamed('create_activity');
  }

  void _viewStudentReports() {
    context.pushNamed('student_reports');
  }

  void _openClassroomSettings() {
    context.pushNamed('classroom_settings');
  }

  void _viewClassroomDetails(ClassroomModel classroom) {
    context.pushNamed(
      'classroom_details',
      pathParameters: {'classroomId': classroom.id},
    );
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
              if (await authService.signOut()) {
                if (context.mounted) {
                  context.goNamed('login');
                }
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
