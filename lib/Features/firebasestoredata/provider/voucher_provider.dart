// providers/voucher_providers.dart
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Voucher {
  final String? id;
  final String category;
  final String imageUrl;
  final double offerPercentage;
  final DateTime validUntil;
  final DateTime createdAt;

  Voucher({
    this.id,
    required this.category,
    required this.imageUrl,
    required this.offerPercentage,
    required this.validUntil,
    required this.createdAt,
  });

  factory Voucher.fromMap(Map<String, dynamic> map, String id) {
    return Voucher(
      id: id,
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      offerPercentage: (map['offerPercentage'] ?? 0.0).toDouble(),
      validUntil: (map['validUntil'] as Timestamp).toDate(),
      createdAt: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'imageUrl': imageUrl,
      'offerPercentage': offerPercentage,
      'validUntil': Timestamp.fromDate(validUntil),
      'timestamp': Timestamp.fromDate(createdAt),
    };
  }

  Voucher copyWith({
    String? id,
    String? category,
    String? imageUrl,
    double? offerPercentage,
    DateTime? validUntil,
    DateTime? createdAt,
  }) {
    return Voucher(
      id: id ?? this.id,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      offerPercentage: offerPercentage ?? this.offerPercentage,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isExpired => validUntil.isBefore(DateTime.now());
  bool get isValid => !isExpired;
}

class VoucherState {
  final List<Voucher> vouchers;
  final bool isLoading;
  final String? error;

  VoucherState({
    this.vouchers = const [],
    this.isLoading = false,
    this.error,
  });

  VoucherState copyWith({
    List<Voucher>? vouchers,
    bool? isLoading,
    String? error,
  }) {
    return VoucherState(
      vouchers: vouchers ?? this.vouchers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Voucher Provider for CRUD operations
final voucherProvider = StateNotifierProvider<VoucherNotifier, VoucherState>((ref) {
  return VoucherNotifier();
});

class VoucherNotifier extends StateNotifier<VoucherState> {
  VoucherNotifier() : super(VoucherState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _mainDocId = 'voucher';

  // Fetch all vouchers
  Future<void> fetchAllVouchers() async {
    log('🔄 Fetching all vouchers...');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final querySnapshot = await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection('categories')
          .orderBy('timestamp', descending: true)
          .get();

      final vouchers = querySnapshot.docs
          .map((doc) => Voucher.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(vouchers: vouchers, isLoading: false);
      log('✅ Successfully fetched ${vouchers.length} vouchers');
      
      // Debug log
      for (var voucher in vouchers) {
        log('📋 ${voucher.category} - ${voucher.offerPercentage}% - Valid until: ${voucher.validUntil}');
      }
    } catch (e) {
      log('💥 Error fetching vouchers: $e');
      state = state.copyWith(
        error: 'Failed to fetch vouchers: $e', 
        isLoading: false
      );
    }
  }

  // Add new voucher
  Future<void> addVoucher(Voucher voucher) async {
    log('➕ Adding new voucher for ${voucher.category}');
    try {
      await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection('categories')
          .add(voucher.toMap());
      
      log('✅ Voucher added successfully');
      
      // Refresh the list
      await fetchAllVouchers();
    } catch (e) {
      log('💥 Error adding voucher: $e');
      throw Exception('Failed to add voucher: $e');
    }
  }

  // Update voucher
  Future<void> updateVoucher(Voucher voucher) async {
    log('✏️ Updating voucher: ${voucher.id}');
    try {
      if (voucher.id == null) {
        throw Exception('Voucher ID is null');
      }
      
      await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection('categories')
          .doc(voucher.id!)
          .update(voucher.toMap());
      
      log('✅ Voucher updated successfully');
      
      // Refresh the list
      await fetchAllVouchers();
    } catch (e) {
      log('💥 Error updating voucher: $e');
      throw Exception('Failed to update voucher: $e');
    }
  }

  // Delete voucher
  Future<void> deleteVoucher(String voucherId) async {
    log('🗑️ Deleting voucher ID: $voucherId');
    try {
      await _firestore
          .collection('items')
          .doc(_mainDocId)
          .collection('categories')
          .doc(voucherId)
          .delete();
      
      log('✅ Voucher deleted successfully');
      
      // Refresh the list
      await fetchAllVouchers();
    } catch (e) {
      log('💥 Error deleting voucher: $e');
      throw Exception('Failed to delete voucher: $e');
    }
  }

  // Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Voucher Statistics Provider
final voucherStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  log('📊 Fetching voucher statistics...');
  
  try {
    final querySnapshot = await firestore
        .collection('items')
        .doc('voucher')
        .collection('categories')
        .get();

    final vouchers = querySnapshot.docs
        .map((doc) => Voucher.fromMap(doc.data(), doc.id))
        .toList();

    final totalVouchers = vouchers.length;
    final activeVouchers = vouchers.where((v) => v.isValid).length;
    final expiredVouchers = vouchers.where((v) => v.isExpired).length;
    
    // Calculate average discount
    final averageDiscount = vouchers.isNotEmpty 
        ? vouchers.map((v) => v.offerPercentage).reduce((a, b) => a + b) / vouchers.length
        : 0.0;

    final stats = {
      'totalVouchers': totalVouchers,
      'activeVouchers': activeVouchers,
      'expiredVouchers': expiredVouchers,
      'averageDiscount': averageDiscount,
    };
    
    log('📊 Voucher Statistics: $stats');
    return stats;
  } catch (e) {
    log('💥 Error fetching voucher stats: $e');
    return {
      'totalVouchers': 0,
      'activeVouchers': 0,
      'expiredVouchers': 0,
      'averageDiscount': 0.0,
    };
  }
});

// Image Upload Provider for Vouchers
final voucherImageUploadProvider = StateNotifierProvider<VoucherImageUploadNotifier, VoucherImageUploadState>((ref) {
  return VoucherImageUploadNotifier();
});

class VoucherImageUploadState {
  final bool isUploading;
  final String? imageUrl;
  final String? error;

  VoucherImageUploadState({
    this.isUploading = false,
    this.imageUrl,
    this.error,
  });

  VoucherImageUploadState copyWith({
    bool? isUploading,
    String? imageUrl,
    String? error,
  }) {
    return VoucherImageUploadState(
      isUploading: isUploading ?? this.isUploading,
      imageUrl: imageUrl ?? this.imageUrl,
      error: error ?? this.error,
    );
  }
}

class VoucherImageUploadNotifier extends StateNotifier<VoucherImageUploadState> {
  VoucherImageUploadNotifier() : super(VoucherImageUploadState());

  Future<void> uploadVoucherImage(File image) async {
    log('🖼️ Starting voucher image upload...');
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = 'vouchers/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child(fileName);

      log('📤 Uploading voucher image to: $fileName');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      state = state.copyWith(
        isUploading: false,
        imageUrl: downloadUrl,
      );
      log('✅ Voucher image uploaded successfully: $downloadUrl');
    } catch (e) {
      log('💥 Error uploading voucher image: $e');
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to upload image: $e',
      );
    }
  }

  void clearImage() {
    log('🗑️ Clearing uploaded voucher image');
    state = VoucherImageUploadState();
  }
}

// Debug Provider for Vouchers
final voucherDebugProvider = Provider<void>((ref) {
  final voucherState = ref.watch(voucherProvider);
  log('🐛 VOUCHER DEBUG - State:');
  log('   📦 Vouchers Count: ${voucherState.vouchers.length}');
  log('   ⏳ Loading: ${voucherState.isLoading}');
  log('   ❌ Error: ${voucherState.error}');
  
  if (voucherState.vouchers.isNotEmpty) {
    log('   📋 Vouchers:');
    for (var voucher in voucherState.vouchers.take(3)) {
      log('      - ${voucher.category} - ${voucher.offerPercentage}% - Valid: ${voucher.validUntil}');
    }
  }
});

// Categories list for vouchers
final voucherCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'Coffee',
    'Tea',
    'Cooler',
    'Snacks',
    'Frozen',
    'Crispy Delicious',
    'Breadcraft',
    'House specials',
    'Continental',
    'DessertDuo',
  ];
});