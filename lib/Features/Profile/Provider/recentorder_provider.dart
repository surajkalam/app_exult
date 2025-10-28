import 'package:coffee_exult_app/DATABASE_HELPER/order_database.dart';
import 'package:coffee_exult_app/Features/Profile/data/paymentorder_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderpaymentProvider = StateNotifierProvider<PaymentNotifier, List<PaymentData>>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<List<PaymentData>> {
  PaymentNotifier() : super([]) {
    _loadPayments();
  }

  final _dbHelper = DatabaseHelper.instance;

  Future<void> _loadPayments() async {
    try {
      final payments = await _dbHelper.getPayments();
      // Sort by completion date (newest first)
      payments.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      state = payments;
    } catch (e) {
      // Handle error
      state = [];
    }
  }

  Future<void> addPayment(PaymentData payment) async {
    try {
      await _dbHelper.insertPayment(payment);
      // Add to state and sort
      final updatedPayments = [...state, payment];
      updatedPayments.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      state = updatedPayments;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refreshPayments() async {
    await _loadPayments();
  }

  Future<void> clearAllPayments() async {
    try {
      await _dbHelper.clearAllPayments();
      state = [];
    } catch (e) {
      // Handle error
    }
  }

  // Get payments by status
  List<PaymentData> getPaymentsByStatus(String status) {
    return state.where((payment) => payment.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get total spent
  double getTotalSpent() {
    return state.fold(0.0, (sum, payment) => sum + payment.totalPrice);
  }

  // Get total orders count
  int getTotalOrdersCount() {
    return state.length;
  }
}
