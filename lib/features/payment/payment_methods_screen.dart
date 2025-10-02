import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/core/providers/auth_provider.dart';

import '../../models/payment_model.dart';
import '../../models/subscription_model.dart';
import '../../providers/payment_provider.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {

  const PaymentMethodsScreen({
    super.key,
    required this.amount,
    required this.currency,
    this.subscriptionId,
    this.subscriptionType,
    this.teacherId,
    this.childrenIds,
  });
  final double amount;
  final String currency;
  final String? subscriptionId;
  final SubscriptionType? subscriptionType;
  final String? teacherId;
  final List<String>? childrenIds;

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  PaymentGateway? _selectedGateway;
  bool _showFees = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final availableGateways = ref.watch(
      availablePaymentMethodsProvider('EG'),
    ); // Default to Egypt
    final paymentProcess = ref.watch(paymentProcessProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFees ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showFees = !_showFees),
            tooltip: _showFees ? 'إخفاء الرسوم' : 'عرض الرسوم',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            _buildAmountSummaryCard(),
            SizedBox(height: 24.h),

            // Payment Methods
            _buildSectionTitle('اختر طريقة الدفع', Icons.payment),
            SizedBox(height: 16.h),

            // Egyptian Payment Methods
            _buildPaymentSection(
              'طرق الدفع المصرية',
              availableGateways.where((g) => g.isEgyptianGateway).toList(),
              Colors.green,
              Icons.location_on,
            ),
            SizedBox(height: 16.h),

            // International Payment Methods
            _buildPaymentSection(
              'طرق الدفع العالمية',
              availableGateways
                  .where((g) => !g.isEgyptianGateway && !g.isWalletGateway)
                  .toList(),
              Colors.blue,
              Icons.public,
            ),
            SizedBox(height: 16.h),

            // Digital Wallets
            _buildPaymentSection(
              'المحافظ الرقمية',
              availableGateways
                  .where((g) => g.isWalletGateway && !g.isEgyptianGateway)
                  .toList(),
              Colors.purple,
              Icons.account_balance_wallet,
            ),
            SizedBox(height: 32.h),

            // Payment Details
            if (_selectedGateway != null) ...[
              _buildPaymentDetailsCard(),
              SizedBox(height: 24.h),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(paymentProcess),
    );
  }

  Widget _buildAmountSummaryCard() {
    final fees = _selectedGateway != null
        ? ref
              .read(paymentProcessProvider.notifier)
              .calculateFees(_selectedGateway!, widget.amount)
        : 0.0;
    final total = widget.amount + fees;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
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
              Icon(Icons.receipt_long, color: Colors.white, size: 24.w),
              SizedBox(width: 12.w),
              Text(
                'ملخص الفاتورة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (widget.subscriptionType != null) ...[
            _buildSummaryRow(
              'نوع الاشتراك:',
              widget.subscriptionType == SubscriptionType.monthly
                  ? 'شهري'
                  : 'نصف سنوي',
              Colors.white.withOpacity(0.9),
            ),
            SizedBox(height: 8.h),
          ],

          _buildSummaryRow(
            'المبلغ الأساسي:',
            '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
            Colors.white,
          ),

          if (_showFees && _selectedGateway != null) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              'رسوم ${_selectedGateway!.displayName}:',
              '${fees.toStringAsFixed(2)} ${widget.currency}',
              Colors.white.withOpacity(0.8),
            ),
          ],

          SizedBox(height: 12.h),
          Container(height: 1.h, color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 12.h),

          _buildSummaryRow(
            'المجموع الكلي:',
            '${total.toStringAsFixed(2)} ${widget.currency}',
            Colors.white,
            isBold: true,
            fontSize: 16.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double? fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20.w),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(
    String title,
    List<PaymentGateway> gateways,
    Color color,
    IconData icon,
  ) {
    if (gateways.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18.w),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: gateways
                  .map(_buildPaymentMethodCard)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentGateway gateway) {
    final isSelected = _selectedGateway == gateway;
    final fees = ref
        .read(paymentProcessProvider.notifier)
        .calculateFees(gateway, widget.amount);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => setState(() => _selectedGateway = gateway),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Gateway Icon
              Container(
                width: 48.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: gateway.iconAsset.contains('assets')
                      ? Image.asset(
                          gateway.iconAsset,
                          width: 32.w,
                          height: 24.h,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getGatewayIcon(gateway),
                            size: 20.w,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Icon(
                          _getGatewayIcon(gateway),
                          size: 20.w,
                          color: Theme.of(context).primaryColor,
                        ),
                ),
              ),
              SizedBox(width: 16.w),

              // Gateway Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gateway.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_showFees) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'رسوم: ${fees.toStringAsFixed(2)} ${widget.currency}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (gateway.requiresPhone || gateway.isCardGateway) ...[
                      SizedBox(height: 4.h),
                      Text(
                        gateway.requiresPhone
                            ? 'يتطلب رقم المحفظة'
                            : 'بطاقة ائتمان/خصم',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Selection Indicator
              Radio<PaymentGateway>(
                value: gateway,
                groupValue: _selectedGateway,
                onChanged: (value) => setState(() => _selectedGateway = value),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    if (_selectedGateway == null) return const SizedBox.shrink();
    final fees = ref
        .read(paymentProcessProvider.notifier)
        .calculateFees(_selectedGateway!, widget.amount);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        // color: Colors.white,
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
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل الدفع',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildDetailRow('طريقة الدفع:', _selectedGateway!.displayName),
          _buildDetailRow(
            'المبلغ:',
            '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
          ),

          if (_showFees) ...[
            _buildDetailRow(
              'الرسوم:',
              '${fees.toStringAsFixed(2)} ${widget.currency}',
            ),
            _buildDetailRow(
              'الإجمالي:',
              '${(widget.amount + fees).toStringAsFixed(2)} ${widget.currency}',
              isBold: true,
            ),
          ],

          if (_selectedGateway!.requiresPhone) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_android, color: Colors.blue, size: 16.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'ستحتاج إلى رقم محفظة ${_selectedGateway!.displayName} لإتمام الدفع',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedGateway!.isCardGateway) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green, size: 16.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'دفع آمن ومشفر بأعلى معايير الأمان',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green[700],
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

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(PaymentProcessState paymentProcess) {
    final canProceed = _selectedGateway != null;
    final isLoading = paymentProcess.maybeWhen(
      loading: () => true,
      processing: () => true,
      orElse: () => false,
    );

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
          onPressed: canProceed && !isLoading ? _proceedToPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: isLoading
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
                      'متابعة للدفع',
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

  IconData _getGatewayIcon(PaymentGateway gateway) {
    switch (gateway) {
      case PaymentGateway.stripe:
      case PaymentGateway.paypal:
        return Icons.payment;
      case PaymentGateway.fawry:
        return Icons.store;
      case PaymentGateway.vodafoneCash:
      case PaymentGateway.weCash:
      case PaymentGateway.orangeCash:
      case PaymentGateway.etisalatCash:
        return Icons.phone_android;
      case PaymentGateway.creditCard:
      case PaymentGateway.debitCard:
      case PaymentGateway.mada:
        return Icons.credit_card;
      case PaymentGateway.bankTransfer:
        return Icons.account_balance;
      case PaymentGateway.applePay:
      case PaymentGateway.googlePay:
      case PaymentGateway.samsungPay:
        return Icons.account_balance_wallet;
    }
  }

  void _proceedToPayment() {
    if (_selectedGateway == null) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    // Navigate to specific payment screen based on gateway
    switch (_selectedGateway!) {
      case PaymentGateway.vodafoneCash:
      case PaymentGateway.weCash:
      case PaymentGateway.orangeCash:
      case PaymentGateway.etisalatCash:
        _navigateToMobileWalletPayment();
        break;

      case PaymentGateway.creditCard:
      case PaymentGateway.debitCard:
      case PaymentGateway.mada:
        _navigateToCardPayment();
        break;

      case PaymentGateway.fawry:
        _navigateToFawryPayment();
        break;

      default:
        _navigateToWebPayment();
    }
  }

  void _navigateToMobileWalletPayment() {
    context.pushNamed(
      'mobile_wallet_payment',
      pathParameters: {'gateway': _selectedGateway!.name},
      extra: {
        'amount': widget.amount,
        'currency': widget.currency,
        'subscriptionId': widget.subscriptionId,
        'subscriptionType': widget.subscriptionType,
        'teacherId': widget.teacherId,
        'childrenIds': widget.childrenIds,
      },
    );
  }

  void _navigateToCardPayment() {
    context.pushNamed(
      'card_payment',
      pathParameters: {'gateway': _selectedGateway!.name},
      extra: {
        'amount': widget.amount,
        'currency': widget.currency,
        'subscriptionId': widget.subscriptionId,
        'subscriptionType': widget.subscriptionType,
        'teacherId': widget.teacherId,
        'childrenIds': widget.childrenIds,
      },
    );
  }

  void _navigateToFawryPayment() {
    context.pushNamed(
      'fawry_payment',
      extra: {
        'gateway': _selectedGateway,
        'amount': widget.amount,
        'currency': widget.currency,
        'subscriptionId': widget.subscriptionId,
        'subscriptionType': widget.subscriptionType,
        'teacherId': widget.teacherId,
        'childrenIds': widget.childrenIds,
      },
    );
  }

  void _navigateToWebPayment() {
    context.pushNamed(
      'web_payment',
      pathParameters: {'gateway': _selectedGateway!.name},
      extra: {
        'amount': widget.amount,
        'currency': widget.currency,
        'subscriptionId': widget.subscriptionId,
        'subscriptionType': widget.subscriptionType,
        'teacherId': widget.teacherId,
        'childrenIds': widget.childrenIds,
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة في الدفع'),
        content: const SingleChildScrollView(
          child: Text(
            'طرق الدفع المتاحة:\n\n'
            '🇪🇬 الطرق المصرية:\n'
            '• فوري: ادفع من أي منافذ فوري\n'
            '• فودافون كاش: ادفع من محفظتك\n'
            '• WE كاش: استخدم محفظة WE\n'
            '• أورانج كاش: ادفع بمحفظة أورانج\n'
            '• اتصالات كاش: محفظة اتصالات\n\n'
            '🌍 الطرق العالمية:\n'
            '• Stripe: بطاقات ائتمان عالمية\n'
            '• PayPal: محفظة PayPal\n'
            '• البطاقات: فيزا، ماستركارد، مدى\n\n'
            '💡 نصائح:\n'
            '• اختر الطريقة الأنسب لك\n'
            '• تأكد من وجود رصيد كافي\n'
            '• احتفظ برقم العملية للمراجعة',
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
}
