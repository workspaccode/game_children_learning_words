import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:readingquest_bilingual_learning/providers/words_provider.dart';
import '../../models/payment_model.dart';
import '../../models/subscription_model.dart';
import 'mobile_wallet_payment_screen.dart';

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

  // Mock payment gateways
  final List<PaymentGateway> _availableGateways = [
    // const PaymentGateway(name: 'stc_pay', displayName: 'STC Pay'),
    // const PaymentGateway(name: 'mada', displayName: 'مدى'),
    // const PaymentGateway(name: 'visa', displayName: 'Visa'),
    // const PaymentGateway(name: 'mastercard', displayName: 'Mastercard'),
    // const PaymentGateway(name: 'apple_pay', displayName: 'Apple Pay'),
    PaymentGateway.vodafoneCash,
    PaymentGateway.mada,
    PaymentGateway.creditCard,
    PaymentGateway.applePay,
    PaymentGateway.fawry,
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            SizedBox(height: 20.h),
            _buildAmountCard(),
            SizedBox(height: 20.h),
            _buildPaymentMethodsSection(),
            if (_selectedGateway != null) ...[
              SizedBox(height: 20.h),
              _buildFeesToggle(),
              if (_showFees) ...[
                SizedBox(height: 16.h),
                _buildFeesCard(),
              ],
              SizedBox(height: 30.h),
              _buildContinueButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: Colors.white,
            size: 32.w,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر طريقة الدفع',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'اختر الطريقة المناسبة لإتمام عملية الدفع',
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
    );
  }

  Widget _buildAmountCard() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المبلغ المطلوب',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.attach_money,
              color: Theme.of(context).primaryColor,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طرق الدفع المتاحة',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ...(_availableGateways.map((gateway) => _buildPaymentMethodCard(gateway))),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentGateway gateway) {
    final isSelected = _selectedGateway?.name == gateway.name;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGateway = gateway;
            _showFees = false;
          });
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _getGatewayColor(gateway.name).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getGatewayIcon(gateway.name),
                  color: _getGatewayColor(gateway.name),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gateway.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getGatewayDescription(gateway.name),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeesToggle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'عرض تفاصيل الرسوم والمصاريف',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.blue[700],
              ),
            ),
          ),
          Switch(
            value: _showFees,
            onChanged: (value) {
              setState(() {
                _showFees = value;
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFeesCard() {
    final fees = widget.amount * 0.025; // 2.5% fees
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
          Text(
            'تفاصيل المبلغ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFeeRow('المبلغ الأساسي', widget.amount, widget.currency),
          SizedBox(height: 8.h),
          _buildFeeRow('رسوم الخدمة (2.5%)', fees, widget.currency),
          Divider(height: 20.h),
          _buildFeeRow('المجموع الكلي', total, widget.currency, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount, String currency, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).primaryColor : Colors.grey[700],
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} $currency',
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).primaryColor : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _selectedGateway != null ? _proceedToPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          'متابعة الدفع',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getGatewayColor(String gatewayName) {
    switch (gatewayName) {
      case 'stc_pay':
        return Colors.purple;
      case 'mada':
        return Colors.green;
      case 'visa':
        return Colors.blue;
      case 'mastercard':
        return Colors.red;
      case 'apple_pay':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  IconData _getGatewayIcon(String gatewayName) {
    switch (gatewayName) {
      case 'stc_pay':
        return Icons.phone_android;
      case 'mada':
        return Icons.credit_card;
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'apple_pay':
        return Icons.apple;
      default:
        return Icons.payment;
    }
  }

  String _getGatewayDescription(String gatewayName) {
    switch (gatewayName) {
      case 'stc_pay':
        return 'دفع سريع وآمن عبر STC Pay';
      case 'mada':
        return 'بطاقة مدى المحلية';
      case 'visa':
        return 'بطاقة فيزا الائتمانية';
      case 'mastercard':
        return 'بطاقة ماستركارد الائتمانية';
      case 'apple_pay':
        return 'دفع آمن عبر Apple Pay';
      default:
        return 'طريقة دفع آمنة';
    }
  }

  void _proceedToPayment() {
    if (_selectedGateway == null) return;

    // Navigate to payment screen based on gateway type
    if (_selectedGateway!.name == 'stc_pay' || _selectedGateway!.name == 'mada') {
      // Navigate to mobile wallet payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileWalletPaymentScreen(
            gateway: _selectedGateway!,
            amount: widget.amount,
            currency: widget.currency,
            subscriptionId: widget.subscriptionId,
            subscriptionType: widget.subscriptionType,
            teacherId: widget.teacherId,
            childrenIds: widget.childrenIds,
          ),
        ),
      );
    } else {
      // For other payment methods, show a placeholder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('دفع ${_selectedGateway!.displayName} قيد التطوير'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
