// Provider to fetch items by type without modifying other providers
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/Features/Home/models/items_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemsByTypeProvider = FutureProvider.family<List<Item>, String>((ref, itemType) async {
  final firestore = FirebaseFirestore.instance;
  final mainDocId = '1757264051191711';
  final List<Item> filteredItems = [];
  
  log('🔄 Fetching items by type: $itemType');
  
  try {
    // Define all categories to search in
    final categories = [
      'Coffee', 'Tea', 'Cooler', 'Snacks', 'Frozen',
      'Crispy Delicious', 'Breadcraft', 'House Specials',
      'Continental', 'DessertDuo'
    ];
    
    // Fetch from each category
    for (final category in categories) {
      try {
        log('📂 Fetching from: items/$mainDocId/$category');
        
        final querySnapshot = await firestore
            .collection('items')
            .doc(mainDocId)
            .collection(category)
            .where('itemType', isEqualTo: itemType) // Filter by itemType
            .get();

        log('✅ Found ${querySnapshot.docs.length} items of type $itemType in $category');
        
        for (var doc in querySnapshot.docs) {
          try {
            final itemData = doc.data();
            final item = Item.fromMap(itemData, doc.id);
            final itemWithCategory = item.copyWith(category: category);
            filteredItems.add(itemWithCategory);
            log('🎯 Loaded item: ${item.name} (${item.itemType}) from $category');
          } catch (e) {
            log('❌ Error parsing item ${doc.id} in $category: $e');
          }
        }
      } catch (e) {
        log('⚠️ Error accessing category $category: $e');
        continue;
      }
    }

    log('🎉 Successfully fetched ${filteredItems.length} items of type $itemType');
    return filteredItems;
  } catch (e) {
    log('💥 Error fetching items by type $itemType: $e');
    throw Exception('Failed to fetch items: $e');
  }
});

// Specific providers for each item type
final newArrivalsProvider = FutureProvider<List<Item>>((ref) {
  return ref.read(itemsByTypeProvider('new_arrivals').future);
});

final seasonalItemsProvider = FutureProvider<List<Item>>((ref) {
  return ref.read(itemsByTypeProvider('seasonal').future);
});

final normalItemsProvider = FutureProvider<List<Item>>((ref) {
  return ref.read(itemsByTypeProvider('normal').future);
});