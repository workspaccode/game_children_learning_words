import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WordsScreen extends ConsumerStatefulWidget {
  const WordsScreen({super.key});

  @override
  ConsumerState<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends ConsumerState<WordsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _searchQuery = '';

  // Mock data for words
  final List<Map<String, dynamic>> _mockWords = [
    {
      'id': '1',
      'english': 'Apple',
      'arabic': 'تفاحة',
      'category': 'fruits',
      'level': 1,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': '2',
      'english': 'Book',
      'arabic': 'كتاب',
      'category': 'objects',
      'level': 1,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': '3',
      'english': 'Cat',
      'arabic': 'قطة',
      'category': 'animals',
      'level': 1,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': '4',
      'english': 'Dog',
      'arabic': 'كلب',
      'category': 'animals',
      'level': 1,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': '5',
      'english': 'House',
      'arabic': 'بيت',
      'category': 'objects',
      'level': 2,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': '6',
      'english': 'Water',
      'arabic': 'ماء',
      'category': 'drinks',
      'level': 1,
      'imageUrl': null,
      'audioUrl': null,
    },
  ];

  final List<String> _categories = [
    'all',
    'animals',
    'fruits',
    'objects',
    'drinks',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('قاموس الكلمات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddWordDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildWordsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن كلمة...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 16.h),
          // Category Filters
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(_getCategoryName(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList() {
    final filteredWords = _getFilteredWords();

    if (filteredWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد كلمات مطابقة للبحث',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: filteredWords.length,
      itemBuilder: (context, index) {
        final word = filteredWords[index];
        return _buildWordCard(word);
      },
    );
  }

  Widget _buildWordCard(Map<String, dynamic> word) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: InkWell(
        onTap: () {
          _showWordDetails(word);
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Word Icon/Image
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: _getCategoryColor(word['category'] as String).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getCategoryIcon(word['category'] as String),
                  size: 30.w,
                  color: _getCategoryColor(word['category'] as String),
                ),
              ),
              SizedBox(width: 16.w),
              // Word Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            word['english'] as String,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(word['level'] as int),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'مستوى ${word['level']}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      word['arabic'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _getCategoryName(word['category'] as String),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () {
                            _playAudio(word);
                          },
                          iconSize: 20.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredWords() {
    return _mockWords.where((word) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final matchesEnglish = (word['english'] as String).toLowerCase().contains(_searchQuery);
        final matchesArabic = (word['arabic'] as String).contains(_searchQuery);
        if (!matchesEnglish && !matchesArabic) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != 'all' && word['category'] != _selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'all':
        return 'الكل';
      case 'animals':
        return 'حيوانات';
      case 'fruits':
        return 'فواكه';
      case 'objects':
        return 'أشياء';
      case 'drinks':
        return 'مشروبات';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'animals':
        return Colors.green;
      case 'fruits':
        return Colors.orange;
      case 'objects':
        return Colors.blue;
      case 'drinks':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'animals':
        return Icons.pets;
      case 'fruits':
        return Icons.apple;
      case 'objects':
        return Icons.category;
      case 'drinks':
        return Icons.local_drink;
      default:
        return Icons.book;
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _playAudio(Map<String, dynamic> word) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تشغيل صوت: ${word['english']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWordDetails(Map<String, dynamic> word) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word['english'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الترجمة: ${word['arabic']}',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'الفئة: ${_getCategoryName(word['category'] as String)}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'المستوى: ${word['level']}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _playAudio(word);
            },
            icon: const Icon(Icons.volume_up, color: Colors.white),
            label: const Text('استمع', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWordDialog() {
    final englishController = TextEditingController();
    final arabicController = TextEditingController();
    String selectedCategory = 'animals';
    int selectedLevel = 1;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة كلمة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: englishController,
                  decoration: const InputDecoration(
                    labelText: 'الكلمة بالإنجليزية',
                    hintText: 'مثال: Apple',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: arabicController,
                  decoration: const InputDecoration(
                    labelText: 'الترجمة بالعربية',
                    hintText: 'مثال: تفاحة',
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                  ),
                  items: _categories
                      .where((cat) => cat != 'all')
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryName(category)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<int>(
                  value: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'المستوى',
                  ),
                  items: [1, 2, 3]
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text('مستوى $level'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedLevel = value!;
                    });
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
            ElevatedButton(
              onPressed: () {
                if (englishController.text.isNotEmpty &&
                    arabicController.text.isNotEmpty) {
                  setState(() {
                    _mockWords.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'english': englishController.text,
                      'arabic': arabicController.text,
                      'category': selectedCategory,
                      'level': selectedLevel,
                      'imageUrl': null,
                      'audioUrl': null,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الكلمة بنجاح!')),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
