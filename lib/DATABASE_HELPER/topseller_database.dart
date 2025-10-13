import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/Home/models/user_salesmodel.dart';


class FirebaseSalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get top sellers for current month without complex queries
  Future<List<UserSales>> getTopSellersThisMonth() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      final Map<String, Map<String, dynamic>> userSalesMap = {};
      final List<Future<void>> userFutures = [];

      // Process each user's payments
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        userFutures.add(
          _processUserPayments(
            userId,
            firstDayOfMonth,
            lastDayOfMonth,
            userSalesMap,
          ),
        );
      }

      // Wait for all user payments to be processed
      await Future.wait(userFutures);

      // Get user details and create UserSales objects
      final List<UserSales> topSellers = [];

      for (final userId in userSalesMap.keys) {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final salesData = userSalesMap[userId]!;

          topSellers.add(
            UserSales(
              userId: userId,
              userName: userData['name'] ?? 'Unknown',
              paymentCount: salesData['paymentCount'],
              totalAmount: salesData['totalAmount'],
            ),
          );
        }
      }

      // Sort by total amount (descending)
      topSellers.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      return topSellers.take(10).toList();
    } catch (e) {
      log('Error fetching top sellers: $e');
      return [];
    }
  }

  // Helper method to process each user's payments
  Future<void> _processUserPayments(
    String userId,
    DateTime firstDayOfMonth,
    DateTime lastDayOfMonth,
    Map<String, Map<String, dynamic>> userSalesMap,
  ) async {
    try {
      // First get all completed payments for this user
      final completedPayments = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .where('status', isEqualTo: 'completed')
          .get();

      double totalAmount = 0.0;
      int paymentCount = 0;
      for (final payment in completedPayments.docs) {
        final paymentData = payment.data();
        final paymentDate = (paymentData['paymentDate']);

        if (paymentDate.isAfter(
              firstDayOfMonth.subtract(const Duration(days: 1)),
            ) &&
            paymentDate.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
          final amount = paymentData['amount'] ?? 0.0;
          totalAmount += amount;
          paymentCount += 1;
        }
      }

      if (paymentCount > 0) {
        userSalesMap[userId] = {
          'paymentCount': paymentCount,
          'totalAmount': totalAmount,
          'userId': userId,
        };
      }
    } catch (e) {
      log('Error processing payments for user $userId: $e');
    }
  }

  // Get real-time updates (simplified)
  Stream<List<UserSales>> getTopSellersStream() {
    return _firestore.collection('users').snapshots().asyncMap((snapshot) {
      return getTopSellersThisMonth();
    });
  }

  // Add a new payment
  Future<void> addPayment({
    required String userId,
    required double amount,
    required DateTime paymentDate,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('payments')
        .add({
          'userId': userId,
          'amount': amount,
          'status': 'completed',
          'paymentDate': Timestamp.fromDate(paymentDate),
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Add a new user
  Future<void> addUser({
    required String userId,
    required String name,
    String? image,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'image': image,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
