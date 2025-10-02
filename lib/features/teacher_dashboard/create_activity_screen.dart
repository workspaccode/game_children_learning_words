import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';

import '../../models/daily_activity_model.dart';
import '../../providers/teacher_provider.dart';

class CreateActivityScreen extends ConsumerStatefulWidget {

  const CreateActivityScreen({super.key, this.studentId, this.classroomId});
  final String? studentId;
  final String? classroomId;

  @override
  ConsumerState<CreateActivityScreen> createState() =>
      _CreateActivityScreenState();
}

class _CreateActivityScreenState extends ConsumerState<CreateActivityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // Form Data
  DateTime _selectedDate = DateTime.now();
  final List<ActivityItem> _selectedActivities = [];
  String? _selectedStudentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedStudentId = widget.studentId;

    // If specific date is needed, set it
    if (_selectedDate.isBefore(DateTime.now())) {
      _selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityTemplates = ref.watch(activityTemplatesProvider);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('إنشاء نشاط يومي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'معلومات أساسية', icon: Icon(Icons.info_outline)),
            Tab(text: 'الأنشطة', icon: Icon(Icons.assignment)),
            Tab(text: 'المراجعة', icon: Icon(Icons.preview)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildActivitiesTab(activityTemplates),
            _buildReviewTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildSectionCard(
            title: 'معلومات النشاط الأساسية',
            icon: Icons.info,
            color: Colors.blue,
            child: Column(
              children: [
                // Student Selection
                _buildStudentSelector(),
                SizedBox(height: 16.h),

                // Date Selection
                _buildDateSelector(),
                SizedBox(height: 16.h),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان النشاط',
                    hintText: 'مثل: أنشطة اليوم الأول للأسبوع',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال عنوان النشاط';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Description Input
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف النشاط (اختياري)',
                    hintText: 'وصف مختصر لأهداف النشاط...',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: 16.h),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات للوالدين (اختياري)',
                    hintText: 'تعليمات أو ملاحظات مهمة...',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(List<ActivityTemplate> templates) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Activities
          if (_selectedActivities.isNotEmpty) ...[
            _buildSectionCard(
              title: 'الأنشطة المختارة (${_selectedActivities.length})',
              icon: Icons.check_circle,
              color: Colors.green,
              child: Column(
                children: _selectedActivities
                    .map(_buildSelectedActivityCard)
                    .toList(),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Available Templates
          _buildSectionCard(
            title: 'قوالب الأنشطة المتاحة',
            icon: Icons.library_books,
            color: Colors.orange,
            child: Column(
              children: templates
                  .map(_buildTemplateCard)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    if (_selectedActivities.isEmpty || _selectedStudentId == null) {
      return _buildEmptyReview();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _buildSectionCard(
            title: 'ملخص النشاط',
            icon: Icons.summarize,
            color: Colors.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('الطالب:', _selectedStudentId ?? 'غير محدد'),
                _buildSummaryRow('التاريخ:', _formatDate(_selectedDate)),
                _buildSummaryRow(
                  'العنوان:',
                  _titleController.text.isEmpty
                      ? 'بدون عنوان'
                      : _titleController.text,
                ),
                _buildSummaryRow(
                  'عدد الأنشطة:',
                  '${_selectedActivities.length}',
                ),
                _buildSummaryRow('إجمالي النقاط:', '${_getTotalPoints()}'),
                _buildSummaryRow('الوقت المتوقع:', _getEstimatedTime()),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Activities Detail
          _buildSectionCard(
            title: 'تفاصيل الأنشطة',
            icon: Icons.list_alt,
            color: Colors.blue,
            child: Column(
              children: _selectedActivities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                return _buildActivityDetailCard(activity, index + 1);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.grey[600]),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطالب المستهدف',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(
                  _selectedStudentId ?? 'اختر طالب',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showStudentSelection,
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ النشاط',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(ActivityTemplate template) {
    final isSelected = _selectedActivities.any(
      (activity) => activity.id.startsWith(template.id),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isSelected
            ? template.type.color.withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? template.type.color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: template.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  template.type.icon,
                  color: template.type.color,
                  size: 16.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      template.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleActivityTemplate(template),
                icon: Icon(
                  isSelected ? Icons.remove_circle : Icons.add_circle,
                  color: isSelected ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildInfoChip(
                '${template.difficultyLevel} نجمة',
                Icons.star,
                Colors.orange,
              ),
              SizedBox(width: 8.w),
              _buildInfoChip(
                '${template.estimatedDuration.inMinutes} دقيقة',
                Icons.timer,
                Colors.blue,
              ),
              SizedBox(width: 8.w),
              _buildInfoChip(
                '${template.points} نقطة',
                Icons.emoji_events,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedActivityCard(ActivityItem activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(activity.type.icon, color: Colors.green, size: 16.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              activity.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeActivity(activity),
            icon: Icon(Icons.close, color: Colors.red, size: 16.w),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64.w, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'لم تختر أي أنشطة بعد',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ارجع إلى تبويب "الأنشطة" لاختيار الأنشطة',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDetailCard(ActivityItem activity, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
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
              CircleAvatar(
                radius: 12.w,
                backgroundColor: Colors.blue,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: activity.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  activity.typeLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: activity.type.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            activity.description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildInfoChip(
                '${activity.difficultyLevel} نجمة',
                Icons.star,
                Colors.orange,
              ),
              SizedBox(width: 8.w),
              _buildInfoChip(
                '${activity.estimatedDuration.inMinutes} دقيقة',
                Icons.timer,
                Colors.blue,
              ),
              SizedBox(width: 8.w),
              _buildInfoChip(
                '${activity.points} نقطة',
                Icons.emoji_events,
                Colors.purple,
              ),
              if (activity.isRequired) ...[
                SizedBox(width: 8.w),
                _buildInfoChip('مطلوب', Icons.priority_high, Colors.red),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.w, color: color),
          SizedBox(width: 2.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_tabController.index > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _tabController.animateTo(_tabController.index - 1),
                icon: const Icon(Icons.arrow_back),
                label: const Text('السابق'),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: _tabController.index < 2
                ? ElevatedButton.icon(
                    onPressed: _canProceedToNext()
                        ? () =>
                              _tabController.animateTo(_tabController.index + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('التالي'),
                  )
                : ElevatedButton.icon(
                    onPressed: _canCreateActivity() ? _createActivity : null,
                    icon: _isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: const Text('إنشاء النشاط'),
                  ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  bool _canProceedToNext() {
    switch (_tabController.index) {
      case 0:
        return _selectedStudentId != null && _titleController.text.isNotEmpty;
      case 1:
        return _selectedActivities.isNotEmpty;
      default:
        return false;
    }
  }

  bool _canCreateActivity() {
    return _selectedStudentId != null &&
        _titleController.text.isNotEmpty &&
        _selectedActivities.isNotEmpty &&
        !_isLoading;
  }

  void _toggleActivityTemplate(ActivityTemplate template) {
    setState(() {
      final existingIndex = _selectedActivities.indexWhere(
        (activity) => activity.id.startsWith(template.id),
      );

      if (existingIndex >= 0) {
        _selectedActivities.removeAt(existingIndex);
      } else {
        _selectedActivities.add(
          template.toActivityItem(studentId: _selectedStudentId!),
        );
      }
    });
  }

  void _removeActivity(ActivityItem activity) {
    setState(() {
      _selectedActivities.removeWhere((item) => item.id == activity.id);
    });
  }

  int _getTotalPoints() {
    return _selectedActivities.fold(
      0,
      (sum, activity) => sum + activity.points,
    );
  }

  String _getEstimatedTime() {
    final totalMinutes = _selectedActivities.fold<int>(
      0,
      (sum, activity) => sum + activity.estimatedDuration.inMinutes,
    );

    if (totalMinutes < 60) {
      return '$totalMinutes دقيقة';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '$hoursس $minutesد';
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showStudentSelection() {
    // TODO: Implement student selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر طالب'),
        content: const Text('سيتم إضافة قائمة الطلاب هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _createActivity() async {
    if (!_canCreateActivity()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).user;
      if (user == null) throw Exception('المستخدم غير مسجل دخول');

      final activity = DailyActivityModel(
        id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
        childId: _selectedStudentId!,
        parentId: 'parent_id', // TODO: Get actual parent ID
        teacherId: user.id,
        date: _selectedDate,
        activities: _selectedActivities,
        status: ActivityStatus.pending,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Create activity using provider
      // TODO: Implement create activity in provider
      // await ref.read(studentActivitiesProvider(StudentActivitiesParams(studentId: _selectedStudentId!)).notifier).assignActivity(activity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء النشاط بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة'),
        content: const Text(
          'إنشاء الأنشطة:\n\n'
          '1. اختر الطالب والتاريخ\n'
          '2. اختر الأنشطة المناسبة\n'
          '3. راجع البيانات قبل الإنشاء\n'
          '4. يمكن للوالدين متابعة التقدم\n'
          '5. ستصلك تقارير عند الإنجاز',
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

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// Extension for ActivityType to get color and icon
extension ActivityTypeExtension on ActivityType {
  Color get color {
    switch (this) {
      case ActivityType.game:
        return Colors.green;
      case ActivityType.lesson:
        return Colors.blue;
      case ActivityType.exercise:
        return Colors.orange;
      case ActivityType.reading:
        return Colors.purple;
      case ActivityType.listening:
        return Colors.teal;
      case ActivityType.speaking:
        return Colors.pink;
      case ActivityType.writing:
        return Colors.indigo;
      case ActivityType.assessment:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.game:
        return Icons.videogame_asset;
      case ActivityType.lesson:
        return Icons.school;
      case ActivityType.exercise:
        return Icons.fitness_center;
      case ActivityType.reading:
        return Icons.menu_book;
      case ActivityType.listening:
        return Icons.hearing;
      case ActivityType.speaking:
        return Icons.record_voice_over;
      case ActivityType.writing:
        return Icons.edit;
      case ActivityType.assessment:
        return Icons.quiz;
    }
  }
}
