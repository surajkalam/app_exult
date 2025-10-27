// provider/user_details_provider.dart
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String name;
  final String email;
  final String phone;

  UserDetails({
    required this.name,
    required this.email,
    required this.phone,
  });
}

final userDetailsProvider = FutureProvider<UserDetails>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    throw Exception('User not logged in');
  }

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      return UserDetails(
        name: data['name'] ?? 'User',
        email: data['email'] ?? currentUser.email ?? 'No email',
        phone: data['phone'] ?? 'No phone',
      );
    } else {
      // Return default values if user document doesn't exist
      return UserDetails(
        name: 'User',
        email: currentUser.email ?? 'No email',
        phone: 'No phone',
      );
    }
  } catch (e) {
    throw Exception('Failed to load user details: $e');
  }
});