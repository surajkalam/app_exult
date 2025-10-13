// Provider to fetch all payments for current user
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPaymentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user?.phoneNumber == null) return Stream.value([]);
  log('Current user: ${user?.uid}');
  log('User phone: ${user?.phoneNumber}');

  final userPhone = user!.phoneNumber!.replaceAll('+', '').replaceAll(' ', '_');
  late final phoneNumber = user.phoneNumber;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(phoneNumber)
      .collection('payments')
      .orderBy('completedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        log('Found ${snapshot.docs.length} payment documents');
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'id': doc.id};
        }).toList();
      });
});
// Provider for a specific payment
final specificPaymentProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, paymentId) {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.phoneNumber == null) return Stream.value({});

      final userPhone = user!.phoneNumber!
          .replaceAll('+', '')
          .replaceAll(' ', '_');

      return FirebaseFirestore.instance
          .collection('users')
          .doc(userPhone)
          .collection('payments')
          .doc(paymentId)
          .snapshots()
          .map((snapshot) => snapshot.data() ?? {});
    });
