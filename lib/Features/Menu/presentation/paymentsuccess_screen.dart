import 'dart:developer';

import 'package:coffee_exult_app/Features/Profile/Provider/recentorder_provider.dart';
import 'package:coffee_exult_app/Features/Profile/data/paymentorder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../../Profile/Provider/coffee_loyalty_provider.dart';
import '../../../Authentication/provider/current_user.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> paymentData;
  const PaymentSuccessScreen({super.key, required this.paymentData});

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}
class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  
  @override
   void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storePaymentData();
    });
    Timer(Duration(seconds: 4), () {
      context.go('/navbar');
    });
  }
    void _storePaymentData() {
    final payment = PaymentData(
      productName: widget.paymentData['productName'] ?? 'Unknown Product',
      quantity: widget.paymentData['quantity'] ?? 1,
      price: widget.paymentData['price']?.toDouble() ?? 0.0,
      totalPrice: widget.paymentData['totalPrice']?.toDouble() ?? 0.0,
      status: widget.paymentData['status'] ?? 'completed',
      completedAt: DateTime.now(),
    );
     
    ref.read(orderpaymentProvider.notifier).addPayment(payment);
  }

  @override
  Widget build(BuildContext context) {
    log('price: ${widget.paymentData['price']}');
    log('totalprice: ${widget.paymentData['totalPrice']}');
    // final colorScheme = Theme.of(context).colorScheme;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // Add order to loyalty system when payment is successful
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user?.phoneNumber != null) {
        ref.read(coffeeLoyaltyProvider.notifier).addOrder(user!.phoneNumber);
      }
    });
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              'Assets/Icons/Success.json',
              height: height * 0.5,
              width: width * 0.9,
              fit: BoxFit.fill,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/navbar');
            },
            child: Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}
