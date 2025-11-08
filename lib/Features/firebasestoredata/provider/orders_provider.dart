import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/Profile/data/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderFilter {
  all,
  coffeeHub,
  parcel,
}

class OrdersState {
  final List<OrderData> orders;
  final bool isLoading;
  final String? error;
  final OrderFilter currentFilter;

  OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentFilter = OrderFilter.all,
  });

  OrdersState copyWith({
    List<OrderData>? orders,
    bool? isLoading,
    String? error,
    OrderFilter? currentFilter,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  List<OrderData> get filteredOrders {
    switch (currentFilter) {
      case OrderFilter.coffeeHub:
        return orders.where((order) => order.orderType == 'Coffee Hub').toList();
      case OrderFilter.parcel:
        return orders.where((order) => order.orderType == 'Parcel').toList();
      case OrderFilter.all:
        return orders;
    }
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final FirebaseFirestore _firestore;

  OrdersNotifier(this._firestore) : super(OrdersState()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      log('📋 Fetching orders from Firebase...');

      final querySnapshot = await _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      final orders = querySnapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return OrderData.fromMap(data);
        } catch (e) {
          log('❌ Error parsing order ${doc.id}: $e');
          return null;
        }
      }).whereType<OrderData>().toList();

      log('✅ Successfully fetched ${orders.length} orders');

      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      log('💥 Error fetching orders: $e');
      state = state.copyWith(
        error: 'Failed to fetch orders: $e',
        isLoading: false,
      );
    }
  }

  void setFilter(OrderFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> updateOrderResponse({
    required String orderId,
    String? message,
    String? tag,
  }) async {
    try {
      // First, get the order to find the user phone and payment ID
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final orderData = OrderData.fromMap(orderDoc.data()!);

      // Update the order document
      await _firestore.collection('orders').doc(orderId).update({
        'adminResponseMessage': message,
        'adminResponseTag': tag,
        'adminResponseTimestamp': DateTime.now().toIso8601String(),
      });

      // Also update the corresponding payment record if userPhone and paymentId exist
      if (orderData.userPhone != null && orderData.paymentId != null) {
        await _firestore
            .collection('users')
            .doc(orderData.userPhone)
            .collection('payments')
            .doc(orderData.paymentId)
            .update({
          'adminResponseMessage': message,
          'adminResponseTag': tag,
          'adminResponseTimestamp': DateTime.now().toIso8601String(),
        });
      }

      // Update local state
      final updatedOrders = state.orders.map((order) {
        if (order.orderId == orderId) {
          return OrderData(
            orderId: order.orderId,
            orderType: order.orderType,
            customerName: order.customerName,
            tableNumber: order.tableNumber,
            items: order.items,
            subtotal: order.subtotal,
            tax: order.tax,
            totalAmount: order.totalAmount,
            status: order.status,
            orderDate: order.orderDate,
            userPhone: order.userPhone,
            paymentId: order.paymentId,
            adminResponseMessage: message,
            adminResponseTag: tag,
            adminResponseTimestamp: DateTime.now(),
          );
        }
        return order;
      }).toList();

      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update order response: $e');
    }
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(FirebaseFirestore.instance);
});