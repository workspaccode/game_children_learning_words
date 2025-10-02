import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'شاشة تسجيل الدخول',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'قيد التطوير...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<void> _handleLogin() async {
//     //if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final result = await ref
//           .read(authStateProvider.notifier)
//           .login(_emailController.text.trim(), _passwordController.text.trim());

//       if (mounted) {
//         setState(() => _isLoading = false);

//         if (result['success'] == true) {
//           final userType = result['user_type'] as UserType;
//           print(
//             '🎯 تم تسجيل الدخول بنجاح كـ: ${userType.toString().split('.').last}',
//           );

//           // توجيه المستخدم إلى الشاشة المناسبة حسب نوعه
//           UserTypeRouter.routeUserByType(context, userType);
//         } else {
//           _showErrorSnackBar(result['error'] as String? ?? 'فشل تسجيل الدخول');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         _showErrorSnackBar(e.toString());
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16.w),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: 40.h),
//                 FadeInDown(
//                   child: Text(
//                     'مرحباً بك في رحلة القراءة',
//                     style: TextStyle(
//                       fontSize: 32.sp,
//                       fontWeight: FontWeight.bold,
//                       color: AppTheme.primaryColor,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 SizedBox(height: 40.h),
//                 FadeInUp(
//                   child: CustomTextField(
//                     controller: _emailController,
//                     label: 'البريد الإلكتروني',
//                     hint: 'أدخل بريدك الإلكتروني',
//                     keyboardType: TextInputType.emailAddress,
//                     validator: ValidationUtils.validateEmailField,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 FadeInUp(
//                   delay: const Duration(milliseconds: 200),
//                   child: CustomTextField(
//                     controller: _passwordController,
//                     label: 'كلمة المرور',
//                     hint: 'أدخل كلمة المرور',
//                     obscureText: true,
//                     validator: ValidationUtils.validatePasswordField,
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 if (_isLoading)
//                   const Center(child: CircularProgressIndicator())
//                 else
//                   FadeInUp(
//                     delay: const Duration(milliseconds: 400),
//                     child: CustomButton(
//                       text: 'تسجيل الدخول',
//                       onPressed: _handleLogin,
//                     ),
//                   ),
//                 SizedBox(height: 16.h),
//                 FadeInUp(
//                   delay: const Duration(milliseconds: 600),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text('ليس لديك حساب؟'),
//                       TextButton(
//                         onPressed: () =>
//                             NavigationService().navigateTo(AppRoutes.register),
//                         child: const Text(
//                           'سجل الآن',
//                           style: TextStyle(
//                             color: AppTheme.primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
