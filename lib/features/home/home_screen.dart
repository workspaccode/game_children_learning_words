import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/extensions_theme.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/theme_app.dart';
import '../../providers/words_provider.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/game_card.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/stats_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(),

                      SizedBox(height: 30.h),

                      // Stats Section
                      _buildStatsSection(),

                      SizedBox(height: 30.h),

                      // Games Section
                      _buildGamesSection(),

                      SizedBox(height: 30.h),

                      // Recent Words Section
                      _buildRecentWordsSection(),
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

  Widget _buildAppBar() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authStateProvider);
        final user = authState.user;

        return CustomAppBar(
          title: 'app.appName'.tr(),
          actions: [
            // Profile Avatar
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: Container(
                width: 40.w,
                height: 40.h,
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: user?.profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.profileImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 24.w,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authStateProvider);
        final user = authState.user;

        return FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ReadingQuest',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Welcome ${user?.name ?? 'Adventurer'}!',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Ready for your bilingual learning adventure?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 80.w,
                  height: 80.h,
                  child: Lottie.asset(
                    'assets/animations/welcome.json',
                    controller: _animationController,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final wordStatsAsync = ref.watch(wordStatsProvider);

        return FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'stats.yourProgress'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16.h),
              wordStatsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'stats.wordsLearned'.tr(),
                        value: stats['totalWords'].toString(),
                        icon: Icons.book_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: StatsCard(
                        title: 'stats.gamesPlayed'.tr(),
                        value: '15', // Get from game progress
                        icon: Icons.games_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: StatsCard(
                        title: 'stats.accuracy'.tr(),
                        value: '85%', // Calculate from progress
                        icon: Icons.trending_up_outlined,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                loading: () => const LoadingWidget(),
                error: (Object error, StackTrace stack) => Text('Error: $error'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGamesSection() {
    final games = [
      {
        'title': 'games.wordMatching'.tr(),
        'description': 'games.wordMatchingDesc'.tr(),
        'icon': Icons.extension_outlined,
        'color': AppTheme.primaryColor,
        'route': AppRoutes.wordMatching,
        'animation': 'assets/animations/word_matching.json',
      },
      {
        'title': 'games.sentenceBuilding'.tr(),
        'description': 'games.sentenceBuildingDesc'.tr(),
        'icon': Icons.build_outlined,
        'color': context.theme.colorScheme.secondary,
        'route': AppRoutes.sentenceBuilding,
        'animation': 'assets/animations/sentence_building.json',
      },
      {
        'title': 'games.pronunciation'.tr(),
        'description': 'games.pronunciationDesc'.tr(),
        'icon': Icons.record_voice_over_outlined,
        'color': AppTheme.warningColor,
        'route': AppRoutes.pronunciation,
        'animation': 'assets/animations/pronunciation.json',
      },
      {
        'title': 'games.spelling'.tr(),
        'description': 'games.spellingDesc'.tr(),
        'icon': Icons.spellcheck_outlined,
        'color': AppTheme.infoColor,
        'route': AppRoutes.spelling,
        'animation': 'assets/animations/spelling.json',
      },
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'games.games'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: context.colorscheme.primary,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GameCard(
                title: game['title']! as String,
                description: game['description']! as String,
                icon: game['icon']! as IconData,
                color: game['color']! as Color,
                onTap: () => context.go(game['route']! as String),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWordsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final recentWordsAsync = ref.watch(recentWordsProvider);

        return FadeInUp(
          delay: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'words.recentWords'.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorscheme.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.words),
                    child: Text(
                      'words.seeAll'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              recentWordsAsync.when(
                data: (words) => SizedBox(
                  height: 120.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return Container(
                        width: 100.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (word.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  word.imageUrl!,
                                  width: 50.w,
                                  height: 50.h,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 50.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppTheme.primaryColor,
                                  size: 25.w,
                                ),
                              ),
                            SizedBox(height: 8.h),
                            Text(
                              word.wordAr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colorscheme.primary,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              word.wordEn,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.colorscheme.secondary,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                loading: () => const LoadingWidget(),
                error: (Object error, StackTrace stack) => Text('Error: $error'),
              ),
            ],
          ),
        );
      },
    );
  }
}
