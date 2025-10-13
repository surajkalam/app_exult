
// // import 'package:coffee_shop/DATABASE_HELPER/sracth_data.dart';
// // import 'package:coffee_shop/Features/Profile/data/scratch_model.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // final scratchCardDatabaseProvider = Provider<ScratchCardDatabase>((ref) {
// //   return ScratchCardDatabase();
// // });

// // final scratchCardsProvider = StateNotifierProvider<ScratchCardsNotifier, List<ScratchCardModel>>((ref) {
// //   return ScratchCardsNotifier(ref.read(scratchCardDatabaseProvider));
// // });

// // class ScratchCardsNotifier extends StateNotifier<List<ScratchCardModel>> {
// //   final ScratchCardDatabase _database;

// //   ScratchCardsNotifier(this._database) : super([]) {
// //     loadScratchCards();
// //   }

// //   Future<void> loadScratchCards() async {
// //     try {
// //       final cards = await _database.getAllScratchCards();
// //       state = cards;
// //     } catch (e) {
// //       // Handle error or set empty state
// //       state = [];
// //       rethrow;
// //     }
// //   }

// //   Future<void> addScratchCard(ScratchCardModel card) async {
// //     try {
// //       await _database.insertScratchCard(card);
// //       await loadScratchCards(); // Reload to get the updated list
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }

// //   Future<void> updateScratchCard(ScratchCardModel card) async {
// //     try {
// //       await _database.updateScratchCard(card);
// //       await loadScratchCards(); // Reload to get the updated list
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }

// //   // NEW: Mark a card as scratched
// //   Future<void> markAsScratched(int cardId) async {
// //     try {
// //       // Find the card in the current state
// //       final cardIndex = state.indexWhere((card) => card.id == cardId);
// //       if (cardIndex != -1) {
// //         final card = state[cardIndex];
// //         // Create updated card with isScratched = true
// //         final updatedCard = card.copyWith(isScratched: true);
// //         // Update in database
// //         await _database.updateScratchCard(updatedCard);
// //         // Reload the list
// //         await loadScratchCards();
// //       }
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }

// //   // NEW: Claim a reward
// //   Future<void> claimReward(int cardId) async {
// //     try {
// //       // Find the card in the current state
// //       final cardIndex = state.indexWhere((card) => card.id == cardId);
// //       if (cardIndex != -1) {
// //         final card = state[cardIndex];
// //         // Create updated card with isClaimed = true
// //         final updatedCard = card.copyWith(isClaimed: true);
// //         // Update in database
// //         await _database.updateScratchCard(updatedCard);
// //         // Reload the list
// //         await loadScratchCards();
// //       }
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }

// //   ScratchCardModel? getLatestCard() {
// //     return state.isNotEmpty ? state.last : null;
// //   }

// //   // Remove the hardcoded list from here as it's not needed
// //   // This should come from your database
// // }
// // lib/Features/Profile/Provider/scratch_provider.dart
// import 'package:coffee_shop/DATABASE_HELPER/sracth_data.dart';
// import 'package:coffee_shop/Features/Profile/data/scratch_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final scratchCardDatabaseProvider = Provider<ScratchCardDatabase>((ref) {
//   return ScratchCardDatabase();
// });

// final scratchCardsProvider = StateNotifierProvider<ScratchCardsNotifier, List<ScratchCardModel>>((ref) {
//   return ScratchCardsNotifier(ref.read(scratchCardDatabaseProvider));
// });

// final availableDiscountsProvider = Provider<List<ScratchCardModel>>((ref) {
//   final scratchCards = ref.watch(scratchCardsProvider);
//   return scratchCards.where((card) => card.isClaimed && !card.isUsed).toList();
// });

// class ScratchCardsNotifier extends StateNotifier<List<ScratchCardModel>> {
//   final ScratchCardDatabase _database;

//   ScratchCardsNotifier(this._database) : super([]) {
//     loadScratchCards();
//   }

//   Future<void> loadScratchCards() async {
//     try {
//       final cards = await _database.getAllScratchCards();
//       state = cards;
//     } catch (e) {
//       state = [];
//       rethrow;
//     }
//   }

//   Future<void> addScratchCard(ScratchCardModel card) async {
//     try {
//       await _database.insertScratchCard(card);
//       await loadScratchCards();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> updateScratchCard(ScratchCardModel card) async {
//     try {
//       await _database.updateScratchCard(card);
//       await loadScratchCards();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> markAsScratched(int cardId) async {
//     try {
//       final cardIndex = state.indexWhere((card) => card.id == cardId);
//       if (cardIndex != -1) {
//         final card = state[cardIndex];
//         final updatedCard = card.copyWith(isScratched: true);
//         await _database.updateScratchCard(updatedCard);
//         await loadScratchCards();
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> claimReward(int cardId) async {
//     try {
//       final cardIndex = state.indexWhere((card) => card.id == cardId);
//       if (cardIndex != -1) {
//         final card = state[cardIndex];
//         final updatedCard = card.copyWith(isClaimed: true);
//         await _database.updateScratchCard(updatedCard);
//         await loadScratchCards();
        
//         // Print reward details to console
//         _printRewardDetails(updatedCard);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> useDiscount(int cardId, String orderId) async {
//     try {
//       final cardIndex = state.indexWhere((card) => card.id == cardId);
//       if (cardIndex != -1) {
//         final card = state[cardIndex];
//         final updatedCard = card.copyWith(
//           isUsed: true,
//           usedInOrderId: orderId,
//           usedAt: DateTime.now(),
//         );
//         await _database.updateScratchCard(updatedCard);
//         await loadScratchCards();
        
//         // Print usage confirmation
//         _printDiscountUsage(updatedCard, orderId);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   void _printRewardDetails(ScratchCardModel card) {
//     print('''
// 🎯 SCRATCH CARD REWARD CLAIMED!
// ───────────────────────────────────────
// 📋 Card ID: ${card.id}
// 🎁 Reward: ${card.reward}
// 💰 Discount Value: ${_extractDiscountValue(card.reward)}
// 📅 Valid: Until used in an order
// 🔢 Discount Code: SCRATCH-${card.id}
// 💡 How to use:
//    - Proceed to checkout
//    - Apply discount code: SCRATCH-${card.id}
//    - The ${card.reward} will be automatically applied
//    - Card will be marked as used after successful payment
// ───────────────────────────────────────
// ''');
//   }

//   void _printDiscountUsage(ScratchCardModel card, String orderId) {
//     print('''
// ✅ SCRATCH CARD DISCOUNT APPLIED!
// ───────────────────────────────────────
// 📋 Card ID: ${card.id}
// 🎁 Reward: ${card.reward}
// 📦 Order ID: $orderId
// 💰 Discount Applied: ${_extractDiscountValue(card.reward)}
// ⏰ Applied at: ${DateTime.now()}
// ───────────────────────────────────────
// ''');
//   }

//   String _extractDiscountValue(String reward) {
//     if (reward.contains('%')) {
//       final regex = RegExp(r'(\d+)%');
//       final match = regex.firstMatch(reward);
//       return match != null ? '${match.group(1)}% discount' : reward;
//     } else if (reward.contains('\$')) {
//       final regex = RegExp(r'\$(\d+)');
//       final match = regex.firstMatch(reward);
//       return match != null ? '\$${match.group(1)} off' : reward;
//     } else if (reward.toLowerCase().contains('free')) {
//       return 'Free item';
//     }
//     return reward;
//   }

//   ScratchCardModel? getLatestCard() {
//     return state.isNotEmpty ? state.last : null;
//   }

//   ScratchCardModel? getCardById(int cardId) {
//     return state.firstWhere((card) => card.id == cardId);
//   }

//   List<ScratchCardModel> getAvailableDiscounts() {
//     return state.where((card) => card.isClaimed && !card.isUsed).toList();
//   }
// }
// import 'dart:developer';
// voucher_provider.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_shop/Features/Profile/data/voucher_model.dart';

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