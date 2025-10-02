import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:uuid/uuid.dart';

import '../models/payment_model.dart';
import '../models/subscription_model.dart';
import 'firebase_database_service.dart';

class PaymentService {
  PaymentService._internal();

  static PaymentService? _instance;
  static PaymentService get instance =>
      _instance ??= PaymentService._internal();

  final Dio _dio = Dio();
  final _uuid = const Uuid();
  final _database = FirebaseDatabaseService.instance;

  // Configuration - يجب تعديل هذه القيم حسب مشروعك
  static const String _baseUrl = String.fromEnvironment(
    'PAYMENT_BASE_URL',
    defaultValue: 'https://api.your-app.com', // ضع URL الخاص بك هنا
  );
  static const String _stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_your_stripe_key', // ضع مفتاح Stripe هنا
  );
  static const String _fawryMerchantCode = String.fromEnvironment(
    'FAWRY_MERCHANT_CODE',
    defaultValue: 'your_fawry_code', // ضع كود فوري هنا
  );
  static const String _fawrySecretKey = String.fromEnvironment(
    'FAWRY_SECRET_KEY',
    defaultValue: 'your_fawry_secret', // ضع مفتاح فوري هنا
  );

  // تهيئة خدمة الدفع
  Future<void> initialize() async {
    try {
      // التحقق من وجود المفاتيح المطلوبة
      if (_stripePublishableKey.contains('your_stripe_key')) {
        debugPrint('⚠️ تحذير: يجب تعديل مفتاح Stripe في payment_service.dart');
      }

      // تهيئة Stripe
      stripe.Stripe.publishableKey = _stripePublishableKey;

      // تكوين Dio للاتصالات
      _dio.options.baseUrl = _baseUrl;
      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 30);

      // إضافة interceptors للتسجيل في وضع التطوير
      if (kDebugMode) {
        _dio.interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (object) =>
                debugPrint('💳 Payment API: ${object.toString()}'),
          ),
        );
      }

      debugPrint('✅ تم تهيئة خدمة الدفع بنجاح');
    } catch (e) {
      debugPrint('❌ فشل في تهيئة خدمة الدفع: $e');
      rethrow;
    }
  }

  // Create Payment Intent
  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String currency,
    required PaymentGateway gateway,
    required String userId,
    String? subscriptionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final intentId = _uuid.v4();

      switch (gateway) {
        case PaymentGateway.stripe:
          return await _createStripePaymentIntent(
            intentId: intentId,
            amount: amount,
            currency: currency,
            userId: userId,
            subscriptionId: subscriptionId,
            metadata: metadata,
          );

        case PaymentGateway.fawry:
          return await _createFawryPaymentIntent(
            intentId: intentId,
            amount: amount,
            currency: currency,
            userId: userId,
            subscriptionId: subscriptionId,
            metadata: metadata,
          );

        case PaymentGateway.vodafoneCash:
        case PaymentGateway.weCash:
        case PaymentGateway.orangeCash:
        case PaymentGateway.etisalatCash:
          return await _createMobileWalletPaymentIntent(
            intentId: intentId,
            amount: amount,
            currency: currency,
            gateway: gateway,
            userId: userId,
            subscriptionId: subscriptionId,
            metadata: metadata,
          );

        default:
          throw PaymentException(
            'Payment gateway ${gateway.displayName} not supported yet',
          );
      }
    } catch (e) {
      debugPrint('❌ Failed to create payment intent: $e');
      throw PaymentException(
        'Failed to create payment intent: ${e.toString()}',
      );
    }
  }

  // Process Payment
  Future<PaymentModel> processPayment({
    required PaymentIntent intent,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final paymentId = _uuid.v4();
      final now = DateTime.now();

      // Create initial payment record
      final payment = PaymentModel(
        id: paymentId,
        userId: (paymentDetails['user_id'] as String?) ?? '',
        subscriptionId: intent.metadata?['subscription_id'] as String?,
        amount: intent.amount,
        currency: intent.currency,
        gateway: intent.gateway,
        status: PaymentStatus.processing,
        type: PaymentType.subscription,
        metadata: intent.metadata,
        createdAt: now,
      );

      // Save payment to database
      await _database.createPayment(payment);

      // Process based on gateway
      PaymentModel processedPayment;
      switch (intent.gateway) {
        case PaymentGateway.stripe:
          processedPayment = await _processStripePayment(
            payment,
            paymentDetails,
          );
          break;

        case PaymentGateway.fawry:
          processedPayment = await _processFawryPayment(
            payment,
            paymentDetails,
          );
          break;

        case PaymentGateway.vodafoneCash:
        case PaymentGateway.weCash:
        case PaymentGateway.orangeCash:
        case PaymentGateway.etisalatCash:
          processedPayment = await _processMobileWalletPayment(
            payment,
            paymentDetails,
          );
          break;

        default:
          throw PaymentException(
            'Payment processing not implemented for ${intent.gateway.displayName}',
          );
      }

      // Update payment in database
      await _database.updatePayment(processedPayment);

      // If payment successful and has subscription, activate subscription
      if (processedPayment.isCompleted &&
          processedPayment.subscriptionId != null) {
        await _activateSubscription(processedPayment.subscriptionId!);
      }

      return processedPayment;
    } catch (e) {
      debugPrint('❌ Failed to process payment: $e');

      // Update payment status to failed
      final failedPayment = PaymentModel(
        id: (paymentDetails['payment_id'] as String?) ?? _uuid.v4(),
        userId: (paymentDetails['user_id'] as String?) ?? '',
        amount: intent.amount,
        currency: intent.currency,
        gateway: intent.gateway,
        status: PaymentStatus.failed,
        type: PaymentType.subscription,
        failureReason: e.toString(),
        createdAt: DateTime.now(),
      );

      await _database.updatePayment(failedPayment);
      throw PaymentException('Payment processing failed: ${e.toString()}');
    }
  }

  // Get Available Payment Methods
  List<PaymentGateway> getAvailablePaymentMethods(String countryCode) {
    final List<PaymentGateway> methods = [];

    // Always available (global)
    methods.addAll([
      PaymentGateway.stripe,
      PaymentGateway.paypal,
      PaymentGateway.creditCard,
      PaymentGateway.debitCard,
    ]);

    // Egyptian payment methods
    if (countryCode.toUpperCase() == 'EG') {
      methods.addAll([
        PaymentGateway.fawry,
        PaymentGateway.vodafoneCash,
        PaymentGateway.weCash,
        PaymentGateway.orangeCash,
        PaymentGateway.etisalatCash,
        PaymentGateway.mada,
        PaymentGateway.bankTransfer,
      ]);
    }

    // Platform-specific methods
    if (Platform.isIOS) {
      methods.add(PaymentGateway.applePay);
    }
    if (Platform.isAndroid) {
      methods.addAll([PaymentGateway.googlePay, PaymentGateway.samsungPay]);
    }

    return methods;
  }

  // Validate Payment Details
  bool validatePaymentDetails(
    PaymentGateway gateway,
    Map<String, dynamic> details,
  ) {
    switch (gateway) {
      case PaymentGateway.vodafoneCash:
      case PaymentGateway.weCash:
      case PaymentGateway.orangeCash:
      case PaymentGateway.etisalatCash:
        return _validatePhoneNumber(details['phone_number'] as String?);

      case PaymentGateway.creditCard:
      case PaymentGateway.debitCard:
      case PaymentGateway.mada:
        return _validateCardDetails(details);

      default:
        return true; // For gateways that don't require pre-validation
    }
  }

  // Create Refund
  Future<RefundRequest> createRefund({
    required String paymentId,
    required double amount,
    required String reason,
    required String userId,
  }) async {
    try {
      final refundId = _uuid.v4();

      final refund = RefundRequest(
        id: refundId,
        paymentId: paymentId,
        userId: userId,
        amount: amount,
        reason: reason,
        status: RefundStatus.pending,
        createdAt: DateTime.now(),
      );

      // Save refund request
      await _database.createRefundRequest(refund);

      // TODO: Process refund based on original payment gateway

      return refund;
    } catch (e) {
      throw PaymentException('Failed to create refund: ${e.toString()}');
    }
  }

  // Private Methods

  Future<PaymentIntent> _createStripePaymentIntent({
    required String intentId,
    required double amount,
    required String currency,
    required String userId,
    String? subscriptionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/payments/stripe/create-intent',
        data: {
          'amount': (amount * 100).round(), // Stripe uses cents
          'currency': currency.toLowerCase(),
          'metadata': {
            'user_id': userId,
            'subscription_id': subscriptionId,
            ...?metadata,
          },
        },
      );

      final data = response.data;
      if (data == null) {
        throw const PaymentException('Invalid response from Stripe API');
      }
      return PaymentIntent(
        id: intentId,
        clientSecret: data['client_secret'] as String,
        amount: amount,
        currency: currency,
        gateway: PaymentGateway.stripe,
        metadata: metadata,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
    } catch (e) {
      throw PaymentException(
        'Failed to create Stripe payment intent: ${e.toString()}',
      );
    }
  }

  Future<PaymentIntent> _createFawryPaymentIntent({
    required String intentId,
    required double amount,
    required String currency,
    required String userId,
    String? subscriptionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final merchantRefNum = _uuid.v4();
      final signature = _generateFawrySignature(merchantRefNum, amount);

      final response = await _dio.post<Map<String, dynamic>>(
        '/payments/fawry/create-intent',
        data: {
          'merchantCode': _fawryMerchantCode,
          'merchantRefNum': merchantRefNum,
          'amount': amount,
          'signature': signature,
          'description': 'Education App Subscription',
          'metadata': {
            'user_id': userId,
            'subscription_id': subscriptionId,
            ...?metadata,
          },
        },
      );

      final data = response.data;
      if (data == null) {
        throw const PaymentException('Invalid response from Fawry API');
      }
      return PaymentIntent(
        id: intentId,
        clientSecret: data['payment_url'] as String,
        amount: amount,
        currency: currency,
        gateway: PaymentGateway.fawry,
        metadata: {'merchant_ref_num': merchantRefNum, ...?metadata},
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    } catch (e) {
      throw PaymentException(
        'Failed to create Fawry payment intent: ${e.toString()}',
      );
    }
  }

  Future<PaymentIntent> _createMobileWalletPaymentIntent({
    required String intentId,
    required double amount,
    required String currency,
    required PaymentGateway gateway,
    required String userId,
    String? subscriptionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/payments/mobile-wallet/create-intent',
        data: {
          'gateway': gateway.name,
          'amount': amount,
          'currency': currency,
          'metadata': {
            'user_id': userId,
            'subscription_id': subscriptionId,
            ...?metadata,
          },
        },
      );

      final data = response.data;
      if (data == null) {
        throw const PaymentException('Invalid response from Mobile Wallet API');
      }
      return PaymentIntent(
        id: intentId,
        clientSecret: data['payment_url'] as String,
        amount: amount,
        currency: currency,
        gateway: gateway,
        metadata: metadata,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );
    } catch (e) {
      throw PaymentException(
        'Failed to create ${gateway.displayName} payment intent: ${e.toString()}',
      );
    }
  }

  Future<PaymentModel> _processStripePayment(
    PaymentModel payment,
    Map<String, dynamic> details,
  ) async {
    try {
      // Stripe processing logic would go here
      // For now, we'll simulate success
      await Future<void>.delayed(const Duration(seconds: 2));

      return payment.copyWith(
        status: PaymentStatus.completed,
        gatewayTransactionId: 'pi_${_uuid.v4()}',
        completedAt: DateTime.now(),
      );
    } catch (e) {
      throw PaymentException('Stripe payment failed: ${e.toString()}');
    }
  }

  Future<PaymentModel> _processFawryPayment(
    PaymentModel payment,
    Map<String, dynamic> details,
  ) async {
    try {
      // Fawry processing logic would go here
      await Future<void>.delayed(const Duration(seconds: 3));

      return payment.copyWith(
        status: PaymentStatus.completed,
        gatewayTransactionId: 'fawry_${_uuid.v4()}',
        gatewayReference: details['reference_number'] as String?,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      throw PaymentException('Fawry payment failed: ${e.toString()}');
    }
  }

  Future<PaymentModel> _processMobileWalletPayment(
    PaymentModel payment,
    Map<String, dynamic> details,
  ) async {
    try {
      // Mobile wallet processing logic would go here
      await Future<void>.delayed(const Duration(seconds: 2));

      return payment.copyWith(
        status: PaymentStatus.completed,
        gatewayTransactionId: '${payment.gateway.name}_${_uuid.v4()}',
        gatewayReference: details['transaction_id'] as String?,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      throw PaymentException(
        '${payment.gateway.displayName} payment failed: ${e.toString()}',
      );
    }
  }

  String _generateFawrySignature(String merchantRefNum, double amount) {
    final input =
        '$_fawryMerchantCode$merchantRefNum${amount.toStringAsFixed(2)}$_fawrySecretKey';
    return sha256.convert(utf8.encode(input)).toString();
  }

  bool _validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return false;

    // Egyptian mobile number validation
    final egyptianMobileRegex = RegExp(r'^(\+201|01)[0-9]{9}$');
    return egyptianMobileRegex.hasMatch(phoneNumber);
  }

  bool _validateCardDetails(Map<String, dynamic> details) {
    final cardNumber = details['card_number'] as String?;
    final expiryMonth = details['expiry_month'] as int?;
    final expiryYear = details['expiry_year'] as int?;
    final cvv = details['cvv'] as String?;

    if (cardNumber == null ||
        expiryMonth == null ||
        expiryYear == null ||
        cvv == null) {
      return false;
    }

    // Basic card validation
    return cardNumber.length >= 13 &&
        cardNumber.length <= 19 &&
        expiryMonth >= 1 &&
        expiryMonth <= 12 &&
        expiryYear >= DateTime.now().year &&
        cvv.length >= 3 &&
        cvv.length <= 4;
  }

  Future<void> _activateSubscription(String subscriptionId) async {
    try {
      final subscription = await _database.getSubscriptionById(subscriptionId);
      if (subscription != null) {
        final activatedSubscription = subscription.copyWith(
          status: SubscriptionStatus.active,
        );
        await _database.updateSubscription(activatedSubscription);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to activate subscription: $e');
    }
  }
}

class PaymentException implements Exception {
  const PaymentException(this.message, [this.code]);
  final String message;
  final String? code;

  @override
  String toString() => 'PaymentException: $message';
}

// Payment Configuration Class
class PaymentConfig {
  static const Map<String, Map<String, dynamic>> gatewayConfig = {
    'stripe': {
      'name': 'Stripe',
      'fees': 2.9, // Percentage
      'fixed_fee': 0.30, // USD
      'currencies': ['USD', 'EUR', 'GBP', 'EGP'],
      'min_amount': 0.50,
      'max_amount': 999999.99,
    },
    'fawry': {
      'name': 'Fawry',
      'fees': 2.0,
      'fixed_fee': 2.0, // EGP
      'currencies': ['EGP'],
      'min_amount': 5.0,
      'max_amount': 50000.0,
    },
    'vodafone_cash': {
      'name': 'Vodafone Cash',
      'fees': 1.5,
      'fixed_fee': 1.0,
      'currencies': ['EGP'],
      'min_amount': 5.0,
      'max_amount': 30000.0,
    },
    'we_cash': {
      'name': 'WE Cash',
      'fees': 1.5,
      'fixed_fee': 1.0,
      'currencies': ['EGP'],
      'min_amount': 5.0,
      'max_amount': 30000.0,
    },
    'orange_cash': {
      'name': 'Orange Cash',
      'fees': 1.5,
      'fixed_fee': 1.0,
      'currencies': ['EGP'],
      'min_amount': 5.0,
      'max_amount': 30000.0,
    },
    'etisalat_cash': {
      'name': 'Etisalat Cash',
      'fees': 1.5,
      'fixed_fee': 1.0,
      'currencies': ['EGP'],
      'min_amount': 5.0,
      'max_amount': 30000.0,
    },
  };

  static double calculateFees(PaymentGateway gateway, double amount) {
    final config = gatewayConfig[gateway.name];
    if (config == null) return 0;

    final percentage = (config['fees'] as double) / 100;
    final fixedFee = config['fixed_fee'] as double;

    return (amount * percentage) + fixedFee;
  }

  static bool isAmountValid(PaymentGateway gateway, double amount) {
    final config = gatewayConfig[gateway.name];
    if (config == null) return true;

    final minAmount = config['min_amount'] as double;
    final maxAmount = config['max_amount'] as double;

    return amount >= minAmount && amount <= maxAmount;
  }

  static bool isCurrencySupported(PaymentGateway gateway, String currency) {
    final config = gatewayConfig[gateway.name];
    if (config == null) return false;

    final supportedCurrencies = config['currencies'] as List<String>;
    return supportedCurrencies.contains(currency.toUpperCase());
  }
}
