import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:coffee_exult_app/Features/Profile/data/order_model.dart';
import '../provider/orders_provider.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final ordersNotifier = ref.read(ordersProvider.notifier);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Orders',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ordersNotifier.refreshOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(ref, ordersState.currentFilter),

          // Orders list
          Expanded(
            child: ordersState.isLoading
                ? Center(child: CircularProgressIndicator())
                : ordersState.error != null
                ? _buildErrorState(ordersState.error!, ordersNotifier)
                : ordersState.filteredOrders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersList(
                    ordersState.filteredOrders,
                    ordersNotifier,
                    colorScheme,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(WidgetRef ref, OrderFilter currentFilter) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab(ref, 'All Orders', OrderFilter.all, currentFilter),
          _buildFilterTab(
            ref,
            'Coffee Hub',
            OrderFilter.coffeeHub,
            currentFilter,
          ),
          _buildFilterTab(ref, 'Parcel', OrderFilter.parcel, currentFilter),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    WidgetRef ref,
    String label,
    OrderFilter filter,
    OrderFilter currentFilter,
  ) {
    final isSelected = currentFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(ordersProvider.notifier).setFilter(filter),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<OrderData> orders,
    OrdersNotifier ordersNotifier,
    ColorScheme colorScheme,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, context, ordersNotifier, colorScheme);
      },
    );
  }

  Widget _buildOrderCard(
    OrderData order,
    BuildContext context,
    OrdersNotifier ordersNotifier,
    ColorScheme colorscheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Text(
            'Order:${order.orderId}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: order.orderType == 'Parcel'
                  ? Colors.orange[100]
                  : Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.orderType,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: order.orderType == 'Parcel'
                    ? Colors.orange[700]
                    : Colors.blue[700],
              ),
            ),
          ),
          SizedBox(height: 8),
          // Customer info
          if (order.orderType == 'Parcel' && order.customerName != null) ...[
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Customer: ${order.customerName}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
          ],

          // Table info
          if (order.orderType == 'Coffee Hub' && order.tableNumber != null) ...[
            Row(
              children: [
                Icon(Icons.table_restaurant, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Table: ${order.tableNumber}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
          ],

          // Items
          Row(
            children: [
              Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Items: ${order.itemNames}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // Admin response section
          if (order.adminResponseMessage != null ||
              order.adminResponseTag != null) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Response:',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  if (order.adminResponseTag != null) ...[
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTagColor(
                          order.adminResponseTag!,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getTagColor(order.adminResponseTag!),
                        ),
                      ),
                      child: Text(
                        order.adminResponseTag!.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getTagColor(order.adminResponseTag!),
                        ),
                      ),
                    ),
                  ],
                  if (order.adminResponseMessage != null) ...[
                    SizedBox(height: 4),
                    Text(
                      order.adminResponseMessage!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 8),
          ],

          // Amount and date with response button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC67C4E),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy\nhh:mm a').format(order.orderDate),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 4),
                  ElevatedButton.icon(
                    onPressed: () => _showResponseDialog(
                      context,
                      order,
                      ordersNotifier,
                      colorscheme,
                    ),
                    icon: Icon(Icons.message, size: 14),
                    label: Text(
                      order.adminResponseMessage != null
                          ? 'Edit Response'
                          : 'Add Response',
                      style: GoogleFonts.dmSans(fontSize: 10),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(0, 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No orders found',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Orders will appear here after customers make purchases',
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, OrdersNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              notifier.clearError();
              notifier.refreshOrders();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showResponseDialog(
    BuildContext context,
    OrderData order,
    OrdersNotifier ordersNotifier,
    ColorScheme colorScheme,
  ) {
    final TextEditingController messageController = TextEditingController(
      text: order.adminResponseMessage ?? '',
    );
    String? selectedTag = order.adminResponseTag;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            order.adminResponseMessage != null
                ? 'Edit Response'
                : 'Add Response',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              color: Colors.brown[700],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedTag,
                decoration: InputDecoration(
                  labelText: 'Response Tag',
                  labelStyle: GoogleFonts.dmSans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['approve', 'wait', 'reject']
                    .map(
                      (tag) => DropdownMenuItem(
                        value: tag,
                        child: Text(
                          tag.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            color: _getTagColor(tag),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedTag = value;
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Response Message',
                  labelStyle: GoogleFonts.dmSans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter your response message...',
                  hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                ),
                style: GoogleFonts.dmSans(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ordersNotifier.updateOrderResponse(
                  orderId: order.orderId,
                  message: messageController.text.trim().isEmpty
                      ? null
                      : messageController.text.trim(),
                  tag: selectedTag,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getTagColor(String tag) {
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
