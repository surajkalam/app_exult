import 'package:coffee_exult_app/DATABASE_HELPER/order_database.dart';
import 'package:coffee_exult_app/Features/Profile/data/paymentorder_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Define the payment provider
final orderpaymentProvider = StateNotifierProvider<PaymentNotifier, List<PaymentData>>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<List<PaymentData>> {
  PaymentNotifier() : super([]) {
    _loadPayments();
  }

  final _dbHelper = DatabaseHelper.instance;

  Future<void> _loadPayments() async {
    final payments = await _dbHelper.getPayments();
    state = payments;
  }

  Future<void> addPayment(PaymentData payment) async {
    await _dbHelper.insertPayment(payment);
    state = [...state, payment];
  }
}