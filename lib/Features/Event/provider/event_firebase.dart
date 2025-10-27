
// services/firestore_service.dart
// services/user_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/event_model.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveBooking({
    required String userId,
    required EventBooking booking,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    final bookingId = _firestore.collection('bookings').doc().id;
    
    // Enhanced booking data with better structure
    final bookingData = {
      ...booking.toMap(),
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userNote': _getUserFriendlyNote(booking.eventType), // Add friendly note
    };

    // Save to user's bookings
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .doc(bookingId)
        .set(bookingData);

    // Save to admin bookings for easy access
    await _firestore
        .collection('admin')
        .doc('bookings')
        .collection('allBookings')
        .doc(bookingId)
        .set({
          'bookingId': bookingId,
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
          'bookingDetails': bookingData,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'adminResponse': '',
          'priority': _getBookingPriority(booking.eventType), // For sorting
        });

    return bookingId;
  }

  // Get user-friendly note based on event type
  String _getUserFriendlyNote(String eventType) {
    final notes = {
      'Birthday Party': 'We\'ll make your celebration special! 🎉',
      'Anniversary': 'Congratulations! Let us help you celebrate love 💕',
      'Baby Shower': 'Exciting times ahead! Welcome the little one 👶',
      'Engagement': 'Cheers to your new journey together! 💍',
      'Open Mic Performance': 'Show us your talent! 🎤',
      'Live Music Attendance': 'Enjoy great music in cozy ambiance 🎵',
      'Band Booking': 'Perfect setup for your band performance 🎸',
      'Coffee Workshop': 'Learn the art of coffee brewing ☕',
      'Community Meeting': 'Perfect space for productive discussions 🤝',
      'Art Class': 'Unleash your creativity in inspiring surroundings 🎨',
      'Book Club': 'Cozy atmosphere for literary discussions 📚',
      'Team Meeting': 'Professional environment for your team 💼',
      'Client Presentation': 'Impress your clients with our setup 📊',
      'Team Building': 'Fun activities for team bonding 🎯',
      'Corporate Training': 'Enhanced learning experience 🏢',
    };
    
    return notes[eventType] ?? 'Looking forward to hosting your event!';
  }

  // Priority for admin sorting
  String _getBookingPriority(String eventType) {
    if (['Corporate Training', 'Client Presentation', 'Team Meeting'].contains(eventType)) {
      return 'high';
    } else if (['Birthday Party', 'Anniversary', 'Engagement'].contains(eventType)) {
      return 'medium';
    }
    return 'normal';
  }

  Stream<List<EventBooking>> getUserBookings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventBooking.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> cancelBooking(String userId, String bookingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .doc(bookingId)
        .update({
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
          'cancelledAt': FieldValue.serverTimestamp(),
        });

    // Also update in admin collection
    await _firestore
        .collection('admin')
        .doc('bookings')
        .collection('allBookings')
        .doc(bookingId)
        .update({
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}