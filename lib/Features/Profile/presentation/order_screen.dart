
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../Provider/recentorder_provider.dart';


class RecentOrdersScreen extends ConsumerWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(orderpaymentProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Recent Orders',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () {
              ref.read(orderpaymentProvider.notifier).refreshPayments();
            },
          ),
        ],
      ),
      body: payments.isEmpty
          ? _buildEmptyState(context, colorScheme, textTheme)
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(orderpaymentProvider.notifier).refreshPayments();
              },
              child: Column(
                children: [
                  // Summary header
                  _buildSummaryHeader(context, payments, colorScheme, textTheme),
                  
                  // Orders list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return _buildEnhancedOrderCard(
                          context, 
                          payment, 
                          index, 
                          colorScheme, 
                          textTheme
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    List<dynamic> payments,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final totalAmount = payments.fold<double>(
      0.0, 
      (sum, payment) => sum + (payment.totalPrice ?? 0.0)
    );
    final totalOrders = payments.length;
    final completedOrders = payments.where((p) => p.status == 'completed').length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.1),
            colorScheme.secondaryContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Spent',
              '\$${totalAmount.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              colorScheme.primary,
              textTheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Total Orders',
              '$totalOrders',
              Icons.shopping_bag,
              colorScheme.secondary,
              textTheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Completed',
              '$completedOrders',
              Icons.check_circle,
              Colors.green,
              textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedOrderCard(
    BuildContext context,
    dynamic payment,
    int index,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final statusColor = _getStatusColor(payment.status);
    final isCompleted = payment.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(context, payment, colorScheme, textTheme),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Product icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_cafe,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.productName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a').format(payment.completedAt),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.pending,
                            size: 12,
                            color: statusColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            payment.status.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Order details
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(
                            'Quantity',
                            '${payment.quantity}x',
                            Icons.shopping_cart,
                            textTheme,
                            colorScheme,
                          ),
                          _buildDetailItem(
                            'Unit Price',
                            '\$${payment.price.toStringAsFixed(2)}',
                            Icons.attach_money,
                            textTheme,
                            colorScheme,
                          ),
                          _buildDetailItem(
                            'Total',
                            '\$${payment.totalPrice.toStringAsFixed(2)}',
                            Icons.receipt,
                            textTheme,
                            colorScheme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showOrderDetails(context, payment, colorScheme, textTheme),
                        icon: Icon(Icons.visibility, size: 16),
                        label: Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isCompleted ? () => _reorderItem(context, payment) : null,
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Reorder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? colorScheme.primary : colorScheme.outline,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        SizedBox(height: 4),
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Orders Yet',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your order history will appear here\nonce you make your first purchase',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.shopping_cart),
              label: Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    dynamic payment,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Order Details',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Details content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Product Name', payment.productName),
                    _buildDetailRow('Quantity', '${payment.quantity}'),
                    _buildDetailRow('Unit Price', '\$${payment.price.toStringAsFixed(2)}'),
                    _buildDetailRow('Total Amount', '\$${payment.totalPrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Status', payment.status),
                    _buildDetailRow('Order Date', DateFormat('MMMM dd, yyyy').format(payment.completedAt)),
                    _buildDetailRow('Order Time', DateFormat('hh:mm a').format(payment.completedAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reorderItem(BuildContext context, dynamic payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${payment.productName} added to cart for reorder!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
