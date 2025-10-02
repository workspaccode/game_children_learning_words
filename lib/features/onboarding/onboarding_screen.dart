import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:readingquest_bilingual_learning/core/extensions_theme.dart';

import '../../core/routing/app_routes.dart';
import '../../core/services/service_locator.dart';
import '../../core/utils/theme_app.dart';
import '../../services/storage_service.dart';
import 'river_pod/utiles.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final refss = contextProvider;

  //late BuildContext context;
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'مرحباً بك في تعلم الكلمات',
      description: 'تطبيق تعليمي ممتع لتعلم الكلمات العربية والإنجليزية',
      animation: 'assets/animations/welcome.json',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'ألعاب تفاعلية',
      description: 'تعلم من خلال الألعاب الممتعة والتفاعلية',
      animation: 'assets/animations/games.json',
      color: AppTheme.warningColor,
    ),
    OnboardingPage(
      title: 'تتبع التقدم',
      description: 'راقب تقدمك وحقق إنجازات جديدة',
      animation: 'assets/animations/progress.json',
      color: AppTheme.successColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'common.skip'.tr(),
                    style: TextStyle(
                      color: context.colorscheme.secondary,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            _buildPageIndicator(),

            SizedBox(height: 20.h),

            // Navigation buttons
            _buildNavigationButtons(),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: SizedBox(
              height: 300.h,
              child: Lottie.asset(page.animation, fit: BoxFit.contain),
            ),
          ),

          SizedBox(height: 40.h),

          // Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              page.title,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: page.color,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              page.description,
              style: TextStyle(
                fontSize: 16.sp,
                color: context.colorscheme.secondary,
                fontFamily: 'Cairo',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: _currentPage == index ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _pages[index].color
                : context.colorscheme.secondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'common.previous'.tr(),
                style: TextStyle(
                  color: context.colorscheme.secondary,
                  fontSize: 16.sp,
                ),
              ),
            )
          else
            const SizedBox(),

          // Next/Get Started button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _pages[_currentPage].color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              _currentPage < _pages.length - 1 ? 'common.next'.tr() : 'البدء',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final storage = ServiceLocator.get<StorageService>();
    await storage.setOnboardingCompleted(true);

    if (mounted) {
      context.go(AppRoutes.login);
    }
  }
}

class OnboardingPage {
  OnboardingPage({
    required this.title,
    required this.description,
    required this.animation,
    required this.color,
  });
  final String title;
  final String description;
  final String animation;
  final Color color;
}
