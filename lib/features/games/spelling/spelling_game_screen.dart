import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:readingquest_bilingual_learning/core/extensions_theme.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/theme_app.dart';
import '../../../models/word_model.dart';
import '../../../providers/words_provider.dart';
import '../../../services/tts_service.dart';

class SpellingGameScreen extends ConsumerStatefulWidget {
  const SpellingGameScreen({super.key});

  @override
  ConsumerState<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends ConsumerState<SpellingGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TTSService _ttsService;

  List<WordModel> _gameWords = [];
  int _currentWordIndex = 0;
  int _score = 0;
  bool _gameCompleted = false;

  List<String> _availableLetters = [];
  final List<String> _userSpelling = [];
  String _feedback = '';
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _ttsService = ServiceLocator.get<TTSService>();
    _initializeGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final wordActions = ref.read(wordActionsProvider);
    final words = await wordActions.getWordsForGame('spelling', count: 8);

    setState(() {
      _gameWords = words;
      _currentWordIndex = 0;
      _score = 0;
      _gameCompleted = false;
    });

    _setupCurrentWord();
  }

  void _setupCurrentWord() {
    if (_gameWords.isEmpty || _currentWordIndex >= _gameWords.length) return;

    final currentWord = _gameWords[_currentWordIndex];
    final wordLetters = currentWord.wordAr.split('');

    // Add some extra random letters to make it challenging
    final extraLetters = ['ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر'];
    final randomExtras = (extraLetters..shuffle()).take(3).toList();

    setState(() {
      _availableLetters = [...wordLetters, ...randomExtras]..shuffle();
      _userSpelling.clear();
      _feedback = '';
      _showHint = false;
    });
  }

  void _addLetter(String letter) {
    setState(() {
      _userSpelling.add(letter);
      _availableLetters.remove(letter);
    });
  }

  void _removeLetter(int index) {
    setState(() {
      final letter = _userSpelling.removeAt(index);
      _availableLetters.add(letter);
    });
  }

  void _checkSpelling() {
    final currentWord = _gameWords[_currentWordIndex];
    final userWord = _userSpelling.join();
    final correctWord = currentWord.wordAr;

    final isCorrect = userWord == correctWord;

    setState(() {
      if (isCorrect) {
        _score += 20;
        _feedback = 'ممتاز! الإملاء صحيح';
      } else {
        _feedback = 'خطأ! الكلمة الصحيحة هي: $correctWord';
      }
    });

    // Play TTS
    _ttsService.speakArabic(userWord);

    // Show feedback for 3 seconds then move to next word
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _nextWord();
      }
    });
  }

  void _nextWord() {
    if (_currentWordIndex < _gameWords.length - 1) {
      setState(() {
        _currentWordIndex++;
      });
      _setupCurrentWord();
    } else {
      setState(() {
        _gameCompleted = true;
      });
      _animationController.forward();
    }
  }

  void _showHintToggle() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  void _playCurrentWord() {
    if (_gameWords.isNotEmpty && _currentWordIndex < _gameWords.length) {
      final currentWord = _gameWords[_currentWordIndex];
      _ttsService.speakArabic(currentWord.wordAr);
    }
  }

  void _clearSpelling() {
    setState(() {
      _availableLetters.addAll(_userSpelling);
      _userSpelling.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'games.spelling'.tr(),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.infoColor,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'النقاط: $_score',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
      body: _gameCompleted ? _buildCompletionScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    if (_gameWords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentWord = _gameWords[_currentWordIndex];

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.infoColor, Colors.transparent],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Progress Indicator
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'الكلمة ${_currentWordIndex + 1} من ${_gameWords.length}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colorscheme.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      LinearProgressIndicator(
                        value: (_currentWordIndex + 1) / _gameWords.length,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.infoColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Word Info
              FadeInLeft(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // English word and meaning
                      Text(
                        currentWord.wordEn,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Cairo',
                        ),
                      ),

                      SizedBox(height: 8.h),

                      if (currentWord.meaningAr != null)
                        Text(
                          currentWord.meaningAr!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: context.colorscheme.secondary,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),

                      SizedBox(height: 16.h),

                      // Listen button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _playCurrentWord,
                            icon: Icon(Icons.volume_up, size: 20.w),
                            label: Text(
                              'استمع للكلمة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton.icon(
                            onPressed: _showHintToggle,
                            icon: Icon(
                              _showHint
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.w,
                            ),
                            label: Text(
                              _showHint ? 'إخفاء التلميح' : 'إظهار التلميح',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Hint
                      if (_showHint) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppTheme.warningColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            'التلميح: الكلمة تبدأ بحرف "${currentWord.wordAr[0]}"',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.warningColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // User Spelling Area
              FadeInUp(
                child: Container(
                  width: double.infinity,
                  height: 80.h,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _userSpelling.isEmpty
                          ? Colors.grey.shade300
                          : AppTheme.infoColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _userSpelling.isEmpty
                      ? Text(
                          'اسحب الحروف هنا لتكوين الكلمة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade500,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          alignment: WrapAlignment.center,
                          children: _userSpelling.asMap().entries.map((entry) {
                            final index = entry.key;
                            final letter = entry.value;
                            return GestureDetector(
                              onTap: () => _removeLetter(index),
                              child: Container(
                                width: 50.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.infoColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),

              SizedBox(height: 20.h),

              // Available Letters
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحروف المتاحة:',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: context.colorscheme.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: _availableLetters.map((letter) {
                            return GestureDetector(
                              onTap: () => _addLetter(letter),
                              child: Container(
                                width: 50.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Feedback
              if (_feedback.isNotEmpty)
                FadeInUp(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: _feedback.contains('ممتاز')
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _feedback.contains('ممتاز')
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                    child: Text(
                      _feedback,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: _feedback.contains('ممتاز')
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Action Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _userSpelling.isEmpty
                            ? null
                            : _checkSpelling,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.infoColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Text(
                          'تحقق من الإملاء',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: _userSpelling.isEmpty ? null : _clearSpelling,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Icon(Icons.clear, size: 20.w),
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

  Widget _buildCompletionScreen() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.successColor, Colors.white],
          stops: [0.0, 0.5],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation
              FadeInDown(
                child: SizedBox(
                  height: 200.h,
                  child: Lottie.asset(
                    'assets/animations/success.json',
                    controller: _animationController,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Congratulations Text
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'ممتاز!',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Text(
                  'لقد أكملت تمرين الإملاء بنجاح!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: context.colorscheme.primary,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 30.h),

              // Score Display
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'النتيجة النهائية',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colorscheme.secondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$_score نقطة',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Action Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 1100),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentWordIndex = 0;
                            _gameCompleted = false;
                            _score = 0;
                            _feedback = '';
                          });
                          _initializeGame();
                          _animationController.reset();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.infoColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'العب مرة أخرى',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.infoColor,
                          side: const BorderSide(color: AppTheme.infoColor),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'العودة للرئيسية',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
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
    );
  }
}
