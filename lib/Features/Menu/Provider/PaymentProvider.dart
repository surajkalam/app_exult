// ignore: file_names
import 'dart:developer';
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:coffee_exult_app/Features/Profile/data/order_model.dart';
import 'package:coffee_exult_app/Features/Profile/data/paymentorder_model.dart';
import 'package:coffee_exult_app/Services/Razorpay_Service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final service = RazorpayService();
  service.initializeRazorpay();
  return service;
});
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(
    ref,
    ref.read(razorpayServiceProvider),
    FirebaseFirestore.instance,
    FirebaseAuth.instance, // Still needed for initialization, but user access will use provider
  );
});

class PaymentState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool paymentSuccess;
  final Map<String, dynamic>? paymentData;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.paymentSuccess = false,
    this.paymentData,
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? paymentSuccess,
    Map<String, dynamic>? paymentData,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
      paymentSuccess: paymentSuccess ?? this.paymentSuccess,
      paymentData: paymentData ?? this.paymentData,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;
  final RazorpayService _razorpayService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  // ignore: unused_field
  late String _currentUser;
  late Map<String, dynamic> _paymentData;

  PaymentNotifier(this._ref,this._razorpayService, this._firestore, this._auth)
    : super(PaymentState()) {
    _currentUser = _auth.currentUser?.phoneNumber ?? 'guest';
  }

  Future<void> initiatePayment({
    required num amount,
    required String productName,
    required int quantity,
    required String orderId,
    String? orderType,
    String? customerName,
    int? tableNumber,
    List<Map<String, dynamic>>? cartItems,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    // Store payment data for later use
    _paymentData = {
      'amount': amount.toDouble(),
      'productName': productName,
      'quantity': quantity,
      'orderId': orderId,
      'timestamp': DateTime.now(),
      'status': 'initiated',
      'orderType': orderType,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'cartItems': cartItems,
    };

    try {
      final amountInPaise = (amount * 100).toInt().toString();

      _razorpayService.openCheckout(
        amount: amountInPaise,
        name: productName,
        description: '$quantity x $productName',
        orderId: orderId,
        onSuccess: _handlePaymentSuccess,
        onError: _handlePaymentError,
        contact: _currentUser
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initiate payment: $e',
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log('Stored payment data: $_paymentData');
    try {
      final orderId =
          _paymentData['orderId'] as String? ??
          'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      // Create order items from cart items
      final cartItems = _paymentData['cartItems'] as List<Map<String, dynamic>>?;
      final orderItems = cartItems?.map((item) {
        return OrderItem(
          name: item['name'] ?? 'Unknown Item',
          quantity: item['quantity'] ?? 1,
          price: (item['price'] ?? 0.0).toDouble(),
          totalPrice: ((item['price'] ?? 0.0) * (item['quantity'] ?? 1)).toDouble(),
        );
      }).toList() ?? [];

      // Calculate totals
      final subtotal = orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.10; // 10% tax
      final totalAmount = subtotal + tax;

      // Create complete order data
      final orderData = OrderData(
        orderId: orderId,
        orderType: _paymentData['orderType'] ?? 'Coffee Hub',
        customerName: _paymentData['customerName'],
        tableNumber: _paymentData['tableNumber'],
        items: orderItems,
        subtotal: subtotal,
        tax: tax,
        totalAmount: totalAmount,
        status: 'completed',
        orderDate: now,
        paymentId: response.paymentId ?? 'N/A',
      );

      final completedPaymentData = {
        'amount': _paymentData['amount']?.toDouble() ?? 0.0,
        'productName':
            _paymentData['productName']?.toString() ?? 'Unknown Product',
        'quantity': _paymentData['quantity']?.toInt() ?? 1,
        'orderId': orderId,
        'paymentId': response.paymentId ?? 'N/A',
        'signature': response.signature,
        'status': 'completed',
        'completedAt': now,
        'timestamp': _paymentData['timestamp'] is DateTime
            ? _paymentData['timestamp'] as DateTime
            : now,
      };

      await _saveOrderToFirebase(orderData);
      await _savePaymentToFirebase(completedPaymentData);

      state = state.copyWith(
        paymentSuccess: true,
        paymentData: completedPaymentData,
        successMessage: 'Payment successful! Order ID: $orderId',
      );
    } catch (e, stackTrace) {
      log('Error: $e');
      log('Stack trace: $stackTrace');
      state = state.copyWith(
        error: 'Payment successful but failed to save details: $e',
        paymentSuccess: false,
      );
    }
  }

  Future<void> _saveOrderToFirebase(OrderData orderData) async {
    final user = _ref.read(currentUserProvider);
    if (user == null || user.phoneNumber == null) {
      throw Exception('User not logged in or phone number missing');
    }

    final phoneNumber = user.phoneNumber!;

    // Save to admin orders collection
    await _firestore.collection('orders').doc(orderData.orderId).set({
      ...orderData.toMap(),
      'userPhone': phoneNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });

    log('Order details saved to Firebase orders collection successfully');
  }

  Future<void> _savePaymentToFirebase(
    Map<String, dynamic> paymentDetails,
  ) async {
    // final user = _auth.currentUser;
    // if (user == null || user.phoneNumber == null) {
    //   throw Exception('User not logged in');
    // }
  final user = _ref.read(currentUserProvider);
    if (user == null || user.phoneNumber == null) {
      throw Exception('User not logged in or phone number missing');
    }

    final usernumber = FirebaseAuth.instance.currentUser;
    late final phoneNumber = usernumber?.phoneNumber;
    // final phoneNumber = user.phoneNumber!;
    final userId =phoneNumber;
    // final phoneNumber = user.phoneNumber;

    // Reference to the user document
    final userDocRef = _firestore.collection('users').doc(userId);

    // Check if user document exists, if not create it
    final userDoc = await userDocRef.get();
    if (!userDoc.exists) {
      await userDocRef.set({
        'userId': userId,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
    // Save payment under the user's payments subcollection
    await userDocRef.collection('payments').doc(paymentDetails['orderId']).set({
      ...paymentDetails,
      'userId': userId,
      'userPhone': phoneNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _firestore
        .collection('users')
        .doc(phoneNumber)
        .collection('payments')
        .doc(paymentDetails['orderId'])
        .set(paymentDetails);

    log('Payment details saved to Firebase successfully');
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    state = state.copyWith(
      error: 'Payment failed: ${response.message}',
      paymentSuccess: false,
    );
  }
  void clearError() {
    state = state.copyWith(error: null);
  }
  void clearSuccess() {
    state = state.copyWith(
      successMessage: null,
      paymentSuccess: false,
      paymentData: null,
    );
  }
  // In your PaymentNotifier class
  Map<String, dynamic> getLastPaymentData() {
    return _paymentData;
  }

  void addPayment(PaymentData payment) {}
}
