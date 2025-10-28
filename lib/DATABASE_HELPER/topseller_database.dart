import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/Home/models/user_salesmodel.dart';

class FirebaseSalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get top sellers for LAST month (not current month)
  Future<List<UserSales>> getTopSellersLastMonth() async {
    try {
      final now = DateTime.now();
      // Get LAST month's dates
      final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
      final lastDayOfLastMonth = DateTime(now.year, now.month, 0);

      log('📅 Fetching bestsellers for: ${firstDayOfLastMonth.toString()} to ${lastDayOfLastMonth.toString()}');

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
            firstDayOfLastMonth,
            lastDayOfLastMonth,
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

      // Sort by total amount (descending) and take top 10
      topSellers.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      
      log('🏆 Found ${topSellers.length} sellers for last month');
      return topSellers.take(10).toList();
    } catch (e) {
      log('❌ Error fetching top sellers: $e');
      return [];
    }
  }

  // Helper method to process each user's payments with proper date handling
  Future<void> _processUserPayments(
    String userId,
    DateTime firstDayOfMonth,
    DateTime lastDayOfMonth,
    Map<String, Map<String, dynamic>> userSalesMap,
  ) async {
    try {
      // Get all completed payments for this user
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
        
        // Handle different date field formats
        DateTime? paymentDate;
        
        if (paymentData['paymentDate'] != null) {
          if (paymentData['paymentDate'] is Timestamp) {
            paymentDate = (paymentData['paymentDate'] as Timestamp).toDate();
          } else if (paymentData['paymentDate'] is DateTime) {
            paymentDate = paymentData['paymentDate'] as DateTime;
          }
        } else if (paymentData['completedAt'] != null) {
          if (paymentData['completedAt'] is Timestamp) {
            paymentDate = (paymentData['completedAt'] as Timestamp).toDate();
          } else if (paymentData['completedAt'] is DateTime) {
            paymentDate = paymentData['completedAt'] as DateTime;
          }
        }

        if (paymentDate != null) {
          // Check if payment is within last month range
          if (paymentDate.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
              paymentDate.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
            
            final amount = (paymentData['amount'] ?? paymentData['totalPrice'] ?? 0.0).toDouble();
            totalAmount += amount;
            paymentCount += 1;
            
            log('✅ Payment found for user $userId: \$${amount} on ${paymentDate.toString()}');
          }
        }
      }

      if (paymentCount > 0) {
        userSalesMap[userId] = {
          'paymentCount': paymentCount,
          'totalAmount': totalAmount,
          'userId': userId,
        };
        log('📊 User $userId: $paymentCount orders, \$${totalAmount.toStringAsFixed(2)}');
      }
    } catch (e) {
      log('❌ Error processing payments for user $userId: $e');
    }
  }

  // Get current month for comparison
  Future<List<UserSales>> getTopSellersThisMonth() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final usersSnapshot = await _firestore.collection('users').get();
      final Map<String, Map<String, dynamic>> userSalesMap = {};
      final List<Future<void>> userFutures = [];

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

      await Future.wait(userFutures);

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

      topSellers.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return topSellers.take(10).toList();
    } catch (e) {
      log('❌ Error fetching current month sellers: $e');
      return [];
    }
  }

  // Get real-time updates for last month
  Stream<List<UserSales>> getTopSellersStream() {
    return _firestore.collection('users').snapshots().asyncMap((snapshot) {
      return getTopSellersLastMonth(); // Changed to last month
    });
  }

  // Add a new payment with proper timestamp
  Future<void> addPayment({
    required String userId,
    required double amount,
    required DateTime paymentDate,
    String? productName,
    int? quantity,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('payments')
        .add({
          'userId': userId,
          'amount': amount,
          'totalPrice': amount, // Add both for compatibility
          'productName': productName ?? 'Unknown Product',
          'quantity': quantity ?? 1,
          'status': 'completed',
          'paymentDate': Timestamp.fromDate(paymentDate),
          'completedAt': Timestamp.fromDate(paymentDate), // Add both for compatibility
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

  // Get month name for display
  String getLastMonthName() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[lastMonth.month - 1]} ${lastMonth.year}';
  }
}
