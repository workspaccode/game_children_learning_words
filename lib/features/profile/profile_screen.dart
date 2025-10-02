import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/core/extensions_theme.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';
import 'package:readingquest_bilingual_learning/features/profile/widgets/level_progress_card.dart';
import 'package:readingquest_bilingual_learning/features/profile/widgets/profile_achievement_card.dart';
import 'package:readingquest_bilingual_learning/services/auth_service.dart';

import '../../core/utils/theme_app.dart';
import '../../shared/widgets/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor, Colors.transparent],
          stops: [0.0, 0.2],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to settings
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      // Profile Header
                      FadeInDown(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60.r,
                              backgroundColor: AppTheme.primaryColor,
                              child: user?.profileImageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        user!.profileImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60.w,
                                      color: Colors.white,
                                    ),
                            ),
                            if (user?.isProfileComplete() == false)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 16.w,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'أكمل ملفك',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      FadeInUp(
                        child: Text(
                          user?.name ?? 'المستخدم',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: context.colorscheme.primary,
                          ),
                        ),
                      ),
                      if (user?.userType == UserType.child)
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            'عمر ${user?.age ?? ''} سنوات',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: context.colorscheme.secondary,
                            ),
                          ),
                        ),
                      SizedBox(height: 24.h),

                      // Level Progress
                      if (user?.userType == UserType.child)
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: const LevelProgressCard(
                            level: 2,
                            wordsLearned: 15,
                            totalWordsInLevel: 20,
                          ),
                        ),

                      SizedBox(height: 24.h),

                      // Achievements Grid
                      if (user?.userType == UserType.child)
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 16.w,
                            children: const [
                              ProfileAchievementCard(
                                title: 'الكلمات المتعلمة',
                                value: '25',
                                icon: Icons.auto_stories,
                                color: Colors.blue,
                              ),
                              ProfileAchievementCard(
                                title: 'أيام متتالية',
                                value: '7',
                                icon: Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              ProfileAchievementCard(
                                title: 'النقاط',
                                value: '150',
                                icon: Icons.star,
                                color: Colors.amber,
                              ),
                              ProfileAchievementCard(
                                title: 'الألعاب المكتملة',
                                value: '12',
                                icon: Icons.games,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 32.h),

                      // Action Buttons
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: CustomButton(
                          text: 'تعديل الملف الشخصي',
                          onPressed: () {
                            // TODO: Navigate to edit profile
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: CustomButton(
                          text: 'تسجيل الخروج',
                          onPressed: () {
                            ref.read(authStateProvider.notifier).signOut();
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          },
                          // variant: ButtonVariant.outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
