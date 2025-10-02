import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readingquest_bilingual_learning/core/extensions_theme.dart';


import '../../../shared/widgets/custom_app_bar.dart';

class WordCompletionScreen extends ConsumerStatefulWidget {
  const WordCompletionScreen({super.key});

  @override
  ConsumerState<WordCompletionScreen> createState() =>
      _WordCompletionScreenState();
}

class _WordCompletionScreenState extends ConsumerState<WordCompletionScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent],
            stops: [0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: 'games.spelling'.tr(), showBackButton: true),
              Expanded(
                child: Center(
                  child: Text(
                    'games.wordCompletionGame.comingSoon'.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorscheme.primary,
                    ),
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
