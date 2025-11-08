// Provider to fetch all orders and payments for admin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminFirestoreServiceProvider = Provider<AdminOrderFirestoreService>((ref) {
  return AdminOrderFirestoreService();
});

final adminOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);

  return adminService.getAllOrders().map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

final adminPaymentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);

  return adminService.getAllPayments().map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

final adminOrderStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);
  return adminService.getOrderStats();
});

final adminPaymentStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);
  return adminService.getPaymentStats();
});

// Filtered providers
final filteredAdminOrdersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final orders = ref.watch(adminOrdersProvider);
  final filter = ref.watch(orderFilterProvider);

  return orders.when(
    data: (ordersList) {
      if (filter == 'all') return ordersList;
      return ordersList.where((order) => order['status'] == filter).toList();
    },
    loading: () => [],
    error: (_,_) => [],
  );
});

final filteredAdminPaymentsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final payments = ref.watch(adminPaymentsProvider);
  final filter = ref.watch(paymentFilterProvider);

  return payments.when(
    data: (paymentsList) {
      if (filter == 'all') return paymentsList;
      return paymentsList.where((payment) => payment['status'] == filter).toList();
    },
    loading: () => [],
    error: (_,_) => [],
  );
});

// Filter providers
final orderFilterProvider = StateProvider<String>((ref) => 'all');
final paymentFilterProvider = StateProvider<String>((ref) => 'all');

class AdminOrderFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all orders for admin
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllOrders() {
    return _firestore
        .collection('admin')
        .doc('orders')
        .collection('allOrders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all payments for admin
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPayments() {
    return _firestore
        .collection('admin')
        .doc('payments')
        .collection('allPayments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update order status with admin response
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required String adminResponse,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    // Update in admin collection
    final adminRef = _firestore
        .collection('admin')
        .doc('orders')
        .collection('allOrders')
        .doc(orderId);

    batch.update(adminRef, {
      'status': status,
      'adminResponse': adminResponse,
      'updatedAt': FieldValue.serverTimestamp(),
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // Update in user's collection
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId);

    batch.update(userRef, {
      'status': status,
      'adminResponse': adminResponse,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Update payment status with admin response
  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    required String adminResponse,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    // Update in admin collection
    final adminRef = _firestore
        .collection('admin')
        .doc('payments')
        .collection('allPayments')
        .doc(paymentId);

    batch.update(adminRef, {
      'status': status,
      'adminResponse': adminResponse,
      'updatedAt': FieldValue.serverTimestamp(),
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // Update in user's collection
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('payments')
        .doc(paymentId);

    batch.update(userRef, {
      'status': status,
      'adminResponse': adminResponse,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Get order statistics
  Future<Map<String, int>> getOrderStats() async {
    final snapshot = await _firestore
        .collection('admin')
        .doc('orders')
        .collection('allOrders')
        .get();

    final total = snapshot.docs.length;
    final pending = snapshot.docs.where((doc) => doc['status'] == 'pending').length;
    final approved = snapshot.docs.where((doc) => doc['status'] == 'approved').length;
    final rejected = snapshot.docs.where((doc) => doc['status'] == 'rejected').length;

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }

  // Get payment statistics
  Future<Map<String, int>> getPaymentStats() async {
    final snapshot = await _firestore
        .collection('admin')
        .doc('payments')
        .collection('allPayments')
        .get();

    final total = snapshot.docs.length;
    final completed = snapshot.docs.where((doc) => doc['status'] == 'completed').length;
    final pending = snapshot.docs.where((doc) => doc['status'] == 'pending').length;
    final failed = snapshot.docs.where((doc) => doc['status'] == 'failed').length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'failed': failed,
    };
  }

  // Delete order (admin only)
  Future<void> deleteOrder(String orderId, String userId) async {
    final batch = _firestore.batch();

    // Delete from admin collection
    final adminRef = _firestore
        .collection('admin')
        .doc('orders')
        .collection('allOrders')
        .doc(orderId);
    batch.delete(adminRef);

    // Delete from user's collection
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId);
    batch.delete(userRef);

    await batch.commit();
  }

  // Delete payment (admin only)
  Future<void> deletePayment(String paymentId, String userId) async {
    final batch = _firestore.batch();

    // Delete from admin collection
    final adminRef = _firestore
        .collection('admin')
        .doc('payments')
        .collection('allPayments')
        .doc(paymentId);
    batch.delete(adminRef);

    // Delete from user's collection
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('payments')
        .doc(paymentId);
    batch.delete(userRef);

    await batch.commit();
  }
}