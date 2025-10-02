import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {

  const PaymentModel({
    required this.id,
    required this.userId,
    this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.status,
    required this.type,
    this.metadata,
    this.gatewayTransactionId,
    this.gatewayReference,
    this.failureReason,
    required this.createdAt,
    this.completedAt,
    this.expiresAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
  final String id;
  final String userId;
  final String? subscriptionId;
  final double amount;
  final String currency;
  final PaymentGateway gateway;
  final PaymentStatus status;
  final PaymentType type;
  final Map<String, dynamic>? metadata;
  final String? gatewayTransactionId;
  final String? gatewayReference;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? subscriptionId,
    double? amount,
    String? currency,
    PaymentGateway? gateway,
    PaymentStatus? status,
    PaymentType? type,
    Map<String, dynamic>? metadata,
    String? gatewayTransactionId,
    String? gatewayReference,
    String? failureReason,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      gateway: gateway ?? this.gateway,
      status: status ?? this.status,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
      gatewayReference: gatewayReference ?? this.gatewayReference,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isPending => status == PaymentStatus.pending;
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get displayAmount => '${amount.toStringAsFixed(2)} $currency';
}

enum PaymentGateway {
  @JsonValue('stripe')
  stripe,
  @JsonValue('paypal')
  paypal,
  @JsonValue('fawry')
  fawry,
  @JsonValue('vodafone_cash')
  vodafoneCash,
  @JsonValue('we_cash')
  weCash,
  @JsonValue('orange_cash')
  orangeCash,
  @JsonValue('etisalat_cash')
  etisalatCash,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('debit_card')
  debitCard,
  @JsonValue('mada')
  mada,
  @JsonValue('apple_pay')
  applePay,
  @JsonValue('google_pay')
  googlePay,
  @JsonValue('samsung_pay')
  samsungPay,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
  @JsonValue('expired')
  expired,
}

enum PaymentType {
  @JsonValue('subscription')
  subscription,
  @JsonValue('top_up')
  topUp,
  @JsonValue('purchase')
  purchase,
  @JsonValue('refund')
  refund,
}

extension PaymentGatewayExtension on PaymentGateway {
  String get displayName {
    switch (this) {
      case PaymentGateway.stripe:
        return 'Stripe';
      case PaymentGateway.paypal:
        return 'PayPal';
      case PaymentGateway.fawry:
        return 'فوري';
      case PaymentGateway.vodafoneCash:
        return 'فودافون كاش';
      case PaymentGateway.weCash:
        return 'WE كاش';
      case PaymentGateway.orangeCash:
        return 'أورانج كاش';
      case PaymentGateway.etisalatCash:
        return 'اتصالات كاش';
      case PaymentGateway.bankTransfer:
        return 'تحويل بنكي';
      case PaymentGateway.creditCard:
        return 'بطاقة ائتمان';
      case PaymentGateway.debitCard:
        return 'بطاقة خصم';
      case PaymentGateway.mada:
        return 'مدى';
      case PaymentGateway.applePay:
        return 'Apple Pay';
      case PaymentGateway.googlePay:
        return 'Google Pay';
      case PaymentGateway.samsungPay:
        return 'Samsung Pay';
    }
  }

  String get iconAsset {
    switch (this) {
      case PaymentGateway.stripe:
        return 'assets/icons/stripe.png';
      case PaymentGateway.paypal:
        return 'assets/icons/paypal.png';
      case PaymentGateway.fawry:
        return 'assets/icons/fawry.png';
      case PaymentGateway.vodafoneCash:
        return 'assets/icons/vodafone_cash.png';
      case PaymentGateway.weCash:
        return 'assets/icons/we_cash.png';
      case PaymentGateway.orangeCash:
        return 'assets/icons/orange_cash.png';
      case PaymentGateway.etisalatCash:
        return 'assets/icons/etisalat_cash.png';
      case PaymentGateway.bankTransfer:
        return 'assets/icons/bank.png';
      case PaymentGateway.creditCard:
        return 'assets/icons/credit_card.png';
      case PaymentGateway.debitCard:
        return 'assets/icons/debit_card.png';
      case PaymentGateway.mada:
        return 'assets/icons/mada.png';
      case PaymentGateway.applePay:
        return 'assets/icons/apple_pay.png';
      case PaymentGateway.googlePay:
        return 'assets/icons/google_pay.png';
      case PaymentGateway.samsungPay:
        return 'assets/icons/samsung_pay.png';
    }
  }

  bool get isEgyptianGateway {
    return [
      PaymentGateway.fawry,
      PaymentGateway.vodafoneCash,
      PaymentGateway.weCash,
      PaymentGateway.orangeCash,
      PaymentGateway.etisalatCash,
    ].contains(this);
  }

  bool get isWalletGateway {
    return [
      PaymentGateway.vodafoneCash,
      PaymentGateway.weCash,
      PaymentGateway.orangeCash,
      PaymentGateway.etisalatCash,
      PaymentGateway.applePay,
      PaymentGateway.googlePay,
      PaymentGateway.samsungPay,
    ].contains(this);
  }

  bool get isCardGateway {
    return [
      PaymentGateway.creditCard,
      PaymentGateway.debitCard,
      PaymentGateway.mada,
    ].contains(this);
  }

  bool get requiresPhone {
    return isWalletGateway && isEgyptianGateway;
  }

  bool get supportsInstallments {
    return [PaymentGateway.creditCard, PaymentGateway.fawry].contains(this);
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'في انتظار الدفع';
      case PaymentStatus.processing:
        return 'جاري المعالجة';
      case PaymentStatus.completed:
        return 'مكتمل';
      case PaymentStatus.failed:
        return 'فشل';
      case PaymentStatus.cancelled:
        return 'ملغي';
      case PaymentStatus.refunded:
        return 'مُسترد';
      case PaymentStatus.expired:
        return 'منتهي الصلاحية';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.expired:
        return Colors.grey;
    }
  }
}

@JsonSerializable()
class PaymentIntent {

  const PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.gateway,
    this.metadata,
    required this.createdAt,
    required this.expiresAt,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentFromJson(json);
  final String id;
  final String clientSecret;
  final double amount;
  final String currency;
  final PaymentGateway gateway;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => _$PaymentIntentToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

@JsonSerializable()
class PaymentMethod {

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.gateway,
    required this.displayName,
    required this.details,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
  final String id;
  final String userId;
  final PaymentGateway gateway;
  final String displayName;
  final Map<String, dynamic> details;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentGateway? gateway,
    String? displayName,
    Map<String, dynamic>? details,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gateway: gateway ?? this.gateway,
      displayName: displayName ?? this.displayName,
      details: details ?? this.details,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  String? get maskedNumber {
    if (gateway.isCardGateway) {
      return details['masked_number'] as String?;
    }
    if (gateway.requiresPhone) {
      return details['phone_number'] as String?;
    }
    return null;
  }

  String? get cardBrand {
    if (gateway.isCardGateway) {
      return details['brand'] as String?;
    }
    return null;
  }
}

@JsonSerializable()
class RefundRequest {

  const RefundRequest({
    required this.id,
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.status,
    this.gatewayRefundId,
    required this.createdAt,
    this.processedAt,
  });

  factory RefundRequest.fromJson(Map<String, dynamic> json) =>
      _$RefundRequestFromJson(json);
  final String id;
  final String paymentId;
  final String userId;
  final double amount;
  final String reason;
  final RefundStatus status;
  final String? gatewayRefundId;
  final DateTime createdAt;
  final DateTime? processedAt;

  Map<String, dynamic> toJson() => _$RefundRequestToJson(this);
  Map<String, dynamic> toMap() => toJson();
}

enum RefundStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}
