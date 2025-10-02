import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readingquest_bilingual_learning/core/extensions_theme.dart';

import '../../models/word_model.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    this.onTap,
    this.onFavorite,
    this.onPlay,
    this.showFavorite = true,
    this.showPlayButton = true,
    this.isCompact = false,
    this.animationDelay,
  });
  final WordModel word;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onPlay;
  final bool showFavorite;
  final bool showPlayButton;
  final bool isCompact;
  final int? animationDelay;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 4.w : 8.w,
        vertical: isCompact ? 4.h : 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 12.r : 16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: isCompact ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isCompact ? 12.r : 16.r),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12.w : 16.w),
            child: isCompact
                ? _buildCompactContent(context)
                : _buildFullContent(context),
          ),
        ),
      ),
    );

    if (animationDelay != null) {
      return FadeInUp(
        delay: Duration(milliseconds: animationDelay!),
        duration: const Duration(milliseconds: 600),
        child: card,
      );
    }

    return card;
  }

  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with favorite button
        Row(
          children: [
            // Category badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                word.category ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Spacer(),
            if (showFavorite)
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  Icons.favorite_border, // TODO: Add isFavorite to WordModel
                  color: Colors.grey,
                  size: 20.w,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),

        SizedBox(height: 12.h),

        // Word image
        if (word.imageUrl != null)
          Container(
            height: 80.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                word.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                      size: 32.w,
                    ),
                  );
                },
              ),
            ),
          ),

        SizedBox(height: 12.h),

        // Arabic word
        Text(word.wordAr, style: Theme.of(context).textTheme.titleLarge),

        SizedBox(height: 4.h),

        // English word
        Text(
          word.wordEn,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontFamily: 'Poppins',
          ),
        ),

        SizedBox(height: 8.h),

        // Difficulty and play button
        Row(
          children: [
            // Difficulty indicator
            Row(
              children: List.generate(3, (index) {
                return Icon(
                  Icons.star,
                  size: 12.w,
                  color: index < word.difficultyLevel
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                );
              }),
            ),
            const Spacer(),
            if (showPlayButton)
              IconButton(
                onPressed: onPlay,
                icon: Icon(
                  Icons.play_circle_filled,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.w,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Row(
      children: [
        // Word image (smaller)
        if (word.imageUrl != null)
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                word.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                      size: 16.w,
                    ),
                  );
                },
              ),
            ),
          ),

        SizedBox(width: 12.w),

        // Word content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(word.wordAr, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 2.h),
              Text(
                word.wordEn,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPlayButton)
              IconButton(
                onPressed: onPlay,
                icon: Icon(
                  Icons.play_circle_filled,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.w,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            if (showFavorite)
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  Icons.favorite_border, // TODO: Add isFavorite to WordModel
                  color: Colors.grey,
                  size: 18.w,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ],
    );
  }
}

class WordGridCard extends StatelessWidget {
  const WordGridCard({
    super.key,
    required this.word,
    this.onTap,
    this.onFavorite,
    this.onPlay,
    this.showFavorite = true,
    this.showPlayButton = true,
    this.animationDelay,
  });
  final WordModel word;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onPlay;
  final bool showFavorite;
  final bool showPlayButton;
  final int? animationDelay;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with favorite
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          word.category ?? '',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (showFavorite)
                      GestureDetector(
                        onTap: onFavorite,
                        child: Icon(
                          Icons
                              .favorite_border, // TODO: Add isFavorite to WordModel
                          color: Colors.grey,
                          size: 16.w,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Word image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade100,
                    ),
                    child: word.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              word.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                    size: 24.w,
                                  ),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 24.w,
                          ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Arabic word
                Text(
                  word.wordAr,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.h),

                // English word
                Text(
                  word.wordEn,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 4.h),

                // Bottom row
                Row(
                  children: [
                    // Difficulty
                    Row(
                      children: List.generate(3, (index) {
                        return Icon(
                          Icons.star,
                          size: 10.w,
                          color: index < word.difficultyLevel
                              ? context.colorscheme.primary
                              : Colors.grey.shade300,
                        );
                      }),
                    ),
                    const Spacer(),
                    if (showPlayButton)
                      GestureDetector(
                        onTap: onPlay,
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18.w,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (animationDelay != null) {
      return FadeInUp(
        delay: Duration(milliseconds: animationDelay!),
        duration: const Duration(milliseconds: 600),
        child: card,
      );
    }

    return card;
  }
}
