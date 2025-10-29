// services/admin_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all bookings for admin
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllBookings() {
    return _firestore
        .collection('admin')
        .doc('bookings')
        .collection('allBookings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update booking status with admin response
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    required String adminResponse,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    // Update in admin collection
    final adminRef = _firestore
        .collection('admin')
        .doc('bookings')
        .collection('allBookings')
        .doc(bookingId);
    
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
        .collection('bookings')
        .doc(bookingId);
    
    batch.update(userRef, {
      'status': status,
      'adminResponse': adminResponse,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Get booking statistics
  Future<Map<String, int>> getBookingStats() async {
    final snapshot = await _firestore
        .collection('admin')
        .doc('bookings')
        .collection('allBookings')
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

  // Delete booking (admin only)
  Future<void> deleteBooking(String bookingId, String userId) async {
    final batch = _firestore.batch();

    // Delete from admin collection
    final adminRef = _firestore
        .collection('admin')
        .doc('bookings')
        .collection('allBookings')
        .doc(bookingId);
    batch.delete(adminRef);

    // Delete from user's collection
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .doc(bookingId);
    batch.delete(userRef);

    await batch.commit();
  }
}