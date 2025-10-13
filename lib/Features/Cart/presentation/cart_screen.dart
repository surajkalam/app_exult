// cart_screen.dart
import 'dart:developer';
import 'package:coffee_exult_app/Features/Cart/provider/cart_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/menu_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../core/core.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('Welcome cart screen');
    final cartAsync = ref.watch(cartProvider);
      final pricingResult = ref.watch(cartPricingProvider);
    log('🔄 Cart provider state: ${cartAsync.toString()}');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen for cart changes
    ref.listen(cartProvider, (_, state) {
      state.when(
        data: (items) => log('Cart items in state: $items'),
        loading: () => log('Loading cart...'),
        error: (e, _) => log('Error: $e'),
      );
    });

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'My Cart ',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartState = ref.watch(cartProvider);
              return cartState.maybeWhen(
                data: (items) => items.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.trash, color: Colors.black),
                        onPressed: () => _showClearCartDialog(
                          context,
                          ref,
                          colorScheme,
                          textTheme,
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => _buildLoadingState(colorScheme, textTheme),
        error: (error, stack) =>
            _buildErrorState(error, colorScheme, textTheme),
        data: (items) {
          log('✅ Cart data received: ${items.length} items');
          if (items.isEmpty) {
            log('📭 Cart is empty');
            return _buildEmptyState(colorScheme, textTheme);
          }


          // Calculate total price
          double total = items.fold(0, (sum, item) {
            return sum + (item['price'] * (item['quantity'] ?? 1));
          });
          log('💰 Total calculated: ₹$total');

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Cart items
                    ...items
                        .map((item) => _buildCartItem(context, ref, item))
                        .toList(),

                    const SizedBox(height: 20),

                    // Order summary
                    // _buildOrderSummary(total),
                     _buildOrderSummary(pricingResult),
                  ],
                ),
              ),

              // Checkout button
              _buildCheckoutButton(context, items, pricingResult,ref),
            ],
          );
        },
      ),
    );
  }

  // Show confirmation dialog for clearing cart
  void _showClearCartDialog(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    // Get current cart state
    final cartState = ref.read(cartProvider);

    cartState.maybeWhen(
      data: (items) {
        if (items.isEmpty) {
          // Show message that cart is already empty
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your cart is already empty'),
              backgroundColor: colorscheme.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          return;
        }

        // Show confirmation dialog for non-empty cart
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Clear Cart',
              style: texttheme.bodyLarge?.copyWith(color: colorscheme.primary),
            ),
            content: Text(
              'Are you sure you want to remove all ${items.length} items from your cart?',
              style: texttheme.bodySmall?.copyWith(
                color: colorscheme.secondary,
                fontSize: 11,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: texttheme.labelMedium?.copyWith(
                    color: colorscheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(cartProvider.notifier).removeAllItems();
                  // ignore: use_build_context_synchronously
                  context.pop();
                },
                child: Text(
                  'Clear All',
                  style: texttheme.labelMedium?.copyWith(
                    color: colorscheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () {
        // Handle loading or error states
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot clear cart at this time'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  // Build loading state
  Widget _buildLoadingState(ColorScheme colorscheme, TextTheme texttheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorscheme.secondaryFixed),
          const SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: texttheme.labelLarge?.copyWith(
              color: colorscheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // Build error state
  Widget _buildErrorState(error, ColorScheme colorscheme, TextTheme texttheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 48, color: colorscheme.secondaryFixed),
          const SizedBox(height: 16),
          Text(
            'Error loading cart items',
            style: texttheme.bodySmall?.copyWith(color: colorscheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: texttheme.bodySmall?.copyWith(
              color: colorscheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState(ColorScheme colorscheme, TextTheme texttheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('Assets/Icons/Empty Cart.json', height: 200, width: 200),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items to get started',
            style: texttheme.bodySmall?.copyWith(color: colorscheme.secondary),
          ),
        ],
      ),
    );
  }

  // Build cart item card
  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
  ) {
    final quantity = item['quantity'] ?? 1;
    final basePrice = item['price'];
    final itemPrice = item['price'] * quantity;
    final rating = item['rating'] ?? 0.0;

    return InkWell(
      onTap: () {
        if (context.mounted) {
          context.pushNamed(
            'product',
            pathParameters: {'id': item['name'].toString()},
            extra: item,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Left Side
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF2E2D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: item['image'] != null
                  ? Image.network(item['image'], fit: BoxFit.cover)
                  : const Icon(
                      Iconsax.coffee,
                      color: Color(0xFFC67C4E),
                      size: 32,
                    ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Row: Item Name and Delete Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? 'Unnamed Item',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .removeItem(item['id']),
                        icon: const Icon(
                          Iconsax.trash,
                          size: 20,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          maxWidth: 36,
                          minHeight: 36,
                          maxHeight: 36,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Second Row: Rating and Category
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['category'] ?? '',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Third Row: Price and Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${basePrice.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC67C4E),
                        ),
                      ),
                      _buildQuantityControls(ref, item, quantity),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build quantity controls (keep the same)
  Widget _buildQuantityControls(
    WidgetRef ref,
    Map<String, dynamic> item,
    int quantity,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2E2D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Decrease button
          IconButton(
            onPressed: () {
              if (quantity > 1) {
                ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item['id'], quantity - 1);
              }
            },
            icon: Icon(
              Icons.remove,
              size: 18,
              color: quantity > 1
                  ? const Color(0xFFC67C4E)
                  : const Color(0xFF9B9B9B),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              maxWidth: 36,
              minHeight: 36,
              maxHeight: 36,
            ),
          ),

          // Quantity display
          Text(
            quantity.toString(),
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          // Increase button
          IconButton(
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .updateQuantity(item['id'], quantity + 1);
            },
            icon: const Icon(Icons.add, size: 18, color: Color(0xFFC67C4E)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              maxWidth: 36,
              minHeight: 36,
              maxHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  // Build order summary
    Widget _buildOrderSummary(PricingResult pricing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              Text(
                'Order Summary',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtotal
          _buildSummaryRow('Subtotal', '₹${pricing.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),

          // Delivery Charges
          _buildSummaryRow('Delivery Charges', '₹${pricing.deliveryCharge.toStringAsFixed(2)}'),
          const SizedBox(height: 12),

          // Service Charges
          _buildSummaryRow('Service Charges', '₹${pricing.serviceCharge.toStringAsFixed(2)}'),
          const SizedBox(height: 12),

          // Taxes
          _buildSummaryRow('Taxes (10%)', '₹${pricing.tax.toStringAsFixed(2)}'),
          const SizedBox(height: 12),

          // Discount if applied
          if (pricing.voucherDiscountPercentage > 0) ...[
            _buildSummaryRow(
              'Discount (${pricing.voucherDiscountPercentage}%)', 
              '-₹${pricing.discountAmount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
            const SizedBox(height: 12),
          ],

          // Divider
          const Divider(height: 1, color: Color(0xFFEAEAEA)),
          const SizedBox(height: 12),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '₹${pricing.grandTotal.toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC67C4E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // Build summary row
  Widget _buildSummaryRow(String title, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: isDiscount ? Colors.green : const Color(0xFF9B9B9B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  // Build checkout button
  Widget _buildCheckoutButton(
    BuildContext context,
    List<Map<String, dynamic>> items,
    PricingResult pricing,
    WidgetRef ref
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 60, left: 20, right: 20, top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            _proceedToCheckout(context, items, pricing,ref);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC67C4E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'PAY NOW ₹${pricing.grandTotal.toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
  // Proceed to checkout method
  void _proceedToCheckout(
  BuildContext context,
  List<Map<String, dynamic>> items,
  PricingResult pricing,
  WidgetRef ref
) async {
  final user = ref.read(currentUserProvider);
  final appliedVoucherId = ref.read(appliedVoucherIdProvider);

  log('=== Cart Checkout Details ===');
  log('Total Items: ${items.length}');
  log('Subtotal: ₹${pricing.subtotal.toStringAsFixed(2)}');
  log('Delivery: ₹${pricing.deliveryCharge.toStringAsFixed(2)}');
  log('Service: ₹${pricing.serviceCharge.toStringAsFixed(2)}');
  log('Tax: ₹${pricing.tax.toStringAsFixed(2)}');
  
  if (pricing.voucherDiscountPercentage > 0) {
    log('Discount: ${pricing.voucherDiscountPercentage}% (-₹${pricing.discountAmount.toStringAsFixed(2)})');
  }
  
  log('Grand Total: ₹${pricing.grandTotal.toStringAsFixed(2)}');
  
  if (appliedVoucherId != null) {
    log('Applied Voucher: $appliedVoucherId');
  }

  // Check if user is logged in
  if (user == null || user.phoneNumber == null) {
    log('User not authenticated with phone number');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please login with your phone number before making a payment.',
        ),
        backgroundColor: Colors.red,
      ),
    );
    context.push('/login-screen');
    return;
  }

  final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';

  try {
    log('Initiating payment from cart...');
    
    // Calculate total quantity from all cart items
    final totalQuantity = items.fold(0, (int sum, item) => sum + ((item['quantity'] as num).toInt() ?? 1));
    
    // Use the first item's name or create a generic name for cart order
    final productName = items.isNotEmpty 
        ? items.first['name'] ?? 'Cart Items'
        : 'Cart Order';

    await ref.read(paymentProvider.notifier).initiatePayment(
      amount: pricing.grandTotal, // Use the pricing parameter (not pricingResult)
      productName: 'Cart - $productName & ${items.length - 1} more', // Descriptive name
      quantity: totalQuantity, // Total quantity of all items
      orderId: orderId,
    );

    // Optional: Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Proceeding to payment with ${items.length} items',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF36C07E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );

  } catch (e) {
    log('Checkout error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout failed: ${e.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
}
