import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_model.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';
import '../models/payment_model.dart';
import '../services/auth_service.dart';

// Mock provider for words
final wordActionsProvider = Provider<WordActions>((ref) {
  return WordActions();
});

// Mock provider for recent words
final recentWordsProvider = FutureProvider<List<WordModel>>((ref) async {
  final wordActions = ref.read(wordActionsProvider);
  return wordActions.getWordsForGame('recent', count: 5);
});

// Mock auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(
    isAuthenticated: true,
    user: MockUser(
      id: '1',
      name: 'محمد أحمد',
      email: 'user@example.com',
    ),
  ));

  void signOut() {
    state = AuthState(isAuthenticated: false, user: null);
  }
}

// Mock word stats provider
final wordStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return {
    'totalWords': 150,
    'learnedWords': 85,
    'accuracy': 85,
    'streak': 7,
  };
});

// Mock parent children provider
final parentChildrenProvider = StateNotifierProvider<ParentChildrenNotifier, AsyncValue<List<UserModel>>>((ref) {
  return ParentChildrenNotifier();
});

// Mock parent stats provider
final parentStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return {
    'totalChildren': 2,
    'activeChildren': 2,
    'totalLessons': 45,
    'completedLessons': 32,
  };
});

// Mock parent subscriptions provider
final parentSubscriptionsProvider = FutureProvider<List<SubscriptionModel>>((ref) async {
  return [
    SubscriptionModel(
      id: '1',
      parentId: 'parent_1',
      teacherId: 'teacher_1',
      childrenIds: ['child_1', 'child_2'],
      subscriptionType: SubscriptionType.monthly,
      status: SubscriptionStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      amount: 50.0,
      paymentMethod: 'credit_card',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
});

// Mock payment process provider
final paymentProcessProvider = StateNotifierProvider<PaymentNotifier, PaymentProcessState>((ref) {
  return PaymentNotifier();
});

// Mock subscription payment provider
final subscriptionPaymentProvider = StateNotifierProvider<SubscriptionPaymentNotifier, Map<String, dynamic>>((ref) {
  return SubscriptionPaymentNotifier();
});

class SubscriptionPaymentNotifier extends StateNotifier<Map<String, dynamic>> {
  SubscriptionPaymentNotifier() : super({
    'status': 'pending',
    'amount': 0.0,
    'currency': 'SAR',
  });

  Future<void> purchaseSubscription({
    required String userId,
    required String teacherId,
    required SubscriptionType type,
    required PaymentGateway gateway,
    required Map<String, dynamic> paymentDetails,
  }) async {
    state = {
      ...state,
      'status': 'processing',
    };
    
    // Mock subscription purchase
    await Future<void>.delayed(const Duration(seconds: 2));
    
    state = {
      ...state,
      'status': 'success',
      'subscriptionId': 'sub_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}

enum PaymentProcessState {
  idle,
  processing,
  success,
  failed,
}

// PaymentGateway is imported from payment_model.dart

class PaymentNotifier extends StateNotifier<PaymentProcessState> {
  PaymentNotifier() : super(PaymentProcessState.idle);

  double calculateFees(double amount) {
    return amount * 0.025; // 2.5% fees
  }

  Future<void> purchaseSubscription({
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
  }) async {
    state = PaymentProcessState.processing;
    
    // Mock payment processing
    await Future<void>.delayed(const Duration(seconds: 2));
    
    // Simulate success
    state = PaymentProcessState.success;
  }

  Future<void> initializePayment({
    required double amount,
    required String currency,
    required String gateway,
  }) async {
    state = PaymentProcessState.processing;
    
    // Mock initialization
    await Future<void>.delayed(const Duration(seconds: 1));
    
    state = PaymentProcessState.idle;
  }

  Future<void> processPayment({
    required String phoneNumber,
    required double amount,
    required String gateway,
  }) async {
    state = PaymentProcessState.processing;
    
    // Mock payment processing
    await Future<void>.delayed(const Duration(seconds: 3));
    
    // Simulate success
    state = PaymentProcessState.success;
  }
}

class ParentChildrenNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  ParentChildrenNotifier() : super(const AsyncValue.loading());

  void loadChildren(String parentId) {
    // Mock children data
    state = AsyncValue.data([
      UserModel(
        id: '1',
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        userType: UserType.child,
        createdAt: DateTime.now(),
      ),
      UserModel(
        id: '2',
        name: 'فاطمة علي',
        email: 'fatima@example.com',
        userType: UserType.child,
        createdAt: DateTime.now(),
      ),
    ]);
  }

  bool canAddMoreChildren() {
    final currentChildren = state.value;
    return (currentChildren?.length ?? 0) < 5; // Max 5 children
  }

  void addChild(UserModel child) {
    state.whenData((children) {
      state = AsyncValue.data([...children, child]);
    });
  }

  void removeChild(String childId) {
    state.whenData((children) {
      state = AsyncValue.data(
        children.where((child) => child.id != childId).toList(),
      );
    });
  }
}

class MockChild {
  final String id;
  final String name;
  final int age;
  final int level;
  final int progress;

  MockChild({
    required this.id,
    required this.name,
    required this.age,
    required this.level,
    required this.progress,
  });
}

class AuthState {
  final bool isAuthenticated;
  final MockUser? user;
  
  AuthState({required this.isAuthenticated, this.user});
}

class MockUser {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  
  MockUser({
    required this.id, 
    required this.name, 
    required this.email,
    this.profileImageUrl,
  });

  String get displayName => name;
  String get initials => name.split(' ').map((e) => e[0]).join().toUpperCase();
}

class WordActions {
  Future<List<WordModel>> getWordsForGame(String gameType, {int count = 8}) async {
    // Mock words for testing
    return [
      WordModel(
        id: 1,
        wordEn: 'cat',
        wordAr: 'قطة',
        meaningAr: 'حيوان أليف',
        category: 'animals',
        createdAt: DateTime.now(),
      ),
      WordModel(
        id: 2,
        wordEn: 'book',
        wordAr: 'كتاب',
        meaningAr: 'للقراءة',
        category: 'objects',
        createdAt: DateTime.now(),
      ),
      WordModel(
        id: 3,
        wordEn: 'house',
        wordAr: 'بيت',
        meaningAr: 'مكان للسكن',
        category: 'places',
        createdAt: DateTime.now(),
      ),
      WordModel(
        id: 4,
        wordEn: 'car',
        wordAr: 'سيارة',
        meaningAr: 'وسيلة نقل',
        category: 'transport',
        createdAt: DateTime.now(),
      ),
      WordModel(
        id: 5,
        wordEn: 'tree',
        wordAr: 'شجرة',
        meaningAr: 'نبات كبير',
        category: 'nature',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
