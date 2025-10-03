import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/providers/words_provider.dart';

class TranslationDemoScreen extends ConsumerStatefulWidget {
  const TranslationDemoScreen({super.key});

  @override
  ConsumerState<TranslationDemoScreen> createState() =>
      _TranslationDemoScreenState();
}

class _TranslationDemoScreenState extends ConsumerState<TranslationDemoScreen> {
  final _sourceController = TextEditingController();
  final _targetController = TextEditingController();
  
  String _sourceLanguage = 'en';
  String _targetLanguage = 'ar';
  bool _isTranslating = false;

  // Mock translation data
  final Map<String, Map<String, String>> _mockTranslations = {
    'en': {
      'hello': 'مرحبا',
      'goodbye': 'وداعا',
      'thank you': 'شكرا لك',
      'please': 'من فضلك',
      'yes': 'نعم',
      'no': 'لا',
      'apple': 'تفاحة',
      'book': 'كتاب',
      'cat': 'قطة',
      'dog': 'كلب',
      'house': 'بيت',
      'water': 'ماء',
      'food': 'طعام',
      'school': 'مدرسة',
      'teacher': 'معلم',
      'student': 'طالب',
    },
    'ar': {
      'مرحبا': 'hello',
      'وداعا': 'goodbye',
      'شكرا لك': 'thank you',
      'من فضلك': 'please',
      'نعم': 'yes',
      'لا': 'no',
      'تفاحة': 'apple',
      'كتاب': 'book',
      'قطة': 'cat',
      'كلب': 'dog',
      'بيت': 'house',
      'ماء': 'water',
      'طعام': 'food',
      'مدرسة': 'school',
      'معلم': 'teacher',
      'طالب': 'student',
    },
  };

  final List<Map<String, String>> _commonPhrases = [
    {'en': 'Hello', 'ar': 'مرحبا'},
    {'en': 'Thank you', 'ar': 'شكرا لك'},
    {'en': 'Good morning', 'ar': 'صباح الخير'},
    {'en': 'How are you?', 'ar': 'كيف حالك؟'},
    {'en': 'What is your name?', 'ar': 'ما اسمك؟'},
    {'en': 'Nice to meet you', 'ar': 'سعيد بلقائك'},
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('مترجم النصوص'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _swapLanguages,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLanguageSelector(),
            SizedBox(height: 24.h),
            _buildTranslationCard(),
            SizedBox(height: 24.h),
            _buildCommonPhrases(),
            SizedBox(height: 24.h),
            _buildTranslationHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'من',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButton<String>(
                  value: _sourceLanguage,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
                    DropdownMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sourceLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: IconButton(
              onPressed: _swapLanguages,
              icon: Icon(
                Icons.swap_horiz,
                color: Theme.of(context).primaryColor,
                size: 32.w,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'إلى',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButton<String>(
                  value: _targetLanguage,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
                    DropdownMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _targetLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard() {
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
          // Source Text Input
          Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 20.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _sourceLanguage == 'en' ? 'English' : 'العربية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _sourceController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _sourceLanguage == 'en' 
                        ? 'Enter text to translate...'
                        : 'أدخل النص للترجمة...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _translateText(value);
                    } else {
                      _targetController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: EdgeInsets.symmetric(horizontal: 20.w),
          ),
          
          // Target Text Output
          Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      size: 20.w,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _targetLanguage == 'en' ? 'English' : 'العربية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                    if (_targetController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          _copyToClipboard(_targetController.text);
                        },
                        iconSize: 20.w,
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  height: 80.h,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                  child: _isTranslating
                      ? Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Text(
                          _targetController.text.isEmpty
                              ? (_targetLanguage == 'en' 
                                  ? 'Translation will appear here...'
                                  : 'ستظهر الترجمة هنا...')
                              : _targetController.text,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _targetController.text.isEmpty
                                ? Colors.grey[500]
                                : Colors.black87,
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

  Widget _buildCommonPhrases() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'العبارات الشائعة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...List.generate(_commonPhrases.length, (index) {
            final phrase = _commonPhrases[index];
            return _buildPhraseCard(phrase);
          }),
        ],
      ),
    );
  }

  Widget _buildPhraseCard(Map<String, String> phrase) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () {
          _sourceController.text = _sourceLanguage == 'en' 
              ? phrase['en']! 
              : phrase['ar']!;
          _translateText(_sourceController.text);
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase['en']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      phrase['ar']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationHistory() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.blue,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'الترجمات الأخيرة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.history_toggle_off,
                  size: 48.w,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 8.h),
                Text(
                  'لا توجد ترجمات سابقة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      
      // Swap text content too
      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  Future<void> _translateText(String text) async {
    if (text.trim().isEmpty) {
      _targetController.clear();
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final lowerText = text.toLowerCase().trim();
    final translations = _mockTranslations[_sourceLanguage] ?? {};
    
    String translation = translations[lowerText] ?? 'ترجمة غير متوفرة';
    
    // If no direct translation found, try word by word
    if (translation == 'ترجمة غير متوفرة') {
      final words = text.split(' ');
      final translatedWords = <String>[];
      
      for (final word in words) {
        final wordTranslation = translations[word.toLowerCase()] ?? word;
        translatedWords.add(wordTranslation);
      }
      
      translation = translatedWords.join(' ');
    }

    setState(() {
      _targetController.text = translation;
      _isTranslating = false;
    });
  }

  void _copyToClipboard(String text) {
    // Mock clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ النص إلى الحافظة'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
