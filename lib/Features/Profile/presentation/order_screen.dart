import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../Provider/fetchpaymentdata.dart';

class RecentOrdersScreen extends ConsumerWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(userPaymentsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Orders',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.primaryContainer,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.primary,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () {
              ref.invalidate(userPaymentsProvider);
            },
          ),
        ],
      ),
      body: paymentsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error loading orders',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (payments) => payments.isEmpty
            ? _buildEmptyState(context, colorScheme, textTheme)
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userPaymentsProvider);
                },
                child: Column(
                  children: [
                    // Summary header
                    _buildSummaryHeader(
                      context,
                      payments,
                      colorScheme,
                      textTheme,
                    ),

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
                            textTheme,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    List<Map<String, dynamic>> payments,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final totalAmount = payments.fold<double>(
      0.0,
      (sum, payment) =>
          sum +
          ((payment['amount'] ?? payment['totalPrice'] ?? 0.0) as num)
              .toDouble(),
    );
    final totalOrders = payments.length;
    final completedOrders = payments
        .where((p) => (p['status'] ?? '') == 'completed')
        .length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.1),
            colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
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
            color: colorScheme.outline.withValues(alpha: 0.3),
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
            color: colorScheme.outline.withValues(alpha: 0.3),
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
        SizedBox(height: 10),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: color.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedOrderCard(
    BuildContext context,
    Map<String, dynamic> payment,
    int index,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final status = payment['status'] ?? 'completed';
    // final statusColor = _getStatusColor(status);
    final isCompleted = status.toLowerCase() == 'completed';

    // Parse completedAt from various possible formats
    DateTime completedAt;
    try {
      final completedAtValue = payment['completedAt'] ?? payment['timestamp'];
      if (completedAtValue is DateTime) {
        completedAt = completedAtValue;
      } else if (completedAtValue is String) {
        completedAt = DateTime.parse(completedAtValue);
      } else {
        completedAt = DateTime.now();
      }
    } catch (e) {
      completedAt = DateTime.now();
    }

    final productName = payment['productName'] ?? 'Unknown Product';
    final quantity = (payment['quantity'] ?? 1) as int;
    // final price = ((payment['price'] ?? 0.0) as num).toDouble();
    final totalPrice =
        ((payment['amount'] ?? payment['totalPrice'] ?? 0.0) as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              _showOrderDetails(context, payment, colorScheme, textTheme),
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
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
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
                            productName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: colorScheme.primaryContainer,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: colorScheme.primaryContainer,
                              ),
                              SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy • hh:mm a',
                                ).format(completedAt),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    // Container(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 08,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: statusColor.withValues(alpha:0.1),
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(color: statusColor.withValues(alpha:0.3)),
                    //   ),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(
                    //         isCompleted ? Icons.check_circle : Icons.pending,
                    //         size: 12,
                    //         color: statusColor,
                    //       ),
                    //       SizedBox(width: 4),
                    //       Text(
                    //         status.toUpperCase(),
                    //         style: textTheme.labelSmall?.copyWith(
                    //           color: statusColor,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(height: 08),

                // Admin response section
                if (payment['adminResponseMessage'] != null ||
                    payment['adminResponseTag'] != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Admin Response',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (payment['adminResponseTag'] != null) ...[
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getAdminTagColor(
                                payment['adminResponseTag'],
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getAdminTagColor(
                                  payment['adminResponseTag'],
                                ),
                              ),
                            ),
                            child: Text(
                              payment['adminResponseTag'].toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _getAdminTagColor(
                                  payment['adminResponseTag'],
                                ),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                        if (payment['adminResponseMessage'] != null) ...[
                          SizedBox(height: 6),
                          Text(
                            payment['adminResponseMessage'],
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Order details
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(
                            'Quantity',
                            '${quantity}x',
                            Icons.shopping_cart,
                            textTheme,
                            colorScheme,
                          ),
                          // _buildDetailItem(
                          //   'Unit Price',
                          //   '\$${price.toStringAsFixed(2)}',
                          //   Icons.attach_money,
                          //   textTheme,
                          //   colorScheme,
                          // ),
                          _buildDetailItem(
                            'Total',
                            '\$${totalPrice.toStringAsFixed(2)}',
                            Icons.receipt,
                            textTheme,
                            colorScheme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 08),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showOrderDetails(
                          context,
                          payment,
                          colorScheme,
                          textTheme,
                        ),
                        icon: Icon(Icons.visibility, size: 16),
                        label: Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
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
                        onPressed: isCompleted
                            ? () => _reorderItem(context, payment)
                            : null,
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text(
                          'Reorder',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? colorScheme.primary
                              : colorScheme.outline,
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
        Icon(icon, size: 16, color: colorScheme.secondaryFixed),
        SizedBox(height: 8),
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primaryContainer,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.secondary,
            fontSize: 10,
            fontWeight: FontWeight.normal,
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
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
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
                color: colorScheme.primaryContainer,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your order history will appear here\nonce you make your first purchase',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
    Map<String, dynamic> payment,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Parse completedAt from various possible formats
    DateTime completedAt;
    try {
      final completedAtValue = payment['completedAt'] ?? payment['timestamp'];
      if (completedAtValue is DateTime) {
        completedAt = completedAtValue;
      } else if (completedAtValue is String) {
        completedAt = DateTime.parse(completedAtValue);
      } else {
        completedAt = DateTime.now();
      }
    } catch (e) {
      completedAt = DateTime.now();
    }

    final productName = payment['productName'] ?? 'Unknown Product';
    final quantity = (payment['quantity'] ?? 1) as int;
    // final price = ((payment['price'] ?? 0.0) as num).toDouble();
    final totalPrice =
        ((payment['amount'] ?? payment['totalPrice'] ?? 0.0) as num).toDouble();
    final status = payment['status'] ?? 'completed';

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
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: colorScheme.primaryContainer,
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
                    _buildDetailRow('Product Name', productName),
                    _buildDetailRow('Quantity', '$quantity'),
                    // _buildDetailRow(
                    //   'Unit Price',
                    //   '\$${price.toStringAsFixed(2)}',
                    // ),
                    _buildDetailRow(
                      'Total Amount',
                      '\$${totalPrice.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow('Status', status),
                    _buildDetailRow(
                      'Order Date',
                      DateFormat('MMMM dd, yyyy').format(completedAt),
                    ),
                    _buildDetailRow(
                      'Order Time',
                      DateFormat('hh:mm a').format(completedAt),
                    ),
                    if (payment['orderId'] != null)
                      _buildDetailRow('Order ID', payment['orderId']),
                    if (payment['paymentId'] != null)
                      _buildDetailRow('Payment ID', payment['paymentId']),
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
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (value == 'completed')
                  Icon(Icons.check_rounded, color: Colors.green, size: 16),
                if (value == 'completed') SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reorderItem(BuildContext context, Map<String, dynamic> payment) {
    final productName = payment['productName'] ?? 'Item';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName added to cart for reorder!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'completed':
  //       return Colors.green;
  //     case 'pending':
  //       return Colors.orange;
  //     case 'cancelled':
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  Color _getAdminTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'approve':
      case 'approved':
        return Colors.green[700]!;
      case 'wait':
      case 'waiting':
        return Colors.orange[700]!;
      case 'reject':
      case 'rejected':
        return Colors.red[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}
