// import 'dart:developer';
// voucher_provider.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_exult_app/Features/Profile/data/voucher_model.dart';

// Provider for voucher controller
final voucherControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

// Provider for applied voucher ID
final appliedVoucherIdProvider = StateProvider<String?>((ref) => null);

// Provider for voucher discount percentage
final voucherDiscountProvider = StateProvider<double>((ref) => 0.0);

// Provider for loading state
final isCheckingVoucherProvider = StateProvider<bool>((ref) => false);

// Provider for error messages
final voucherErrorProvider = StateProvider<String?>((ref) => null);

// Provider for selected voucher
final selectedVoucherProvider = StateProvider<VoucherProduct?>((ref) => null);

// Provider to fetch all vouchers
final voucherCategoriesProvider = FutureProvider<List<VoucherProduct>>((ref) async {
  final categories = await getVoucherCategories();
  
  return categories.map((product) {
    return product.copyWith(
      voucherId: product.voucherId ?? _generateRandomVoucherId(),
    );
  }).toList();
});

// Provider to validate voucher by ID
final voucherValidationProvider = FutureProvider.family<double?, String>((ref, voucherId) async {
  return await validateVoucherAndGetDiscount(voucherId);
});

// Provider to check voucher validity
final voucherValidityProvider = FutureProvider.family<bool, String>((ref, voucherId) async {
  return await checkVoucherValidity(voucherId);
});

// Provider to get voucher by ID
final voucherByIdProvider = FutureProvider.family<VoucherProduct?, String>((ref, voucherId) async {
  return await getVoucherById(voucherId);
});

// Generate random voucher ID
String _generateRandomVoucherId() {
  final random = Random();
  return 'VOUCH${random.nextInt(900000) + 100000}';
}

// Fetch all vouchers
Future<List<VoucherProduct>> getVoucherCategories() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    final QuerySnapshot categorySnapshot = await firestore
        .collection('items')
        .doc('voucher')
        .collection('categories')
        .get();

    return categorySnapshot.docs.map((productDoc) {
      final data = productDoc.data() as Map<String, dynamic>;
      data['id'] = productDoc.id;
      return VoucherProduct.fromMap(data);
    }).toList();
  } catch (e) {
    throw Exception('Error fetching voucher categories: $e');
  }
}

// Get voucher by ID
Future<VoucherProduct?> getVoucherById(String voucherId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    final QuerySnapshot snapshot = await firestore
        .collection('items')
        .doc('voucher')
        .collection('categories')
        .where('voucherId', isEqualTo: voucherId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return VoucherProduct.fromMap(data);
    }
    return null;
  } catch (e) {
    throw Exception('Error fetching voucher: $e');
  }
}

// Validate voucher and return discount
Future<double?> validateVoucherAndGetDiscount(String voucherId) async {
  final voucher = await getVoucherById(voucherId);
  if (voucher == null || !voucher.isValid) {
    return null;
  }
  return voucher.offerPercentage;
}

// Check voucher validity
Future<bool> checkVoucherValidity(String voucherId) async {
  final voucher = await getVoucherById(voucherId);
  return voucher != null && voucher.isValid;
}

// Apply voucher function (use this in payment screen)
Future<bool> applyVoucher(WidgetRef ref, String voucherId) async {
  ref.read(isCheckingVoucherProvider.notifier).state = true;
  ref.read(voucherErrorProvider.notifier).state = null;

  try {
    final discount = await validateVoucherAndGetDiscount(voucherId);
    
    if (discount != null && discount > 0) {
      final voucher = await getVoucherById(voucherId);
      log('✅ Voucher found: ${voucher?.toMap()}' as num);

      ref.read(appliedVoucherIdProvider.notifier).state = voucherId;
      ref.read(voucherDiscountProvider.notifier).state = discount;
      ref.read(selectedVoucherProvider.notifier).state = voucher;
      ref.read(voucherErrorProvider.notifier).state = null;
      debugPrint('💡 Discount returned: $discount');
      return true;
    } else {
      ref.read(voucherErrorProvider.notifier).state = 'Invalid or expired voucher';
      ref.read(appliedVoucherIdProvider.notifier).state = null;
      ref.read(voucherDiscountProvider.notifier).state = 0.0;
      ref.read(selectedVoucherProvider.notifier).state = null;
      return false;
    }
  } catch (e) {
    ref.read(voucherErrorProvider.notifier).state = 'Error applying voucher: $e';
    return false;
  } finally {
    ref.read(isCheckingVoucherProvider.notifier).state = false;
  }
}

// Remove voucher function
void removeVoucher(WidgetRef ref) {
  ref.read(appliedVoucherIdProvider.notifier).state = null;
  ref.read(voucherDiscountProvider.notifier).state = 0.0;
  ref.read(selectedVoucherProvider.notifier).state = null;
  ref.read(voucherControllerProvider).clear();
  ref.read(voucherErrorProvider.notifier).state = null;
}