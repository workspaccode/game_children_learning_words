import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/word_model.dart';

import '../../providers/audio_provider.dart';
import '../../providers/words_provider.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/filter_chip_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/word_card.dart';

class WordsScreen extends ConsumerStatefulWidget {
  const WordsScreen({super.key});

  @override
  ConsumerState<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends ConsumerState<WordsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  int _selectedLevel = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
            stops: [0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              CustomAppBar(title: 'words.words'.tr(), showBackButton: true),

              // Search and Filters
              _buildSearchAndFilters(),

              // Words List
              Expanded(child: _buildWordsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Search Field
            CustomTextField(
              controller: _searchController,
              label: 'words.searchWords'.tr(),
              prefixIconData: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            SizedBox(height: 16.h),

            // Category Filter
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);

                return categoriesAsync.when(
                  data: (categories) => SizedBox(
                    height: 40.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChipWidget(
                          label: 'words.all'.tr(),
                          isSelected: _selectedCategory == 'all',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'all';
                            });
                          },
                        ),
                        ...categories.map(
                          (category) => FilterChipWidget(
                            label: category,
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                );
              },
            ),

            SizedBox(height: 12.h),

            // Level Filter
            Consumer(
              builder: (context, ref, child) {
                final levelsAsync = ref.watch(levelsProvider);

                return levelsAsync.when(
                  data: (levels) => SizedBox(
                    height: 40.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChipWidget(
                          label: 'words.allLevels'.tr(),
                          isSelected: _selectedLevel == 0,
                          onTap: () {
                            setState(() {
                              _selectedLevel = 0;
                            });
                          },
                        ),
                        ...levels.map(
                          (level) => FilterChipWidget(
                            label: '${'words.level'.tr()} $level',
                            isSelected: _selectedLevel == level,
                            onTap: () {
                              setState(() {
                                _selectedLevel = level;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsList() {
    return Consumer(
      builder: (context, ref, child) {
        // Choose the appropriate provider based on filters
        final wordsAsync = _getWordsProvider(ref);

        return wordsAsync.when(
          data: (words) {
            // Apply search filter
            final filteredWords = _searchQuery.isEmpty
                ? words
                : words
                      .where(
                        (word) =>
                            word.wordAr.contains(_searchQuery) ||
                            word.wordEn.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            (word.category?.contains(_searchQuery) ?? false),
                      )
                      .toList();

            if (filteredWords.isEmpty) {
              return _buildEmptyState();
            }

            return FadeInUp(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: filteredWords.length,
                itemBuilder: (context, index) {
                  final word = filteredWords[index];
                  return FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: index * 100),
                    child: WordCard(
                      word: word,
                      onTap: () => _showWordDetails(word),
                      onPlay: () => _playWordAudio(word),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  AsyncValue<List<WordModel>> _getWordsProvider(WidgetRef ref) {
    if (_searchQuery.isNotEmpty) {
      return ref.watch(searchWordsProvider(_searchQuery));
    } else if (_selectedCategory != 'all') {
      return ref.watch(wordsByCategoryProvider(_selectedCategory));
    } else if (_selectedLevel != 0) {
      return ref.watch(wordsByLevelProvider(_selectedLevel));
    } else {
      return ref.watch(wordsProvider);
    }
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 80.w,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16.h),
            Text(
              'words.noWordsFound'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'words.tryDifferentSearch'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return FadeInUp(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'words.errorOccurred'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Refresh the data
                if (_selectedCategory != 'all') {
                  ref.refresh(wordsByCategoryProvider(_selectedCategory));
                } else if (_selectedLevel != 0) {
                  ref.refresh(wordsByLevelProvider(_selectedLevel));
                } else {
                  ref.refresh(wordsProvider);
                }
              },
              child: Text('words.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetails(WordModel word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Word Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word Image
                    if (word.imageUrl != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            word.imageUrl!,
                            width: 200.w,
                            height: 150.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    SizedBox(height: 20.h),

                    // Arabic Word
                    Text(
                      word.wordAr,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.black87),
                    ),

                    SizedBox(height: 8.h),

                    // English Word
                    Text(
                      word.wordEn,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.blue),
                    ),

                    SizedBox(height: 16.h),

                    // Category
                    if (word.category != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          word.categoryDisplayName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),

                    SizedBox(height: 20.h),

                    // Audio Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _playWordAudio(word),
                            icon: const Icon(Icons.volume_up),
                            label: const Text('نطق عربي'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _playWordAudio(word, isArabic: false),
                            icon: const Icon(Icons.volume_up),
                            label: const Text('English'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playWordAudio(WordModel word, {bool isArabic = true}) {
    final audioNotifier = ref.read(ttsStateProvider.notifier);
    final text = isArabic ? word.wordAr : word.wordEn;
    final language = isArabic ? 'ar-SA' : 'en-US';

    audioNotifier.speak(text.toString(), language: language);
  }
}
