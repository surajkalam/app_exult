
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../Provider/recentorder_provider.dart';


class RecentOrdersScreen extends ConsumerWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the paymentProvider to get the list of payments
    final payments = ref.watch(orderpaymentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Orders'),
      ),
      body: payments.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      payment.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Quantity: ${payment.quantity}'),
                        Text('Price: \$${payment.price.toStringAsFixed(2)}'),
                        Text('Total: \$${payment.totalPrice.toStringAsFixed(2)}'),
                        Text('Status: ${payment.status}'),
                        Text(
                          'Completed: ${DateFormat.yMMMd().add_jm().format(payment.completedAt)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}