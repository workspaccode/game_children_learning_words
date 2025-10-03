import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:readingquest_bilingual_learning/providers/words_provider.dart';
import '../../models/payment_model.dart';
import '../../models/subscription_model.dart';

class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    this.paymentId,
    this.subscriptionId,
    this.errorMessage,
  });

  final bool isSuccess;
  final String? paymentId;
  final String? subscriptionId;
  final String? errorMessage;

  @override
  ConsumerState<PaymentResultScreen> createState() => _PaymentResultScreenState();
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
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    if (widget.isSuccess) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _confettiController.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isSuccess 
          ? Colors.green.withValues(alpha: 0.05)
          : Colors.red.withValues(alpha: 0.05),
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildResultIcon(),
                          ),
                          SizedBox(height: 32.h),
                          _buildResultTitle(),
                          SizedBox(height: 16.h),
                          _buildResultMessage(),
                          if (widget.isSuccess) ...[
                            SizedBox(height: 32.h),
                            _buildSuccessDetails(),
                          ],
                          if (!widget.isSuccess && widget.errorMessage != null) ...[
                            SizedBox(height: 24.h),
                            _buildErrorDetails(),
                          ],
                        ],
                      ),
                    ),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isSuccess)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708, // radians for downward
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.05,
                shouldLoop: false,
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

  Widget _buildResultIcon() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: widget.isSuccess ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (widget.isSuccess ? Colors.green : Colors.red)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        widget.isSuccess ? Icons.check : Icons.close,
        size: 60.w,
        color: Colors.white,
      ),
    );
  }

  Widget _buildResultTitle() {
    return Text(
      widget.isSuccess ? 'تم الدفع بنجاح!' : 'فشل في الدفع',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: widget.isSuccess ? Colors.green : Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResultMessage() {
    String message;
    if (widget.isSuccess) {
      message = 'تمت عملية الدفع بنجاح وتم تفعيل اشتراكك';
    } else {
      message = 'حدث خطأ أثناء معالجة عملية الدفع';
    }

    return Text(
      message,
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuccessDetails() {
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
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: Colors.green, size: 24.w),
              SizedBox(width: 12.w),
              Text(
                'تفاصيل العملية',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (widget.paymentId != null)
            _buildDetailRow('رقم العملية', widget.paymentId!),
          if (widget.subscriptionId != null) ...[
            SizedBox(height: 8.h),
            _buildDetailRow('رقم الاشتراك', widget.subscriptionId!),
          ],
          SizedBox(height: 8.h),
          _buildDetailRow('التاريخ', _formatDate(DateTime.now())),
          SizedBox(height: 8.h),
          _buildDetailRow('الحالة', 'مكتمل'),
        ],
      ),
    );
  }

  Widget _buildErrorDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.errorMessage ?? 'حدث خطأ غير متوقع',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              if (widget.isSuccess) {
                // Navigate to home or dashboard
                context.go('/home');
              } else {
                // Go back to try again
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSuccess 
                  ? Colors.green 
                  : Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              widget.isSuccess ? 'العودة للرئيسية' : 'المحاولة مرة أخرى',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (!widget.isSuccess) ...[
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: OutlinedButton(
              onPressed: () {
                context.go('/home');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'العودة للرئيسية',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
