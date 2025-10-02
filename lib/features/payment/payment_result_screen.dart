import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../models/payment_model.dart';
import '../../models/subscription_model.dart';
import '../../providers/payment_provider.dart';

class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({super.key});

  @override
  ConsumerState<PaymentResultScreen> createState() =>
      _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProcess = ref.watch(paymentProcessProvider);
    final subscriptionPayment = ref.watch(subscriptionPaymentProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),

                  // Result based on payment state
                  _buildResultContent(paymentProcess, subscriptionPayment),
                  SizedBox(height: 40.h),

                  // Action Buttons
                  _buildActionButtons(paymentProcess, subscriptionPayment),
                ],
              ),
            ),
          ),

          // Confetti Effect (for success)
          if (_shouldShowConfetti(paymentProcess, subscriptionPayment))
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultContent(
    PaymentProcessState paymentProcess,
    SubscriptionPaymentState subscriptionPayment,
  ) {
    // Check subscription payment first
    return subscriptionPayment.when(
      initial: _buildLoadingContent,
      processing: _buildLoadingContent,
      pending: _buildPendingContent,
      success: (subscription, payment) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confettiController.play();
        });
        return _buildSuccessContent(subscription, payment);
      },
      failed: _buildFailedContent,
      error: (message, stackTrace) => _buildErrorContent(message),
    );
  }

  Widget _buildSuccessContent(
    SubscriptionModel subscription,
    PaymentModel payment,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Success Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 80.w, color: Colors.green),
            ),
          ),
          SizedBox(height: 32.h),

          // Success Message
          Text(
            'تم الدفع بنجاح! 🎉',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          Text(
            'تهانينا! تم تفعيل اشتراكك بنجاح',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Payment Details Card
          _buildPaymentDetailsCard(payment, subscription: subscription),
          SizedBox(height: 24.h),

          // Subscription Details Card
          _buildSubscriptionDetailsCard(subscription),
        ],
      ),
    );
  }

  Widget _buildFailedContent(
    SubscriptionModel? subscription,
    PaymentModel? payment,
    String reason,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Failed Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 80.w, color: Colors.red),
            ),
          ),
          SizedBox(height: 32.h),

          // Failed Message
          Text(
            'فشل في الدفع',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          Text(
            reason,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Failure Details
          if (payment != null) ...[
            _buildPaymentDetailsCard(payment),
            SizedBox(height: 24.h),
          ],

          // Help Information
          _buildHelpCard(),
        ],
      ),
    );
  }

  Widget _buildPendingContent(
    SubscriptionModel? subscription,
    PaymentModel payment,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Pending Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule, size: 80.w, color: Colors.orange),
            ),
          ),
          SizedBox(height: 32.h),

          // Pending Message
          Text(
            'في انتظار تأكيد الدفع',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          Text(
            'نحن نعالج عملية الدفع. قد تستغرق بضع دقائق.',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Payment Details
          _buildPaymentDetailsCard(payment),
          SizedBox(height: 24.h),

          // Progress Indicator
          _buildProgressCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        SizedBox(height: 100.h),
        const CircularProgressIndicator(),
        SizedBox(height: 32.h),
        Text(
          'جاري معالجة الدفع...',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildErrorContent(String message) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 80.w, color: Colors.red),
          SizedBox(height: 24.h),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(
    PaymentModel payment, {
    SubscriptionModel? subscription,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                'تفاصيل العملية',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildDetailRow(
            'رقم العملية:',
            payment.id.substring(0, 8).toUpperCase(),
          ),
          _buildDetailRow('طريقة الدفع:', payment.gateway.displayName),
          _buildDetailRow('المبلغ:', payment.displayAmount),
          _buildDetailRow(
            'الحالة:',
            payment.status.displayName,
            valueColor: payment.status.color,
          ),
          _buildDetailRow('التاريخ:', _formatDateTime(payment.createdAt)),

          if (payment.gatewayReference != null)
            _buildDetailRow('رقم المرجع:', payment.gatewayReference!),

          if (payment.completedAt != null)
            _buildDetailRow(
              'وقت التأكيد:',
              _formatDateTime(payment.completedAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetailsCard(SubscriptionModel subscription) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                Icons.subscriptions,
                color: Theme.of(context).primaryColor,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل الاشتراك',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildDetailRow(
            'نوع الاشتراك:',
            subscription.subscriptionType == SubscriptionType.monthly
                ? 'شهري'
                : 'نصف سنوي',
          ),
          _buildDetailRow(
            'تاريخ البداية:',
            _formatDate(subscription.startDate),
          ),
          _buildDetailRow('تاريخ الانتهاء:', _formatDate(subscription.endDate)),
          _buildDetailRow('عدد الأطفال:', '${subscription.childrenIds.length}'),
          _buildDetailRow('الحالة:', 'نشط', valueColor: Colors.green),

          if (subscription.subscriptionType == SubscriptionType.semiAnnual) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings, color: Colors.green, size: 16.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'تهانينا! وفرت 20% بالاشتراك نصف السنوي',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                'تحتاج مساعدة؟',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Text(
            '• تأكد من وجود رصيد كافي في محفظتك\n'
            '• تحقق من صحة رقم المحفظة\n'
            '• جرب طريقة دفع أخرى\n'
            '• اتصل بخدمة العملاء: 19999',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 18.w),
              SizedBox(width: 8.w),
              Text(
                'معالجة الدفع...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          LinearProgressIndicator(
            backgroundColor: Colors.orange.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 8.h),

          Text(
            'يرجى الانتظار... قد تستغرق العملية بضع دقائق',
            style: TextStyle(fontSize: 12.sp, color: Colors.orange[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    PaymentProcessState paymentProcess,
    SubscriptionPaymentState subscriptionPayment,
  ) {
    return Column(
      children: [
        // Main Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleMainAction(subscriptionPayment),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getMainActionColor(subscriptionPayment),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getMainActionIcon(subscriptionPayment)),
                SizedBox(width: 8.w),
                Text(
                  _getMainActionText(subscriptionPayment),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Secondary Action Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _handleSecondaryAction(subscriptionPayment),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getSecondaryActionIcon(subscriptionPayment)),
                SizedBox(width: 8.w),
                Text(
                  _getSecondaryActionText(subscriptionPayment),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  bool _shouldShowConfetti(
    PaymentProcessState paymentProcess,
    SubscriptionPaymentState subscriptionPayment,
  ) {
    return subscriptionPayment.maybeWhen(
      success: (_, __) => true,
      orElse: () => false,
    );
  }

  Color _getMainActionColor(SubscriptionPaymentState subscriptionPayment) {
    return subscriptionPayment.when(
      initial: () => Colors.blue,
      processing: () => Colors.blue,
      pending: (_, __) => Colors.orange,
      success: (_, __) => Colors.green,
      failed: (_, __, ___) => Colors.red,
      error: (_, __) => Colors.red,
    );
  }

  IconData _getMainActionIcon(SubscriptionPaymentState subscriptionPayment) {
    return subscriptionPayment.when(
      initial: () => Icons.home,
      processing: () => Icons.home,
      pending: (_, __) => Icons.refresh,
      success: (_, __) => Icons.home,
      failed: (_, __, ___) => Icons.replay,
      error: (_, __) => Icons.replay,
    );
  }

  String _getMainActionText(SubscriptionPaymentState subscriptionPayment) {
    return subscriptionPayment.when(
      initial: () => 'الرئيسية',
      processing: () => 'الرئيسية',
      pending: (_, __) => 'تحديث الحالة',
      success: (_, __) => 'الذهاب للرئيسية',
      failed: (_, __, ___) => 'إعادة المحاولة',
      error: (_, __) => 'إعادة المحاولة',
    );
  }

  IconData _getSecondaryActionIcon(
    SubscriptionPaymentState subscriptionPayment,
  ) {
    return subscriptionPayment.when(
      initial: () => Icons.support_agent,
      processing: () => Icons.support_agent,
      pending: (_, __) => Icons.support_agent,
      success: (_, __) => Icons.receipt,
      failed: (_, __, ___) => Icons.support_agent,
      error: (_, __) => Icons.support_agent,
    );
  }

  String _getSecondaryActionText(SubscriptionPaymentState subscriptionPayment) {
    return subscriptionPayment.when(
      initial: () => 'خدمة العملاء',
      processing: () => 'خدمة العملاء',
      pending: (_, __) => 'خدمة العملاء',
      success: (_, __) => 'عرض الإيصال',
      failed: (_, __, ___) => 'خدمة العملاء',
      error: (_, __) => 'خدمة العملاء',
    );
  }

  void _handleMainAction(SubscriptionPaymentState subscriptionPayment) {
    subscriptionPayment.when(
      initial: _goToHome,
      processing: _goToHome,
      pending: (_, __) => _refreshStatus(),
      success: (_, __) => _goToHome(),
      failed: (_, __, ___) => _retryPayment(),
      error: (_, __) => _retryPayment(),
    );
  }

  void _handleSecondaryAction(SubscriptionPaymentState subscriptionPayment) {
    subscriptionPayment.when(
      initial: _contactSupport,
      processing: _contactSupport,
      pending: (_, __) => _contactSupport(),
      success: _showReceipt,
      failed: (_, __, ___) => _contactSupport(),
      error: (_, __) => _contactSupport(),
    );
  }

  void _goToHome() {
    context.goNamed('home');
  }

  void _refreshStatus() {
    // Implement status refresh logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري تحديث الحالة...')));
  }

  void _retryPayment() {
    ref.read(paymentProcessProvider.notifier).reset();
    ref.read(subscriptionPaymentProvider.notifier).reset();
    context.pop();
  }

  void _contactSupport() {
    // Implement contact support logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خدمة العملاء'),
        content: const Text(
          'يمكنك التواصل معنا:\n\n'
          '📞 الهاتف: 19999\n'
          '📧 البريد الإلكتروني: support@app.com\n'
          '💬 واتساب: +201234567890',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showReceipt(SubscriptionModel subscription, PaymentModel payment) {
    context.pushNamed(
      'payment_receipt',
      extra: {'subscription': subscription, 'payment': payment},
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
