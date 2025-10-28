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

        state = CoffeeLoyaltyState(
          filledLayers: filledLayers == 0 && totalOrders > 0 ? 3 : filledLayers,
          totalOrders: totalOrders,
          hasFreeCoffee: hasFreeCoffee,
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  // Add order and update layers
  Future<void> addOrder(String? phoneNumber) async {
    if (phoneNumber == null) return;

    try {
      final newTotalOrders = state.totalOrders + 1;
      final newFilledLayers = newTotalOrders % 3;
      final hasFreeCoffee = newFilledLayers == 0;

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
    } catch (e) {
      // Handle error
    }
  }

  // Claim free coffee
  Future<void> claimFreeCoffee(String? phoneNumber) async {
    if (phoneNumber == null || !state.hasFreeCoffee) return;

    try {
      // Reset the cycle
      state = state.copyWith(
        filledLayers: 0,
        hasFreeCoffee: false,
      );

      // Log the free coffee claim
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .collection('freeCoffees')
          .add({
        'claimedAt': FieldValue.serverTimestamp(),
        'totalOrdersWhenClaimed': state.totalOrders,
      });
    } catch (e) {
      // Handle error
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