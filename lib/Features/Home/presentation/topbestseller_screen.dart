import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:coffee_shop/features/home/provider/sales_provider.dart';

class TopBestsellersScreen extends ConsumerWidget {
  const TopBestsellersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topSellersAsync = ref.watch(topSellersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Top Bestsellers - ${DateFormat('MMMM yyyy').format(DateTime.now())}',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(topSellersProvider),
          ),
        ],
      ),
      body: topSellersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (sellers) {
          if (sellers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No sales data this month',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transactions will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: sellers.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final seller = sellers[index];
              final rank = index + 1;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: _buildRankBadge(rank),
                  title: Text(
                    seller.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${seller.paymentCount} ${seller.paymentCount == 1 ? 'sale' : 'sales'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        '\$${seller.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.brown;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.blue;
        icon = null;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}