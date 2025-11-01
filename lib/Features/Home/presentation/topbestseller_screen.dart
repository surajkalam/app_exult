import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/provider.dart';


class TopBestsellersScreen extends ConsumerWidget {
  const TopBestsellersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topSellersAsync = ref.watch(topSellersStreamProvider);
    final lastMonthName = ref.watch(lastMonthNameProvider);
    //  final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Top 10 Bestsellers - $lastMonthName'),
        centerTitle: true,
        actions: [
          IconButton(
            icon:  Icon(Icons.refresh),
            onPressed: () => ref.refresh(topSellersProvider),
          ),
        ],
      ),
      body: topSellersAsync.when(
        loading: () =>Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.error, size: 64, color: Colors.red),
               SizedBox(height: height*0.018),
              Text(
                'Error loading data',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(topSellersProvider),
                child: Text('Retry'),
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
                    'No sales data for $lastMonthName',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bestsellers will appear here based on last month\'s sales',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Top Performers',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                      ),
                    ),
                    Text(
                      'Based on $lastMonthName sales',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bestsellers list
              Expanded(
                child: ListView.builder(
                  itemCount: sellers.length,
                  padding:  EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final seller = sellers[index];
                    final rank = index + 1;
                    return Card(
                      margin:EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: _buildRankBadge(rank),
                        title: Text(
                          seller.userName,
                          style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primaryContainer,
                      ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${seller.paymentCount} ${seller.paymentCount == 1 ? 'sale' : 'sales'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              '\$${seller.totalAmount.toStringAsFixed(2)}',
                            
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                        trailing: rank <= 10 
                          ? Icon(
                              Icons.star,
                              color: _getRankColor(rank),
                              size: 20,
                            )
                          : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor = _getRankColor(rank);
    IconData? icon;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        break;
      case 2:
        icon = Icons.emoji_events;
        break;
      case 3:
        icon = Icons.emoji_events;
      case 4:
        icon = Icons.emoji_events;
        break;
      case 5:
        icon = Icons.emoji_events;
        break;
      case 6:
        icon = Icons.emoji_events;
      case 7:
        icon = Icons.emoji_events;
        break;
      case 8:
        icon = Icons.emoji_events;
        break;
      case 9:
        icon = Icons.emoji_events;
      case 10:
        icon = Icons.emoji_events;
        break;
      default:
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.amberAccent; // Silver
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.limeAccent; // Gold
      case 5:
        return Colors.deepOrangeAccent; // Silver
      case 6:
        return Colors.deepOrange;
      case 7:
        return Colors.orangeAccent; // Gold
      case 8:
        return Colors.orange; // Silver
      case 9:
        return Colors.blue;
      case 10:
        return Colors.blueAccent;
      default:
        return Colors.purpleAccent;
    }
  }
}
