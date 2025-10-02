import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';

import '../../models/payment_model.dart';
import '../../models/subscription_model.dart';
import '../../providers/payment_provider.dart';

class MobileWalletPaymentScreen extends ConsumerStatefulWidget {

  const MobileWalletPaymentScreen({
    super.key,
    required this.gateway,
    required this.amount,
    required this.currency,
    this.subscriptionId,
    this.subscriptionType,
    this.teacherId,
    this.childrenIds,
  });
  final PaymentGateway gateway;
  final double amount;
  final String currency;
  final String? subscriptionId;
  final SubscriptionType? subscriptionType;
  final String? teacherId;
  final List<String>? childrenIds;

  @override
  ConsumerState<MobileWalletPaymentScreen> createState() =>
      _MobileWalletPaymentScreenState();
}

class _MobileWalletPaymentScreenState
    extends ConsumerState<MobileWalletPaymentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isProcessing = false;
  final bool _showPinField = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final paymentProcess = ref.watch(paymentProcessProvider);
    final subscriptionPayment = ref.watch(subscriptionPaymentProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('دفع ${widget.gateway.displayName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gateway Info Card
                  _buildGatewayInfoCard(),
                  SizedBox(height: 24.h),

                  // Amount Summary
                  _buildAmountSummaryCard(),
                  SizedBox(height: 24.h),

                  // Phone Number Input
                  _buildPhoneNumberSection(),
                  SizedBox(height: 20.h),

                  // PIN Input (if needed)
                  if (_showPinField) ...[
                    _buildPinSection(),
                    SizedBox(height: 20.h),
                  ],

                  // Payment Instructions
                  _buildInstructionsCard(),
                  SizedBox(height: 32.h),

                  // Security Notice
                  _buildSecurityNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildGatewayInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGatewayColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _getGatewayColors().first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.gateway.displayName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'دفع آمن عبر محفظتك الإلكترونية',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.white, size: 16.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'مشفر وآمن بنسبة 100%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSummaryCard() {
    final fees = ref
        .read(paymentProcessProvider.notifier)
        .calculateFees(widget.gateway, widget.amount);
    final total = widget.amount + fees;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt,
                color: Theme.of(context).primaryColor,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل المبلغ',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildAmountRow(
            'المبلغ الأساسي',
            '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
          ),
          _buildAmountRow(
            'رسوم ${widget.gateway.displayName}',
            '${fees.toStringAsFixed(2)} ${widget.currency}',
          ),

          SizedBox(height: 8.h),
          Container(height: 1.h, color: Colors.grey[300]),
          SizedBox(height: 8.h),

          _buildAmountRow(
            'المجموع النهائي',
            '${total.toStringAsFixed(2)} ${widget.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 13.sp,
              fontWeight: FontWeight.bold,
              color: isTotal ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.phone,
              color: Theme.of(context).primaryColor,
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'رقم محفظة ${widget.gateway.displayName}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'مثال: 01xxxxxxxxx',
            prefixIcon: const Icon(Icons.phone_android),
            prefixText: '+20 ',
            suffixIcon: _phoneController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _phoneController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            _PhoneNumberFormatter(),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'الرجاء إدخال رقم المحفظة';
            }
            if (value!.length < 11) {
              return 'رقم المحفظة غير صحيح';
            }
            if (!_isValidPhoneNumber(value)) {
              return 'رقم المحفظة غير صالح لـ ${widget.gateway.displayName}';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: 8.h),

        Text(
          _getPhoneHint(),
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock, color: Theme.of(context).primaryColor, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              'رقم PIN السري',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        TextFormField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'أدخل رقم PIN',
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'الرجاء إدخال رقم PIN';
            }
            if (value!.length < 4) {
              return 'رقم PIN يجب أن يكون 4 أرقام';
            }
            return null;
          },
        ),
        SizedBox(height: 8.h),

        Text(
          'رقم PIN الخاص بمحفظة ${widget.gateway.displayName}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                'خطوات الدفع',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          ..._getPaymentSteps().asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildInstructionStep(index + 1, step);
          }),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String instruction) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: Colors.green, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دفع آمن ومحمي',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'جميع المعاملات مشفرة بأعلى معايير الأمان. لن يتم حفظ بياناتك الحساسة.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canProceed = _phoneController.text.length >= 11 && !_isProcessing;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canProceed ? _processPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getGatewayColors().first,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: _isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    const Text('جاري المعالجة...'),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment),
                    SizedBox(width: 8.w),
                    Text(
                      'دفع ${(widget.amount + ref.read(paymentProcessProvider.notifier).calculateFees(widget.gateway, widget.amount)).toStringAsFixed(2)} ${widget.currency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper Methods
  List<Color> _getGatewayColors() {
    switch (widget.gateway) {
      case PaymentGateway.vodafoneCash:
        return [const Color(0xFFE60000), const Color(0xFFFF4444)];
      case PaymentGateway.weCash:
        return [const Color(0xFF7B3F98), const Color(0xFF9B59B6)];
      case PaymentGateway.orangeCash:
        return [const Color(0xFFFF6600), const Color(0xFFFF8533)];
      case PaymentGateway.etisalatCash:
        return [const Color(0xFF00B04F), const Color(0xFF33C86F)];
      default:
        return [Colors.blue, Colors.lightBlue];
    }
  }

  String _getPhoneHint() {
    switch (widget.gateway) {
      case PaymentGateway.vodafoneCash:
        return 'أرقام فودافون تبدأ بـ 010، 011، 012، 015';
      case PaymentGateway.weCash:
        return 'أرقام WE تبدأ بـ 011، 015';
      case PaymentGateway.orangeCash:
        return 'أرقام أورانج تبدأ بـ 010، 012';
      case PaymentGateway.etisalatCash:
        return 'أرقام اتصالات تبدأ بـ 011، 014، 017';
      default:
        return 'أدخل رقم المحفظة صحيحاً';
    }
  }

  bool _isValidPhoneNumber(String phone) {
    switch (widget.gateway) {
      case PaymentGateway.vodafoneCash:
        return phone.startsWith('010') ||
            phone.startsWith('011') ||
            phone.startsWith('012') ||
            phone.startsWith('015');
      case PaymentGateway.weCash:
        return phone.startsWith('011') || phone.startsWith('015');
      case PaymentGateway.orangeCash:
        return phone.startsWith('010') || phone.startsWith('012');
      case PaymentGateway.etisalatCash:
        return phone.startsWith('011') ||
            phone.startsWith('014') ||
            phone.startsWith('017');
      default:
        return phone.length == 11 && phone.startsWith('01');
    }
  }

  List<String> _getPaymentSteps() {
    return [
      'أدخل رقم محفظة ${widget.gateway.displayName} الخاصة بك',
      'تأكد من وجود رصيد كافي في المحفظة',
      'اضغط على "دفع" لإرسال طلب الدفع',
      'ستصلك رسالة تأكيد على هاتفك',
      'أدخل رقم PIN لتأكيد العملية',
      'ستتم معالجة الدفع فوراً بعد التأكيد',
    ];
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);

      try {
        final user = ref.read(authStateProvider).user;
        if (user == null) throw Exception('المستخدم غير مسجل دخول');

        final paymentDetails = {
          'user_id': user.id,
          'phone_number': '+20${_phoneController.text}',
          'pin': _pinController.text,
          'gateway': widget.gateway.name,
        };

        if (widget.subscriptionType != null) {
          await ref
              .read(subscriptionPaymentProvider.notifier)
              .purchaseSubscription(
                userId: user.id,
                teacherId: widget.teacherId!,
                type: widget.subscriptionType!,
                gateway: widget.gateway,
                paymentDetails: paymentDetails,
                childrenIds: widget.childrenIds ?? [],
              );
        } else {
          // Initialize payment intent
          await ref
              .read(paymentProcessProvider.notifier)
              .initializePayment(
                amount: widget.amount,
                currency: widget.currency,
                gateway: widget.gateway,
                userId: user.id,
                subscriptionId: widget.subscriptionId,
              );

          // Get the created intent
          final paymentState = ref.read(paymentProcessProvider);
          paymentState.maybeWhen(
            intentCreated: (intent) async {
              await ref
                  .read(paymentProcessProvider.notifier)
                  .processPayment(
                    intent: intent,
                    paymentDetails: paymentDetails,
                  );
            },
            orElse: () {},
          );
        }

        // Navigate to success/result screen
        if (mounted) {
          context.pushReplacementNamed('payment_result');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في معالجة الدفع: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مساعدة ${widget.gateway.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('كيفية الدفع عبر ${widget.gateway.displayName}:'),
              const SizedBox(height: 12),
              ..._getPaymentSteps().asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                );
              }),
              const SizedBox(height: 12),
              const Text(
                'ملاحظات مهمة:\n'
                '• تأكد من صحة رقم المحفظة\n'
                '• يجب وجود رصيد كافي\n'
                '• احتفظ برقم العملية للمراجعة\n'
                '• في حالة المشاكل، اتصل بخدمة العملاء',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Phone Number Formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp('[^0-9]'), '');

    return newValue.copyWith(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}
