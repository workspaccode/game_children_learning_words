// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:readingquest_bilingual_learning/providers/words_provider.dart';

// class TeacherDashboardScreen extends ConsumerStatefulWidget {
//   const TeacherDashboardScreen({super.key});

//   @override
//   ConsumerState<TeacherDashboardScreen> createState() =>
//       _TeacherDashboardScreenState();
// }

// class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authStateProvider);
//     final user = authState.user;

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         title: const Text('لوحة تحكم المعلم'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               _showNotifications();
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               context.push('/settings');
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildWelcomeHeader(user),
//           _buildQuickStats(),
//           SizedBox(height: 20.h),
//           Expanded(
//             child: _buildMainContent(),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNavigation(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.push('/teacher/create-activity');
//         },
//         backgroundColor: Theme.of(context).primaryColor,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildWelcomeHeader(MockUser? user) {
//     return Container(
//       margin: EdgeInsets.all(20.w),
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).primaryColor.withValues(alpha: 0.8),
//             Theme.of(context).primaryColor,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30.w,
//             backgroundColor: Colors.white.withValues(alpha: 0.2),
//             child: user?.profileImageUrl != null
//                 ? ClipOval(
//                     child: Image.network(
//                       user!.profileImageUrl!,
//                       width: 60.w,
//                       height: 60.w,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Icon(
//                           Icons.person,
//                           size: 30.w,
//                           color: Colors.white,
//                         );
//                       },
//                     ),
//                   )
//                 : Icon(
//                     Icons.person,
//                     size: 30.w,
//                     color: Colors.white,
//                   ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'مرحباً ${user?.displayName ?? 'المعلم'}',
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   'لديك 3 فصول دراسية و 25 طالب',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.white.withValues(alpha: 0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Icon(
//             Icons.school,
//             color: Colors.white,
//             size: 32.w,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickStats() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildStatCard(
//               'الطلاب',
//               '25',
//               Icons.people,
//               Colors.blue,
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: _buildStatCard(
//               'الأنشطة',
//               '12',
//               Icons.assignment,
//               Colors.green,
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: _buildStatCard(
//               'التقييمات',
//               '8',
//               Icons.quiz,
//               Colors.orange,
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: _buildStatCard(
//               'التقارير',
//               '5',
//               Icons.analytics,
//               Colors.purple,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 20.w),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18.sp,
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

//   Widget _buildMainContent() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildOverviewTab();
//       case 1:
//         return _buildClassroomsTab();
//       case 2:
//         return _buildActivitiesTab();
//       case 3:
//         return _buildReportsTab();
//       default:
//         return _buildOverviewTab();
//     }
//   }

//   Widget _buildOverviewTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(20.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الأنشطة الحديثة',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           _buildRecentActivitiesList(),
//           SizedBox(height: 24.h),
//           Text(
//             'الطلاب النشطون',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           _buildActiveStudentsList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildClassroomsTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(20.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'الفصول الدراسية',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   _showCreateClassroomDialog();
//                 },
//                 icon: const Icon(Icons.add, color: Colors.white),
//                 label: const Text('إضافة فصل', style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           _buildClassroomsList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivitiesTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(20.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'الأنشطة',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   context.push('/teacher/create-activity');
//                 },
//                 icon: const Icon(Icons.add, color: Colors.white),
//                 label: const Text('نشاط جديد', style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           _buildActivitiesList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildReportsTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(20.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'التقارير والإحصائيات',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           _buildReportsList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentActivitiesList() {
//     final activities = [
//       {'title': 'قراءة الحروف', 'class': 'الصف الأول', 'students': 15, 'date': 'اليوم'},
//       {'title': 'كتابة الكلمات', 'class': 'الصف الثاني', 'students': 12, 'date': 'أمس'},
//       {'title': 'تعلم الأرقام', 'class': 'الصف الأول', 'students': 18, 'date': 'منذ يومين'},
//     ];

//     return Column(
//       children: activities.map((activity) => _buildActivityCard(activity)).toList(),
//     );
//   }

//   Widget _buildActiveStudentsList() {
//     final students = [
//       {'name': 'أحمد محمد', 'class': 'الصف الأول', 'progress': 85, 'avatar': '👦'},
//       {'name': 'فاطمة علي', 'class': 'الصف الثاني', 'progress': 92, 'avatar': '👧'},
//       {'name': 'محمد أحمد', 'class': 'الصف الأول', 'progress': 78, 'avatar': '👦'},
//     ];

//     return Column(
//       children: students.map((student) => _buildStudentCard(student)).toList(),
//     );
//   }

//   Widget _buildClassroomsList() {
//     final classrooms = [
//       {'name': 'الصف الأول أ', 'students': 15, 'activities': 8, 'color': Colors.blue},
//       {'name': 'الصف الثاني ب', 'students': 12, 'activities': 6, 'color': Colors.green},
//       {'name': 'الصف الثالث ج', 'students': 18, 'activities': 10, 'color': Colors.orange},
//     ];

//     return Column(
//       children: classrooms.map((classroom) => _buildClassroomCard(classroom)).toList(),
//     );
//   }

//   Widget _buildActivitiesList() {
//     final activities = [
//       {'title': 'قراءة الحروف', 'type': 'قراءة', 'difficulty': 'سهل', 'duration': 15},
//       {'title': 'كتابة الكلمات', 'type': 'كتابة', 'difficulty': 'متوسط', 'duration': 20},
//       {'title': 'تعلم الأرقام', 'type': 'مفردات', 'difficulty': 'سهل', 'duration': 10},
//       {'title': 'قواعد بسيطة', 'type': 'قواعد', 'difficulty': 'صعب', 'duration': 25},
//     ];

//     return Column(
//       children: activities.map((activity) => _buildActivityListCard(activity)).toList(),
//     );
//   }

//   Widget _buildReportsList() {
//     final reports = [
//       {'title': 'تقرير التقدم الشهري', 'type': 'شهري', 'date': 'ديسمبر 2024'},
//       {'title': 'تحليل الأداء', 'type': 'تحليلي', 'date': 'هذا الأسبوع'},
//       {'title': 'إحصائيات الحضور', 'type': 'حضور', 'date': 'اليوم'},
//     ];

//     return Column(
//       children: reports.map((report) => _buildReportCard(report)).toList(),
//     );
//   }

//   Widget _buildActivityCard(Map<String, dynamic> activity) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: Colors.blue.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(Icons.assignment, color: Colors.blue, size: 20.w),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   activity['title'],
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${activity['class']} • ${activity['students']} طالب',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             activity['date'],
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStudentCard(Map<String, dynamic> student) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Text(
//             student['avatar'],
//             style: TextStyle(fontSize: 32.sp),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   student['name'],
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   student['class'],
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 LinearProgressIndicator(
//                   value: student['progress'] / 100.0,
//                   backgroundColor: Colors.grey[300],
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     student['progress'] > 80 ? Colors.green : Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Text(
//             '${student['progress']}%',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.bold,
//               color: student['progress'] > 80 ? Colors.green : Colors.orange,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildClassroomCard(Map<String, dynamic> classroom) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: (classroom['color'] as Color).withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(
//               Icons.class_,
//               color: classroom['color'] as Color,
//               size: 24.w,
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   classroom['name'],
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   '${classroom['students']} طالب • ${classroom['activities']} نشاط',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey[400]),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityListCard(Map<String, dynamic> activity) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: _getActivityTypeColor(activity['type']).withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(
//               _getActivityTypeIcon(activity['type']),
//               color: _getActivityTypeColor(activity['type']),
//               size: 20.w,
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   activity['title'],
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${activity['type']} • ${activity['difficulty']} • ${activity['duration']} د',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuButton(
//             itemBuilder: (context) => [
//               const PopupMenuItem(value: 'edit', child: Text('تعديل')),
//               const PopupMenuItem(value: 'duplicate', child: Text('نسخ')),
//               const PopupMenuItem(value: 'delete', child: Text('حذف')),
//             ],
//             onSelected: (value) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('تم اختيار: $value')),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReportCard(Map<String, dynamic> report) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: Colors.purple.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(Icons.analytics, color: Colors.purple, size: 20.w),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   report['title'],
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${report['type']} • ${report['date']}',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('عرض ${report['title']}')),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             ),
//             child: const Text('عرض', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       currentIndex: _selectedIndex,
//       onTap: (index) {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.dashboard),
//           label: 'نظرة عامة',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.class_),
//           label: 'الفصول',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.assignment),
//           label: 'الأنشطة',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.analytics),
//           label: 'التقارير',
//         ),
//       ],
//     );
//   }

//   Color _getActivityTypeColor(String type) {
//     switch (type) {
//       case 'قراءة':
//         return Colors.blue;
//       case 'كتابة':
//         return Colors.green;
//       case 'مفردات':
//         return Colors.orange;
//       case 'قواعد':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getActivityTypeIcon(String type) {
//     switch (type) {
//       case 'قراءة':
//         return Icons.auto_stories;
//       case 'كتابة':
//         return Icons.edit;
//       case 'مفردات':
//         return Icons.spellcheck;
//       case 'قواعد':
//         return Icons.rule;
//       default:
//         return Icons.assignment;
//     }
//   }

//   void _showNotifications() {
//     showDialog<void>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('الإشعارات'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.assignment, color: Colors.blue),
//               title: const Text('نشاط جديد مكتمل'),
//               subtitle: const Text('أحمد محمد أكمل نشاط القراءة'),
//               trailing: const Text('منذ 5 د'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person_add, color: Colors.green),
//               title: const Text('طالب جديد'),
//               subtitle: const Text('انضم فاطمة علي للصف الثاني'),
//               trailing: const Text('منذ ساعة'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('موافق'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCreateClassroomDialog() {
//     showDialog<void>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('إنشاء فصل جديد'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'اسم الفصل',
//                 hintText: 'مثال: الصف الأول أ',
//               ),
//             ),
//             SizedBox(height: 16.h),
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'وصف الفصل',
//                 hintText: 'وصف مختصر للفصل',
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تم إنشاء الفصل بنجاح!')),
//               );
//             },
//             child: const Text('إنشاء'),
//           ),
//         ],
//       ),
//     );
//   }
// }
