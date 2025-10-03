// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:readingquest_bilingual_learning/providers/words_provider.dart';
// import '../../models/user_model.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);
//     final user = authState.user;

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         title: const Text('الملف الشخصي'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => context.pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('الإعدادات قيد التطوير')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           children: [
//             _buildProfileHeader(context, user),
//             SizedBox(height: 32.h),
//             if (user?.userType == UserType.child) ...[
//               _buildStatsSection(context),
//               SizedBox(height: 32.h),
//               _buildAchievementsSection(context),
//               SizedBox(height: 32.h),
//             ],
//             _buildActionButtons(context, ref),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader(BuildContext context, MockUser? user) {
//     return Container(
//       padding: EdgeInsets.all(24.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).primaryColor.withValues(alpha: 0.8),
//             Theme.of(context).primaryColor,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               CircleAvatar(
//                 radius: 50.w,
//                 backgroundColor: Colors.white.withValues(alpha: 0.2),
//                 child: user?.profileImageUrl != null
//                     ? ClipOval(
//                         child: Image.network(
//                           user!.profileImageUrl!,
//                           width: 100.w,
//                           height: 100.w,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Icon(
//                               Icons.person,
//                               size: 50.w,
//                               color: Colors.white,
//                             );
//                           },
//                         ),
//                       )
//                     : Icon(
//                         Icons.person,
//                         size: 50.w,
//                         color: Colors.white,
//                       ),
//               ),
//               Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   padding: EdgeInsets.all(8.w),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.camera_alt,
//                     size: 16.w,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             user?.displayName ?? 'المستخدم',
//             style: TextStyle(
//               fontSize: 24.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             user?.email ?? 'user@example.com',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.white.withValues(alpha: 0.9),
//             ),
//           ),
//           if (user?.userType == UserType.child && user?.age != null) ...[
//             SizedBox(height: 8.h),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               child: Text(
//                 'عمر ${user!.age} سنوات',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsSection(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'إحصائياتي',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'المستوى',
//                   '2',
//                   Icons.trending_up,
//                   Colors.blue,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: _buildStatCard(
//                   'الكلمات',
//                   '25',
//                   Icons.auto_stories,
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'النقاط',
//                   '150',
//                   Icons.star,
//                   Colors.amber,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: _buildStatCard(
//                   'الأيام',
//                   '7',
//                   Icons.local_fire_department,
//                   Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24.w),
//           SizedBox(height: 8.h),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievementsSection(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.emoji_events, color: Colors.amber, size: 24.w),
//               SizedBox(width: 8.w),
//               Text(
//                 'الإنجازات',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 3,
//             mainAxisSpacing: 12.h,
//             crossAxisSpacing: 12.w,
//             children: [
//               _buildAchievementBadge('🏆', 'أول كلمة', true),
//               _buildAchievementBadge('🔥', '7 أيام', true),
//               _buildAchievementBadge('⭐', '100 نقطة', true),
//               _buildAchievementBadge('📚', '20 كلمة', false),
//               _buildAchievementBadge('🎯', 'مستوى 3', false),
//               _buildAchievementBadge('💎', 'خبير', false),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievementBadge(String emoji, String title, bool achieved) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: achieved 
//             ? Colors.amber.withValues(alpha: 0.1)
//             : Colors.grey.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: achieved 
//               ? Colors.amber.withValues(alpha: 0.3)
//               : Colors.grey.withValues(alpha: 0.3),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             emoji,
//             style: TextStyle(
//               fontSize: 24.sp,
//               color: achieved ? null : Colors.grey,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 10.sp,
//               fontWeight: FontWeight.w500,
//               color: achieved ? Colors.amber[700] : Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           height: 56.h,
//           child: ElevatedButton.icon(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تعديل الملف الشخصي قيد التطوير')),
//               );
//             },
//             icon: const Icon(Icons.edit, color: Colors.white),
//             label: Text(
//               'تعديل الملف الشخصي',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).primaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 16.h),
//         SizedBox(
//           width: double.infinity,
//           height: 56.h,
//           child: OutlinedButton.icon(
//             onPressed: () {
//               _showLogoutDialog(context, ref);
//             },
//             icon: Icon(Icons.logout, color: Colors.red[600]),
//             label: Text(
//               'تسجيل الخروج',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red[600],
//               ),
//             ),
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: Colors.red[600]!),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showLogoutDialog(BuildContext context, WidgetRef ref) {
//     showDialog<void>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تسجيل الخروج'),
//         content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ref.read(authStateProvider.notifier).signOut();
//               context.go('/login');
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
