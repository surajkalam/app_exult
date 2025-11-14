// services/firebase_menu_service.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, List<Map<String, dynamic>>>> getMenuItems() async {
    try {
      final Map<String, List<Map<String, dynamic>>> menuData = {};

      // Define your categories
      final List<String> categories = [
        'Coffee',
        'Tea',
        'Cooler',
        'Snacks',
        'Frozen',
        'Crispy Delicious',
        'Breadcraft',
        'House specials',
        'Continental',
        'DessertDuo'
      ];

      for (final category in categories) {
        final QuerySnapshot snapshot = await _firestore
            .collection('items')
            .doc('1757264051191711')
            .collection(category)
            .get();

        menuData[category] = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? '',
            'type': data['type'] ?? '',
            'rating': (data['rating'] ?? 0.0).toDouble(),
            'image': data['image'] ?? '',
            'description': data['description'] ?? '',
            'price': data['price']?.toString() ?? '0',
            'isAvailable':data['isAvailable']??'true',
          };
        }).toList();
      }

      return menuData;
    } catch (e) {
      log('Error fetching menu data: $e');
      rethrow;
    }
  }

  // Stream for real-time updates
  Stream<Map<String, List<Map<String, dynamic>>>> getMenuItemsStream() {
    return Stream.periodic(Duration(seconds: 30)).asyncMap((_) => getMenuItems());
  }
}