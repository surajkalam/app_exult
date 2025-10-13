import 'package:coffee_exult_app/DATABASE_HELPER/cart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  CartNotifier() : super(const AsyncValue.loading()) {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final items = await DatabaseHelper.instance.getCartItems();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateQuantity(int id, int newQuantity) async {
    try {
      if (newQuantity > 0) {
        await DatabaseHelper.instance.updateCartItemQuantity(id, newQuantity);
      } else {
        await DatabaseHelper.instance.removeCartItem(id);
      }
      await _loadCartItems();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeItem(int id) async {
    try {
      await DatabaseHelper.instance.removeCartItem(id);
      await _loadCartItems();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> checkout() async {
    try {
      // Add your checkout logic here
      await DatabaseHelper.instance.close();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeAllItems() async {
    try {
      // Check if cart is already empty
      final currentState = state;
      if (currentState is AsyncData && currentState.value!.isEmpty) {
        return; // Cart is already empty, no action needed
      }
      
      state = const AsyncValue.loading();
      await DatabaseHelper.instance.clearCart();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      // If error occurs, try to reload current state
      try {
        await _loadCartItems();
      } catch (_) {
        state = const AsyncValue.data([]); // Fallback to empty cart
      }
    }
  }
}
