import 'package:flutter/material.dart';

class ChildCompletionScreen extends StatelessWidget {
  const ChildCompletionScreen({
    super.key,
    required this.userData,
  });

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Child Profile'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Child Completion Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Complete your child profile here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// class ChildCompletionScreen extends ConsumerStatefulWidget {

//   const ChildCompletionScreen({super.key, required this.userData});
//   final Map<String, dynamic> userData;

//   @override
//   ConsumerState<ChildCompletionScreen> createState() =>
//       _ChildCompletionScreenState();
// }

// class _ChildCompletionScreenState extends ConsumerState<ChildCompletionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _parentEmailController = TextEditingController();
//   final _ageController = TextEditingController();

//   bool _isCheckingParent = false;
//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _parentEmailController.dispose();
//     _ageController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleComplete() async {
//     if (!_formKey.currentState!.validate()) return;

//     // التحقق من وجود الوالد
//     final parentExists = await _checkParentExists();
//     if (!parentExists) return;

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       final authService = ref.read(authServiceProvider);
//       final success = await authService.updateChildWithParentInfo(
//         childId: widget.userData['uid']?.toString() ?? '',
//         parentEmail: _parentEmailController.text.trim(),
//         username: _usernameController.text.trim(),
//         age: int.parse(_ageController.text),
//       );

//       if (success) {
//         if (mounted) {
//           context.go(AppRoutes.home);
//         }
//       } else {
//         _showErrorSnackBar(authService.errorMessage ?? 'errors.saveFailed'.tr());
//       }
//     } catch (e) {
//       _showErrorSnackBar('errors.unknownError'.tr());
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   Future<bool> _checkParentExists() async {
//     if (_parentEmailController.text.trim().isEmpty) {
//       _showErrorSnackBar('validation.parentEmailRequired'.tr());
//       return false;
//     }

//     setState(() {
//       _isCheckingParent = true;
//     });

//     try {
//       final authService = ref.read(authServiceProvider);
//       final parent = await authService.checkParentExists(
//         _parentEmailController.text.trim(),
//       );

//       if (parent == null) {
//         _showErrorSnackBar(
//           'errors.parentNotFound'.tr(),
//         );
//         return false;
//       }

//       return true;
//     } catch (e) {
//       _showErrorSnackBar('errors.parentCheckError'.tr());
//       return false;
//     } finally {
//       setState(() {
//         _isCheckingParent = false;
//       });
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.all(16.w),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LoadingOverlay(
//         isLoading: _isSubmitting,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(24.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: 40.h),

//                 // Header
//                 _buildHeader(),

//                 SizedBox(height: 40.h),

//                 // Form
//                 _buildForm(),

//                 SizedBox(height: 30.h),

//                 // Complete Button
//                 CustomButton(text: 'auth.completeRegistration'.tr(), onPressed: _handleComplete),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         // Welcome User Info
//         FadeInDown(
//           duration: const Duration(milliseconds: 600),
//           child: Container(
//             width: 80.w,
//             height: 80.h,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20.r),
//               image: widget.userData['photoURL'] != null
//                   ? DecorationImage(
//                       image: NetworkImage(widget.userData['photoURL'].toString()),
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//               color: widget.userData['photoURL'] == null
//                   ? context.colorscheme.primary.withValues(alpha: 0.1)
//                   : null,
//             ),
//             child: widget.userData['photoURL'] == null
//                 ? Icon(
//                     Icons.child_care,
//                     size: 40.w,
//                     color: context.colorscheme.primary,
//                   )
//                 : null,
//           ),
//         ),

//         SizedBox(height: 20.h),

//         // Title
//         FadeInUp(
//           delay: const Duration(milliseconds: 200),
//           child: Text(
//             'auth.welcomeUser'.tr(args: [widget.userData['displayName']?.toString() ?? 'بك']),
//             style: TextStyle(
//               fontSize: 24.sp,
//               fontWeight: FontWeight.bold,
//               color: context.colorscheme.primary,
//               fontFamily: 'Cairo',
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),

//         SizedBox(height: 8.h),

//         FadeInUp(
//           delay: const Duration(milliseconds: 400),
//           child: Text(
//             'auth.completeYourData'.tr(),
//             style: TextStyle(
//               fontSize: 16.sp,
//               color: context.colorscheme.secondary,
//               fontFamily: 'Cairo',
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildForm() {
//     return FadeInUp(
//       delay: const Duration(milliseconds: 600),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Username Field
//             CustomTextField(
//               controller: _usernameController,
//               label: 'auth.username'.tr(),
//               hint: 'auth.usernameHint'.tr(),
//               prefixIconData: Icons.account_circle_outlined,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'validation.usernameRequired'.tr();
//                 }
//                 if (value.length < 3) {
//                   return 'validation.usernameMinLength'.tr();
//                 }
//                 if (value.contains(' ')) {
//                   return 'validation.usernameNoSpaces'.tr();
//                 }
//                 return null;
//               },
//             ),

//             SizedBox(height: 20.h),

//             // Parent Email Field
//             CustomTextField(
//               controller: _parentEmailController,
//               label: 'auth.parentEmail'.tr(),
//               hint: 'auth.parentEmailHint'.tr(),
//               keyboardType: TextInputType.emailAddress,
//               prefixIconData: Icons.supervisor_account_outlined,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'validation.parentEmailRequired'.tr();
//                 }
//                 if (!ValidationUtils.isValidEmail(value)) {
//                   return 'validation.emailInvalid'.tr();
//                 }
//                 return null;
//               },
//               suffixWidget: _isCheckingParent
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : IconButton(
//                       icon: const Icon(Icons.search),
//                       onPressed: () async {
//                         if (_parentEmailController.text.trim().isNotEmpty) {
//                           await _checkParentExists();
//                         }
//                       },
//                       tooltip: 'tooltips.checkParent'.tr(),
//                     ),
//             ),

//             SizedBox(height: 20.h),

//             // Age Field
//             CustomTextField(
//               controller: _ageController,
//               label: 'auth.age'.tr(),
//               hint: 'auth.ageHint'.tr(),
//               keyboardType: TextInputType.number,
//               prefixIconData: Icons.cake_outlined,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'validation.ageRequired'.tr();
//                 }
//                 final age = int.tryParse(value);
//                 if (age == null || age < 3 || age > 18) {
//                   return 'validation.ageInvalid'.tr();
//                 }
//                 return null;
//               },
//             ),

//             SizedBox(height: 20.h),

//             // Info Card
//             Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: context.colorscheme.primary.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(
//                   color: context.colorscheme.primary.withValues(alpha: 0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: context.colorscheme.primary,
//                     size: 20.w,
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Text(
//                       'auth.parentInfo'.tr(),
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: context.colorscheme.primary,
//                         fontFamily: 'Cairo',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }