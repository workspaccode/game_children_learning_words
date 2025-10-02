import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/theme_app.dart';

/// ReadingQuest Showcase - صفحة عرض شاملة للميزات الجديدة
class ReadingQuestShowcase extends StatefulWidget {
  const ReadingQuestShowcase({super.key});

  @override
  State<ReadingQuestShowcase> createState() => _ReadingQuestShowcaseState();
}

class _ReadingQuestShowcaseState extends State<ReadingQuestShowcase>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<ShowcaseItem> _showcaseItems = [
    ShowcaseItem(
      title: 'ReadingQuest',
      subtitle: 'Welcome to the Adventure!',
      description: 'مرحباً بك في مغامرة التعلم ثنائية اللغة الأكثر إثارة!',
      icon: Icons.book_rounded,
      color: AppTheme.primaryColor,
    ),
    ShowcaseItem(
      title: 'User Types',
      subtitle: 'Adult or Child?',
      description: 'اختر نوع المستخدم - للكبار أو الأطفال، لتجربة مخصصة',
      icon: Icons.people,
      color: AppTheme.secondaryColor,
    ),
    ShowcaseItem(
      title: 'Bilingual Learning',
      subtitle: 'Arabic & English',
      description: 'تعلم بلغتين معاً - العربية والإنجليزية في نفس الوقت',
      icon: Icons.language,
      color: AppTheme.tertiaryColor,
    ),
    ShowcaseItem(
      title: 'Games & Adventures',
      subtitle: 'Fun Learning Experience',
      description: 'ألعاب تفاعلية مثيرة تجعل التعلم متعة حقيقية',
      icon: Icons.games,
      color: AppTheme.successColor,
    ),
    ShowcaseItem(
      title: 'Progress Tracking',
      subtitle: 'Monitor Your Growth',
      description: 'تتبع تقدمك ومشاهدة نموك في رحلة التعلم',
      icon: Icons.trending_up,
      color: AppTheme.infoColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _showcaseItems.length,
                  itemBuilder: (context, index) {
                    return _buildShowcasePage(_showcaseItems[index], index);
                  },
                ),
              ),

              // Page Indicator and Navigation
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Text(
              'ReadingQuest',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Bilingual Learning Adventure',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcasePage(ShowcaseItem item, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 300 + (index * 100)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            SlideInDown(
              delay: Duration(milliseconds: 500 + (index * 100)),
              child: Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(item.icon, size: 60.w, color: item.color),
              ),
            ),

            SizedBox(height: 40.h),

            // Title
            FadeInUp(
              delay: Duration(milliseconds: 700 + (index * 100)),
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 12.h),

            // Subtitle
            FadeInUp(
              delay: Duration(milliseconds: 900 + (index * 100)),
              child: Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 20.h),

            // Description
            FadeInUp(
              delay: Duration(milliseconds: 1100 + (index * 100)),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Feature Highlights
            if (index == 1) _buildUserTypeDemo(),
            if (index == 2) _buildLanguageToggleDemo(),
            if (index == 3) _buildGamesPreview(),
            if (index == 4) _buildProgressDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeDemo() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildUserTypeCard('Adult', Icons.person, true),
          SizedBox(width: 20.w),
          _buildUserTypeCard('Child', Icons.child_care, false),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard(String type, IconData icon, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Text(
            type,
            style: TextStyle(
              fontSize: 14.sp,
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggleDemo() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1300),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              'Hello',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Icon(
              Icons.swap_horiz,
              color: Colors.white.withOpacity(0.7),
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'مرحبا',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesPreview() {
    final games = ['Word Match', 'Spelling', 'Pronunciation', 'Story Mode'];

    return FadeInUp(
      delay: const Duration(milliseconds: 1300),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: games
            .map(
              (game) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  game,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProgressDemo() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1300),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level Progress',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '75%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return FadeInUp(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _showcaseItems.length,
                (index) => Container(
                  width: _currentPage == index ? 24.w : 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 18.w),
                        SizedBox(width: 4.w),
                        const Text('Previous'),
                      ],
                    ),
                  )
                else
                  const SizedBox(),

                // Next/Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _showcaseItems.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Navigate to login or main app
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage < _showcaseItems.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _currentPage < _showcaseItems.length - 1
                            ? Icons.arrow_forward
                            : Icons.rocket_launch,
                        size: 18.w,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShowcaseItem {

  ShowcaseItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
}
