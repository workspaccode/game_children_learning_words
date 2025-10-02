import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel {
  SubscriptionModel({
    required this.id,
    required this.parentId,
    required this.teacherId,
    required this.childrenIds,
    required this.subscriptionType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.paymentMethod,
    this.paymentId,
    required this.createdAt,
    this.cancelledAt,
    this.features = const [],
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      parentId: map['parent_id'] as String,
      teacherId: map['teacher_id'] as String,
      childrenIds: List<String>.from(map['children_ids'] as List),
      subscriptionType: _parseSubscriptionType(
        map['subscription_type'] as String,
      ),
      status: _parseSubscriptionStatus(map['status'] as String),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      paymentId: map['payment_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      features: List<String>.from(map['features'] as List? ?? []),
    );
  }

  final String id;
  final String parentId;
  final String teacherId;
  final List<String> childrenIds; // max 4 children
  final SubscriptionType subscriptionType;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final List<String> features;

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'teacher_id': teacherId,
      'children_ids': childrenIds,
      'subscription_type': subscriptionType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'created_at': createdAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'features': features,
    };
  }

  // Helper methods
  bool get isActive =>
      status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);

  bool get isExpired => DateTime.now().isAfter(endDate);

  int get remainingDays => endDate.difference(DateTime.now()).inDays;

  double get monthlyAmount => subscriptionType == SubscriptionType.monthly
      ? amount
      : amount / 6; // Semi-annual divided by 6 months

  List<String> get includedFeatures {
    switch (subscriptionType) {
      case SubscriptionType.monthly:
        return [
          'تتبع تقدم الطفل اليومي',
          'تقارير أسبوعية مفصلة',
          'تواصل مع المعلم',
          'أنشطة إضافية',
          'ألعاب متقدمة',
        ];
      case SubscriptionType.semiAnnual:
        return [
          'جميع ميزات الاشتراك الشهري',
          'خصم 20%',
          'تقييم شامل للطفل',
          'خطة تعليمية مخصصة',
          'دعم فني أولوية',
          'محتوى حصري',
        ];
    }
  }

  static SubscriptionType _parseSubscriptionType(String type) {
    switch (type) {
      case 'monthly':
        return SubscriptionType.monthly;
      case 'semiAnnual':
        return SubscriptionType.semiAnnual;
      default:
        return SubscriptionType.monthly;
    }
  }

  static SubscriptionStatus _parseSubscriptionStatus(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.pending;
    }
  }

  SubscriptionModel copyWith({
    String? id,
    String? parentId,
    String? teacherId,
    List<String>? childrenIds,
    SubscriptionType? subscriptionType,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
    String? paymentMethod,
    String? paymentId,
    DateTime? createdAt,
    DateTime? cancelledAt,
    List<String>? features,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      teacherId: teacherId ?? this.teacherId,
      childrenIds: childrenIds ?? this.childrenIds,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      features: features ?? this.features,
    );
  }
}

enum SubscriptionType {
  monthly, // شهري - 50 ريال
  semiAnnual, // نصف سنوي - 240 ريال (خصم 20%)
}

enum SubscriptionStatus {
  active, // نشط
  expired, // منتهي الصلاحية
  cancelled, // ملغي
  pending, // في انتظار الدفع
}
