import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/providers/words_provider.dart';

class CreateActivityScreen extends ConsumerStatefulWidget {
  const CreateActivityScreen({
    super.key, 
    this.studentId, 
    this.classroomId,
  });

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
  String _selectedActivityType = 'reading';
  String _selectedDifficulty = 'easy';
  int _estimatedDuration = 15;
  bool _isLoading = false;

  // Mock data
  final List<String> _activityTypes = [
    'reading',
    'writing',
    'listening',
    'speaking',
    'vocabulary',
    'grammar',
  ];

  final List<String> _difficulties = [
    'easy',
    'medium',
    'hard',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('إنشاء نشاط جديد'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المعلومات الأساسية', icon: Icon(Icons.info)),
            Tab(text: 'محتوى النشاط', icon: Icon(Icons.assignment)),
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
            _buildActivityContentTab(),
            _buildReviewTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'معلومات النشاط',
            icon: Icons.info,
            children: [
              SizedBox(height: 16.h),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان النشاط *',
                  hintText: 'أدخل عنوان النشاط',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال عنوان النشاط';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف النشاط',
                  hintText: 'أدخل وصف مفصل للنشاط',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildSectionCard(
            title: 'إعدادات النشاط',
            icon: Icons.settings,
            children: [
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedActivityType,
                decoration: InputDecoration(
                  labelText: 'نوع النشاط',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: _activityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getActivityTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityType = value!;
                  });
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: InputDecoration(
                  labelText: 'مستوى الصعوبة',
                  prefixIcon: const Icon(Icons.bar_chart),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: _difficulties.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(_getDifficultyName(difficulty)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.grey[600]),
                  SizedBox(width: 12.w),
                  Text(
                    'المدة المقدرة: $_estimatedDuration دقيقة',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
              Slider(
                value: _estimatedDuration.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: '$_estimatedDuration دقيقة',
                onChanged: (value) {
                  setState(() {
                    _estimatedDuration = value.round();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildSectionCard(
            title: 'التاريخ والوقت',
            icon: Icons.calendar_today,
            children: [
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('تاريخ النشاط'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _selectDate(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'محتوى النشاط',
            icon: Icons.assignment,
            children: [
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.auto_stories, size: 48.w, color: Colors.blue),
                    SizedBox(height: 12.h),
                    Text(
                      'محتوى ${_getActivityTypeName(_selectedActivityType)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'سيتم إنشاء محتوى تفاعلي مناسب لمستوى ${_getDifficultyName(_selectedDifficulty)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'ملاحظات إضافية',
                  hintText: 'أضف أي ملاحظات أو تعليمات خاصة للطلاب',
                  prefixIcon: const Icon(Icons.note_add),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildSectionCard(
            title: 'معاينة النشاط',
            icon: Icons.preview,
            children: [
              SizedBox(height: 16.h),
              _buildActivityPreview(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'مراجعة النشاط',
            icon: Icons.check_circle,
            children: [
              SizedBox(height: 16.h),
              _buildReviewItem('العنوان', _titleController.text.isEmpty ? 'غير محدد' : _titleController.text),
              _buildReviewItem('النوع', _getActivityTypeName(_selectedActivityType)),
              _buildReviewItem('المستوى', _getDifficultyName(_selectedDifficulty)),
              _buildReviewItem('المدة', '$_estimatedDuration دقيقة'),
              _buildReviewItem('التاريخ', '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              if (_descriptionController.text.isNotEmpty)
                _buildReviewItem('الوصف', _descriptionController.text),
              if (_notesController.text.isNotEmpty)
                _buildReviewItem('الملاحظات', _notesController.text),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'النشاط جاهز للإنشاء! اضغط على "إنشاء النشاط" لحفظه.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 24.w),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPreview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(_selectedDifficulty),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getActivityIcon(_selectedActivityType),
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleController.text.isEmpty ? 'عنوان النشاط' : _titleController.text,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_getActivityTypeName(_selectedActivityType)} • ${_getDifficultyName(_selectedDifficulty)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$_estimatedDuration د',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (_descriptionController.text.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              _descriptionController.text,
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_tabController.index > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _tabController.animateTo(_tabController.index - 1);
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'السابق',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          if (_tabController.index > 0) SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextOrCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _tabController.index == 2 ? 'إنشاء النشاط' : 'التالي',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityTypeName(String type) {
    switch (type) {
      case 'reading':
        return 'قراءة';
      case 'writing':
        return 'كتابة';
      case 'listening':
        return 'استماع';
      case 'speaking':
        return 'تحدث';
      case 'vocabulary':
        return 'مفردات';
      case 'grammar':
        return 'قواعد';
      default:
        return type;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'سهل';
      case 'medium':
        return 'متوسط';
      case 'hard':
        return 'صعب';
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'reading':
        return Icons.auto_stories;
      case 'writing':
        return Icons.edit;
      case 'listening':
        return Icons.headphones;
      case 'speaking':
        return Icons.record_voice_over;
      case 'vocabulary':
        return Icons.spellcheck;
      case 'grammar':
        return Icons.rule;
      default:
        return Icons.assignment;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleNextOrCreate() {
    if (_tabController.index == 2) {
      _createActivity();
    } else {
      if (_tabController.index == 0 && !_formKey.currentState!.validate()) {
        return;
      }
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mock activity creation
      await Future<void>.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                const Text('تم إنشاء النشاط بنجاح!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في إنشاء النشاط: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة'),
        content: const Text(
          'هذه الشاشة تساعدك في إنشاء أنشطة تعليمية جديدة للطلاب.\n\n'
          '1. املأ المعلومات الأساسية للنشاط\n'
          '2. حدد محتوى النشاط والملاحظات\n'
          '3. راجع جميع المعلومات قبل الإنشاء',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
