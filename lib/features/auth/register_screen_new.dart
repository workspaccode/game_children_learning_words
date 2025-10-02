import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/extensions_theme.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/validation_utils.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';
import 'domain/entities/register_params.dart';
import 'domain/entities/user_type.dart';
import 'presentation/bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _usernameController = TextEditingController();
  final _parentEmailController = TextEditingController();

  UserType _selectedUserType = UserType.child;
  bool _acceptTerms = false;
  bool passwordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  void _checkParentExists() {
    final email = _parentEmailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('validation.parentEmailRequired'.tr());
      return;
    }

    context.read<AuthBloc>().add(
      AuthCheckParentExistsEvent(parentEmail: email),
    );
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorSnackBar('validation.termsRequired'.tr());
      return;
    }

    final params = RegisterUserParams(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      userType: _selectedUserType,
      age: _selectedUserType == UserType.child
          ? int.tryParse(_ageController.text)
          : null,
      username: _selectedUserType == UserType.child
          ? _usernameController.text.trim()
          : null,
      parentEmail: _selectedUserType == UserType.child
          ? _parentEmailController.text.trim()
          : null,
    );

    context.read<AuthBloc>().add(AuthRegisterEvent(params));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildUserTypeOption(
    UserType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedUserType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colorscheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.colorscheme.primary
                    : Colors.grey.shade600,
                size: 20.w,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? context.colorscheme.primary
                  : Colors.grey.shade400,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildUserTypeOption(
            UserType.child,
            'auth.child'.tr(),
            'auth.childSubtitle'.tr(),
            Icons.child_care,
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),
          _buildUserTypeOption(
            UserType.parent,
            'auth.father'.tr(),
            'auth.parentSubtitle'.tr(),
            Icons.family_restroom,
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),
          _buildUserTypeOption(
            UserType.teacher,
            'auth.teacher'.tr(),
            'auth.teacherSubtitle'.tr(),
            Icons.school,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.person_add_rounded, size: 40.w),
          ),
        ),

        SizedBox(height: 20.h),

        // Title
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'auth.signUp'.tr(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),

        SizedBox(height: 8.h),

        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Text(
            'auth.createAccount'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'auth.alreadyHaveAccount'.tr(),
            style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
            child: Text(
              'auth.signIn'.tr(),
              style: TextStyle(
                color: context.theme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Type Selection
            Text(
              'auth.userType'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 12.h),

            _buildUserTypeSelector(),

            SizedBox(height: 24.h),

            // Name Field
            CustomTextField(
              controller: _nameController,
              label: 'auth.fullName'.tr(),
              prefixIconData: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'auth.feildRequired'.tr();
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Email Field
            CustomTextField(
              controller: _emailController,
              label: 'auth.email'.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIconData: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'auth.feildRequired'.tr();
                }
                if (!ValidationUtils.isValidEmail(value)) {
                  return 'auth.emailInvalid'.tr();
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Child-specific fields
            if (_selectedUserType == UserType.child) ...[
              // Username Field (for children)
              CustomTextField(
                controller: _usernameController,
                label: 'auth.username'.tr(),
                prefixIconData: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'auth.feildRequired'.tr();
                  }
                  if (value.length < 3) {
                    return 'validation.usernameMinLength'.tr();
                  }
                  if (value.contains(' ')) {
                    return 'validation.usernameNoSpaces'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Parent Email Field
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return CustomTextField(
                    controller: _parentEmailController,
                    label: 'auth.parentEmail'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    prefixIconData: Icons.supervisor_account_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'validation.parentEmailRequired'.tr();
                      }
                      if (!ValidationUtils.isValidEmail(value)) {
                        return 'validation.emailInvalid'.tr();
                      }
                      return null;
                    },
                    suffixWidget: state is AuthCheckingParent
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed:
                                _parentEmailController.text.trim().isEmpty
                                ? null
                                : _checkParentExists,
                            tooltip: 'tooltips.checkParent'.tr(),
                          ),
                  );
                },
              ),
              SizedBox(height: 20.h),

              // Age Field
              CustomTextField(
                controller: _ageController,
                label: 'auth.age'.tr(),
                keyboardType: TextInputType.number,
                prefixIconData: Icons.cake_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validation.ageRequired'.tr();
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 3 || age > 18) {
                    return 'validation.ageInvalid'.tr();
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),
            ],

            // Password Field
            CustomTextField(
              controller: _passwordController,
              label: 'auth.password'.tr(),
              obscureText: !passwordVisible,
              prefixIconData: Icons.lock_outline,
              suffixWidget: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'validation.passwordRequired'.tr();
                }
                if (value.length < 6) {
                  return 'validation.passwordMinLength'.tr();
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Confirm Password Field
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'auth.confirmPassword'.tr(),
              obscureText: !passwordVisible,
              prefixIconData: Icons.lock_outline,
              suffixWidget: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'validation.passwordRequired'.tr();
                }
                if (value != _passwordController.text) {
                  return 'validation.passwordsDoNotMatch'.tr();
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptTerms = !_acceptTerms;
                      });
                    },
                    child: Text(
                      'auth.acceptTerms'.tr(),
                      style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            // Register Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return CustomButton(
                  text: 'auth.signUp'.tr(),
                  onPressed: _acceptTerms ? _handleRegister : null,
                  isLoading: state is AuthLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthParentExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('validation.parentFound'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthParentDoesNotExist) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('validation.parentNotFound'.tr()),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: _buildHeader(),
                    ),
                    SizedBox(height: 24.h),
                    _buildRegistrationForm(),
                    SizedBox(height: 24.h),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
