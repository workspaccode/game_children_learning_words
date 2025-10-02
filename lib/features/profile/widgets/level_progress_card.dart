import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/utils/theme_app.dart';

class LevelProgressCard extends StatelessWidget {

  const LevelProgressCard({
    super.key,
    required this.level,
    required this.wordsLearned,
    required this.totalWordsInLevel,
  });
  final int level;
  final int wordsLearned;
  final int totalWordsInLevel;

  @override
  Widget build(BuildContext context) {
    final progress = wordsLearned / totalWordsInLevel;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 40.r,
              lineWidth: 8,
              animation: true,
              percent: progress,
              center: Text(
                'مستوى\n$level',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              progressColor: AppTheme.primaryColor,
              backgroundColor: Colors.grey[200]!,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تقدم المستوى',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'تعلمت $wordsLearned من $totalWordsInLevel كلمة',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
