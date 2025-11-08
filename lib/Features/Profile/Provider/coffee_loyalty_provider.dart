import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Authentication/provider/current_user.dart';

// Coffee loyalty state
class CoffeeLoyaltyState {
  final int filledLayers;
  final int totalOrders;
  final bool hasFreeCoffee;

  CoffeeLoyaltyState({
    required this.filledLayers,
    required this.totalOrders,
    required this.hasFreeCoffee,
  });

  CoffeeLoyaltyState copyWith({
    int? filledLayers,
    int? totalOrders,
    bool? hasFreeCoffee,
  }) {
    return CoffeeLoyaltyState(
      filledLayers: filledLayers ?? this.filledLayers,
      totalOrders: totalOrders ?? this.totalOrders,
      hasFreeCoffee: hasFreeCoffee ?? this.hasFreeCoffee,
    );
  }
}

// Coffee loyalty notifier
class CoffeeLoyaltyNotifier extends StateNotifier<CoffeeLoyaltyState> {
  CoffeeLoyaltyNotifier() : super(CoffeeLoyaltyState(
    filledLayers: 0,
    totalOrders: 0,
    hasFreeCoffee: false,
  ));

  // Load loyalty data from Firebase
  Future<void> loadLoyaltyData(String? phoneNumber) async {
    if (phoneNumber == null) return;

    try {
      log('🔍 Loading loyalty data for user: $phoneNumber');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .collection('loyalty')
          .doc('coffee')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final totalOrders = data['totalOrders'] ?? 0;
        final filledLayers = (totalOrders % 3);
        final hasFreeCoffee = filledLayers == 0 && totalOrders > 0;

        log('📊 Loyalty data loaded: totalOrders=$totalOrders, filledLayers=$filledLayers, hasFreeCoffee=$hasFreeCoffee');

        state = CoffeeLoyaltyState(
          filledLayers: filledLayers == 0 && totalOrders > 0 ? 3 : filledLayers,
          totalOrders: totalOrders,
          hasFreeCoffee: hasFreeCoffee,
        );
      } else {
        log('📭 No loyalty data found for user: $phoneNumber');
      }
    } catch (e) {
      log('❌ Error loading loyalty data: $e');
    }
  }

  // Add order and update layers
  Future<void> addOrder(String? phoneNumber) async {
    if (phoneNumber == null) return;

    try {
      // First, load current data from Firebase to ensure we have the latest count
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .collection('loyalty')
          .doc('coffee')
          .get();

      int currentTotalOrders = 0;
      if (doc.exists) {
        currentTotalOrders = doc.data()?['totalOrders'] ?? 0;
      }

      final newTotalOrders = currentTotalOrders + 1;
      final newFilledLayers = newTotalOrders % 3;
      final hasFreeCoffee = newFilledLayers == 0;

      log('☕ Coffee Loyalty Update:');
      log('   Previous orders: $currentTotalOrders');
      log('   New total orders: $newTotalOrders');
      log('   Filled layers: ${hasFreeCoffee ? 3 : newFilledLayers}/3');
      log('   Has free coffee: $hasFreeCoffee');

      // Update Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .collection('loyalty')
          .doc('coffee')
          .set({
        'totalOrders': newTotalOrders,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update state
      state = CoffeeLoyaltyState(
        filledLayers: hasFreeCoffee ? 3 : newFilledLayers,
        totalOrders: newTotalOrders,
        hasFreeCoffee: hasFreeCoffee,
      );

      log('✅ Coffee loyalty state updated successfully');
    } catch (e) {
      log('❌ Error updating coffee loyalty: $e');
    }
  }

  // Claim free coffee
  Future<void> claimFreeCoffee(String? phoneNumber) async {
    if (phoneNumber == null || !state.hasFreeCoffee) return;

    try {
      log('🎉 Claiming free coffee for user: $phoneNumber');

      // Reset the cycle in Firebase - set totalOrders back to 0
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .collection('loyalty')
          .doc('coffee')
          .set({
        'totalOrders': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Log the free coffee claim
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .collection('freeCoffees')
          .add({
        'claimedAt': FieldValue.serverTimestamp(),
        'totalOrdersWhenClaimed': state.totalOrders,
      });

      // Reset the local state
      state = CoffeeLoyaltyState(
        filledLayers: 0,
        totalOrders: 0,
        hasFreeCoffee: false,
      );

      log('✅ Free coffee claimed and loyalty reset to 0');
    } catch (e) {
      log('❌ Error claiming free coffee: $e');
    }
  }
}

// Provider
final coffeeLoyaltyProvider = StateNotifierProvider<CoffeeLoyaltyNotifier, CoffeeLoyaltyState>((ref) {
  return CoffeeLoyaltyNotifier();
});

// Auto-load loyalty data when user changes
final loyaltyDataLoader = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  final notifier = ref.read(coffeeLoyaltyProvider.notifier);
  
  if (user?.phoneNumber != null) {
    await notifier.loadLoyaltyData(user!.phoneNumber);
  }
});