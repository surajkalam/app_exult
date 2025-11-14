import 'dart:developer';

import 'package:coffee_exult_app/Services/firebase_cart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartServiceProvider = Provider<FirebaseCartService>((ref) {
  return FirebaseCartService();
});

final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<Map<String, dynamic>>>>(
      (ref) {
        final cartService = ref.watch(cartServiceProvider);
        return CartNotifier(cartService);
      },
    );

class CartNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final FirebaseCartService _cartService;

  CartNotifier(this._cartService) : super(const AsyncValue.loading()) {
    _loadCartItems();
  }

  // Future<void> _loadCartItems() async {
  //   try {
  //     final items = await _cartService.getCartItems();
  //     state = AsyncValue.data(items);
  //   } catch (e, stack) {
  //     state = AsyncValue.error(e, stack);
  //   }
  // }
  Future<void> _loadCartItems() async {
    try {
      state = const AsyncValue.loading();

      final items = await _cartService.getCartItems();

      // Log the sanitized data for debugging
      for (var item in items) {
        log(
          '✅ Sanitized Item: ${item['name']} - Price: ${item['price']} (${item['price'].runtimeType}) - Quantity: ${item['quantity']} (${item['quantity'].runtimeType})',
        );
      }

      state = AsyncValue.data(items);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      // First update the local state for immediate UI feedback
      state.maybeWhen(
        data: (items) {
          final updatedItems = items.map((item) {
            if (item['id'] == itemId || item['name'] == itemId) {
              final updatedItem = Map<String, dynamic>.from(item);
              updatedItem['quantity'] = newQuantity;
              return updatedItem;
            }
            return item;
          }).where((item) => (item['quantity'] as int) > 0).toList();

          state = AsyncValue.data(updatedItems);
        },
        orElse: () {},
      );

      // Then update Firebase in the background
      if (newQuantity > 0) {
        await _cartService.updateQuantity(itemId, newQuantity);
      } else {
        await _cartService.removeItem(itemId);
      }

      // No reload needed - local state is already updated and Firebase is synced
    } catch (e, stack) {
      // If Firebase update fails, reload to revert local changes
      await _loadCartItems();
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await _cartService.removeItem(itemId);
      await _loadCartItems();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> checkout() async {
    try {
      await _cartService.clearCart();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeAllItems() async {
    try {
      final currentState = state;
      if (currentState is AsyncData && currentState.value!.isEmpty) {
        return;
      }

      state = const AsyncValue.loading();
      await _cartService.clearCart();
      state = const AsyncValue.data([]);
    } catch (e) {
      try {
        await _loadCartItems();
      } catch (_) {
        state = const AsyncValue.data([]);
      }
    }
  }
}
