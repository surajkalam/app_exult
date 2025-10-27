// providers/admin_providers.dart
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/Home/models/items_model.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/booking/booking_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminTab {
  items,
  offers,
  vouchers,
  analytics
}

// Admin Tab Provider
final adminTabProvider = StateProvider<AdminTab>((ref) => AdminTab.items);
final adminStateProvider = StateProvider<int>((ref) => 0);

// Items Provider for CRUD operations - FIXED for your structure
final itemsProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  return ItemsNotifier();
});

class ItemsState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ItemsNotifier extends StateNotifier<ItemsState> {
  ItemsNotifier() : super(ItemsState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Your main document ID where categories are stored
  final String _mainDocId = '1757264051191711';

  // Define all possible categories
  final List<String> _allCategories = [
    'Coffee',
    'Tea',
    'Cooler',
    'Snacks',
    'Frozen',
    'Crispy Delicious',
    'Breadcraft',
    'House Specials',
    'Continental',
    'Dessertduo'
  ];

  // To get only new arrivals
  List<Item> get newArrivals =>
      state.items.where((item) => item.itemType == 'new_arrivals').toList();

  // To get only seasonal items
  List<Item> get seasonalItems =>
      state.items.where((item) => item.itemType == 'seasonal').toList();

  // To get normal items
  List<Item> get normalItems =>
      state.items.where((item) => item.itemType == 'normal').toList();
      
  // Fetch all items from all categories - FIXED for your structure
  Future<void> fetchAllItems() async {
    log('🔄 Starting to fetch all items from document: $_mainDocId...');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final List<Item> allItems = [];
      
      // Fetch from each category under the main document
      for (final category in _allCategories) {
        try {
          log('📂 Fetching from: items/$_mainDocId/$category');
          
          final querySnapshot = await _firestore
              .collection('items')
              .doc(_mainDocId)
              .collection(category)
              .get();

          log('✅ Found ${querySnapshot.docs.length} items in $category');
          
          for (var doc in querySnapshot.docs) {
            try {
              final itemData = doc.data();
              log('📄 Raw data for ${doc.id}: $itemData');
              
              final item = Item.fromMap(itemData, doc.id);
              // Add category information to the item
              final itemWithCategory = item.copyWith(category: category);
              allItems.add(itemWithCategory);
              log('🎯 Loaded item: ${item.name} from $category');
            } catch (e) {
              log('❌ Error parsing item ${doc.id} in $category: $e');
            }
          }
        } catch (e) {
          log('⚠️ Error accessing category $category: $e');
          continue;
        }
      }

      state = state.copyWith(items: allItems, isLoading: false);
      log('🎉 Successfully fetched ${allItems.length} items in total');
      
      // log all items for debugging
      for (var item in allItems) {
        log('📋 ${item.name} - ${item.category} - \${item.price}');
      }
    } catch (e) {
      log('💥 Error fetching all items: $e');
      state = state.copyWith(
        error: 'Failed to fetch items: $e', 
        isLoading: false
      );
    }
  }

  // Fetch items by specific category
  Future<void> fetchItemsByCategory(String category) async {
    
    log('🔄 Fetching items from category: $category');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      log('📂 Fetching from: items/$_mainDocId/$category');
      
      final querySnapshot = await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection(category)
          .get();

      final items = querySnapshot.docs
          .map((doc) {
            final item = Item.fromMap(doc.data(), doc.id);
            return item.copyWith(category: category);
          })
          .toList();

      state = state.copyWith(items: items, isLoading: false);
      log('✅ Successfully fetched ${items.length} items from $category category');
      
      // Debug log
      for (var item in items) {
        log('📋 ${item.name} - \${item.price}');
      }
    } catch (e) {
      log('💥 Error fetching items from $category: $e');
      state = state.copyWith(
        error: 'Failed to fetch items: $e', 
        isLoading: false
      );
    }
  }

  // Add new item
  Future<void> addItem(Item item, String category) async {
    log('➕ Adding new item: ${item.name} to category: $category');
    try {
      final itemData = item.toMap();
      
      await _firestore
          .collection('items')
          .doc(_mainDocId)
          // .collection(category.toLowerCase())
          .collection(category)
          .add(itemData);
      
      log('✅ Item added successfully to $category category');
      
      // Refresh the list
      await fetchAllItems();
    } catch (e) {
      log('💥 Error adding item: $e');
      throw Exception('Failed to add item: $e');
    }
  }

  // Update item
  Future<void> updateItem(Item item, String category) async {
    log('✏️ Updating item: ${item.name} (ID: ${item.id}) in category: $category');
    try {
      if (item.id == null) {
        throw Exception('Item ID is null');
      }
      
      await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection(category)
          .doc(item.id!)
          .update(item.toMap());
      
      log('✅ Item updated successfully');
      
      // Refresh the list
      await fetchAllItems();
    } catch (e) {
      log('💥 Error updating item: $e');
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId, String category) async {
    log('🗑️ Deleting item ID: $itemId from category: $category');
    try {
      await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection(category.toLowerCase())
          .doc(itemId)
          .delete();
      
      log('✅ Item deleted successfully');
      
      // Refresh the list
      await fetchAllItems();
    } catch (e) {
      log('💥 Error deleting item: $e');
      throw Exception('Failed to delete item: $e');
    }
  }

  // Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Statistics Provider - FIXED for your structure
final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final mainDocId = '1757264051191711';
  
  log('📊 Fetching statistics from document: $mainDocId...');
  
  try {
    int totalItems = 0;
    // Define categories to check
    
    final categories = [
      'Coffee', 'Tea', 'Cooler', 'Snacks', 'Frozen',
      'Crispy Delicious', 'Breadcraft', 'House Specials',
      'Continental', 'Dessertduo'
    ];
    
    // Count items in each category
    for (final category in categories) {
      try {
        log('🔍 Counting items in: items/$mainDocId/$category');
        
        final query = firestore
            .collection('items')
            .doc(mainDocId)
            .collection(category);
        
        final snapshot = await query.get();
        totalItems += snapshot.docs.length;
        log('📈 Category $category: ${snapshot.docs.length} items');
        
        // log document IDs for debugging
        if (snapshot.docs.isNotEmpty) {
          log('   Document IDs: ${snapshot.docs.map((doc) => doc.id).toList()}');
        }
      } catch (e) {
        log('⚠️ Could not count category $category: $e');
      }
    }
    
    // Also check other documents (Newarrivals, Sessional, voucher)
    final otherDocs = ['Newarrivals', 'Sessional', 'voucher'];
    int newArrivalsCount = 0;
    int seasonalItemsCount = 0;
    int vouchersCount = 0;
    
    for (final docId in otherDocs) {
      try {
        log('🔍 Checking document: items/$docId');
        final doc = await firestore.collection('items').doc(docId).get();
        if (doc.exists) {
          // If these documents have subcollections, you might need to count them too
          log('📄 Document $docId exists');
        }
      } catch (e) {
        log('⚠️ Could not access document $docId: $e');
      }
    }
    
    final stats = {
      'totalItems': totalItems,
      'activeOffers': 0, // You can implement this later
      'vouchers': vouchersCount,
      'newArrivals': newArrivalsCount,
      'seasonalItems': seasonalItemsCount,
    };
    
    log('📊 Final Statistics: $stats');
    return stats;
  } catch (e) {
    log('💥 Error fetching stats: $e');
    return {
      'totalItems': 0,
      'activeOffers': 0,
      'vouchers': 0,
      'newArrivals': 0,
      'seasonalItems': 0,
    };
  }
});

// Debug function to check Firebase structure
final firebaseStructureProvider = FutureProvider<void>((ref) async {
  final firestore = FirebaseFirestore.instance;
  log('🏗️ Checking Firebase structure...');
  
  try {
    // Check what documents exist in 'items' collection
    final itemsSnapshot = await firestore.collection('items').get();
    log('📁 Documents in "items" collection:');
    
    for (final doc in itemsSnapshot.docs) {
      log('   📄 ${doc.id}');
      
      // Try to list subcollections for each document
      try {
        // For web version, we can try to get one collection to see if it exists
        final testCollection = await firestore
            .collection('items')
            .doc(doc.id)
            .collection('coffee')
            .limit(1)
            .get();
            
        log('      ☕ coffee collection exists: ${testCollection.docs.length} items');
      } catch (e) {
        log('      ❌ No coffee collection or error: $e');
      }
    }
  } catch (e) {
    log('💥 Error checking Firebase structure: $e');
  }
});

// Image Upload Provider (same as before)
final imageUploadProvider = StateNotifierProvider<ImageUploadNotifier, ImageUploadState>((ref) {
  return ImageUploadNotifier();
});

class ImageUploadState {
  final bool isUploading;
  final String? imageUrl;
  final String? error;

  ImageUploadState({
    this.isUploading = false,
    this.imageUrl,
    this.error,
  });

  ImageUploadState copyWith({
    bool? isUploading,
    String? imageUrl,
    String? error,
  }) {
    return ImageUploadState(
      isUploading: isUploading ?? this.isUploading,
      imageUrl: imageUrl ?? this.imageUrl,
      error: error ?? this.error,
    );
  }
}

// services/admin_firestore_service.dart - Update the updateBookingStatus method
Future<void> updateBookingStatus({
  required String bookingId,
  required String status,
  required String adminResponse,
  required String userId,
}) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Update in admin collection
  final adminRef = firestore
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

  // Update in user's collection - include adminResponse
  final userRef = firestore
      .collection('users')
      .doc(userId)
      .collection('bookings')
      .doc(bookingId);
  
  batch.update(userRef, {
    'status': status,
    'adminResponse': adminResponse, // Make sure this is included
    'updatedAt': FieldValue.serverTimestamp(),
  });

  await batch.commit();
}
final adminBookingsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);
  
  return adminService.getAllBookings().map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});
final bookingStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final adminService = ref.watch(adminFirestoreServiceProvider);
  
  return adminService.getAllBookings().map((snapshot) {
    final docs = snapshot.docs;
    final total = docs.length;
    final pending = docs.where((doc) => doc['status'] == 'pending').length;
    final approved = docs.where((doc) => doc['status'] == 'approved').length;
    final rejected = docs.where((doc) => doc['status'] == 'rejected').length;

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  });
});

class ImageUploadNotifier extends StateNotifier<ImageUploadState> {
  ImageUploadNotifier() : super(ImageUploadState());

  Future<void> uploadImage(File image) async {
    log('🖼️ Starting image upload...');
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = 'items/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child(fileName);

      log('📤 Uploading image to: $fileName');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      state = state.copyWith(
        isUploading: false,
        imageUrl: downloadUrl,
      );
      log('✅ Image uploaded successfully: $downloadUrl');
    } catch (e) {
      log('💥 Error uploading image: $e');
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to upload image: $e',
      );
    }
  }

  void clearImage() {
    log('🗑️ Clearing uploaded image');
    state = ImageUploadState();
  }
}

// Debug Provider
final debugProvider = Provider<void>((ref) {
  final itemsState = ref.watch(itemsProvider);
  log('🐛 DEBUG - Items State:');
  log('   📦 Items Count: ${itemsState.items.length}');
  log('   ⏳ Loading: ${itemsState.isLoading}');
  log('   ❌ Error: ${itemsState.error}');
});

// Category list provider for UI
final categoriesProvider = Provider<List<String>>((ref) {
  return [
    'All',
    'Coffee',
    'Tea',
    'Cooler',
    'Snacks',
    'Frozen',
    'Crispy Delicious',
    'Breadcraft',
    'House Specials',
    'Continental',
    'DessertDuo'
  ];
});