// // cart_screen.dart
import 'dart:developer';
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:coffee_exult_app/Features/Cart/provider/cart_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/menu_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/paymentProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

final selectedtableNumberProvider = StateProvider<int?>((ref) => null);
final orderTypeProvider = StateProvider<String>((ref) => 'Coffee Hub');
final customerNameProvider = StateProvider<String?>((ref) => null);
final voucherCodeProvider = StateProvider<String>((ref) => '');
final voucherDiscountProvider = StateProvider<double>((ref) => 0.0);
final voucherAppliedProvider = StateProvider<bool>((ref) => false);

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('Welcome cart screen');

    try {
      // Test 1: Check if the error is in provider access
      log('Test 1: Accessing cartProvider...');
      final cartAsync = ref.watch(cartProvider);
      log('✅ cartProvider accessed successfully');

      // Test 2: Check if the error is in pricing provider
      log('Test 2: Accessing cartPricingProvider...');
      final pricingResult = ref.watch(cartPricingProvider);
      log('✅ cartPricingProvider accessed successfully');

      log('🔄 Cart provider state: ${cartAsync.toString()}');

      return _buildSafeCartScreen(context, ref, cartAsync, pricingResult);
    } catch (e, stack) {
      log('❌ ERROR at specific location: $e');
      log('📋 Stack trace: $stack');
      return _buildErrorScreen(context, e.toString());
    }
  }

  Widget _buildSafeCartScreen(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Map<String, dynamic>>> cartAsync,
    dynamic pricingResult, // Use dynamic to avoid type issues
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // int? _selectedNumber;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: AppBar(
        title: Text('My Cart'),
        backgroundColor: colorScheme.surface,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartState = ref.watch(cartProvider);
              return cartState.maybeWhen(
                data: (items) => items.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.trash, color: Colors.red),
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

          // SAFE CALCULATION - This might be the problem area
          try {
            double total = items.fold(0.0, (double sum, item) {
              // Debug each item
              log(
                'Item price: ${item['price']} (type: ${item['price']?.runtimeType})',
              );
              log(
                'Item quantity: ${item['quantity']} (type: ${item['quantity']?.runtimeType})',
              );

              final price = _safeParseDouble(item['price']);
              final quantity = _safeParseInt(item['quantity'] ?? 1);
              return sum + (price * quantity);
            });
            log('💰 Total calculated: ₹$total');
          } catch (e) {
            log('❌ Error in total calculation: $e');
          }

          if (items.isEmpty) {
            return _buildEmptyState(colorScheme, textTheme);
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Cart items
                    ...items.map(
                      (item) => _buildCartItem(
                        context,
                        ref,
                        item,
                        colorScheme,
                        textTheme,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildOrderSummary(items, ref),
                    SizedBox(height: 20),
                    _buildVoucherSection(colorScheme, textTheme, ref),
                    SizedBox(height: 20),
                    _buildchooseoption(colorScheme, textTheme),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              // Checkout button
              _buildCheckoutButton(context, items, ref),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // Build cart item card
  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // SAFE TYPE CONVERSIONS
    final quantity = _safeParseInt(item['quantity'] ?? 1);
    final basePrice = _safeParseDouble(item['price']);
    // final itemPrice = basePrice * quantity;
    final rating = _safeParseDouble(item['rating'] ?? 0.0);

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
              color: Colors.black.withValues(alpha: 0.05),
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
                        onPressed: () => _showDeleteItemDialog(
                          context,
                          ref,
                          item,
                          colorScheme,
                          textTheme,
                        ),
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
                  SizedBox(height: 8),
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

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Cart Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Force rebuild
                final container = ProviderScope.containerOf(context);
                container.invalidate(cartProvider);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Add these helper methods:
  double _safeParseDouble(dynamic value) {
    log('Parsing double from: $value (type: ${value?.runtimeType})');
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value) ?? 0.0;
      log('String "$value" parsed to double: $parsed');
      return parsed;
    }
    log(
      '⚠️ Cannot parse $value (${value.runtimeType}) to double, returning 0.0',
    );
    return 0.0;
  }

  int _safeParseInt(dynamic value) {
    log('Parsing int from: $value (type: ${value?.runtimeType})');
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value) ?? 1;
      log('String "$value" parsed to int: $parsed');
      return parsed;
    }
    log('⚠️ Cannot parse $value (${value.runtimeType}) to int, returning 1');
    return 1;
  }

  Widget _buildchooseoption(ColorScheme colorscheme, TextTheme texttheme) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedNumber = ref.watch(selectedtableNumberProvider);
        final orderType = ref.watch(orderTypeProvider);
        final customerName = ref.watch(customerNameProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Type and Table Number in Single Row
            Row(
              children: [
                // Order Type Dropdown
                Expanded(
                  flex: orderType == 'Coffee Hub' ? 3 : 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: orderType,
                    dropdownColor: colorscheme.onPrimary,
                    decoration: InputDecoration(
                      labelText: 'Order Type',
                      labelStyle: texttheme.bodySmall?.copyWith(
                        color: colorscheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorscheme.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Coffee Hub',
                        child: Text(
                          'At Coffee Hub',
                          style: texttheme.bodySmall?.copyWith(
                            color: colorscheme.primaryContainer.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Parcel',
                        child: Text(
                          'Parcel (Takeaway)',
                          style: texttheme.bodySmall?.copyWith(
                            color: colorscheme.primaryContainer.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      ref.read(orderTypeProvider.notifier).state =
                          newValue ?? 'Coffee Hub';
                      // Clear table number when switching to parcel
                      if (newValue == 'Parcel') {
                        ref.read(selectedtableNumberProvider.notifier).state =
                            null;
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Table Number Dropdown (only show for Coffee Hub)
                if (orderType == 'Coffee Hub')
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedNumber,
                      dropdownColor: colorscheme.onPrimary,
                      decoration: InputDecoration(
                        labelText: 'Table Number',
                        labelStyle: texttheme.bodySmall?.copyWith(
                          color: colorscheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 11,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorscheme.primary),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: List.generate(10, (index) {
                        final number = index + 1;
                        return DropdownMenuItem<int>(
                          value: number,
                          child: Text(
                            'Table $number',
                            style: texttheme.bodySmall?.copyWith(
                              color: colorscheme.primaryContainer.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                      onChanged: (int? newValue) {
                        ref.read(selectedtableNumberProvider.notifier).state =
                            newValue;
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16),

            // Show message for Parcel
            if (orderType == 'Parcel')
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You don\'t need a table number for parcel order',
                        style: texttheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Customer Name Field (for Parcel orders)
            if (orderType == 'Parcel') ...[
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Your Name (for parcel)',
                  labelStyle: texttheme.bodySmall?.copyWith(
                    color: colorscheme.primaryContainer.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorscheme.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                onChanged: (value) {
                  ref.read(customerNameProvider.notifier).state =
                      value.isNotEmpty ? value : null;
                },
                validator: (value) {
                  if (orderType == 'Parcel' &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter your name for parcel order';
                  }
                  return null;
                },
              ),
            ],

            SizedBox(height: 16),

            // Show selected options below
            if (orderType == 'Coffee Hub' && selectedNumber != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.table_restaurant, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Table $selectedNumber selected for Coffee Hub',
                      style: texttheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            if (orderType == 'Parcel' && customerName != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Parcel order for: $customerName',
                      style: texttheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
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
                  Navigator.pop(context);
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

  // Show confirmation dialog for deleting individual item
  void _showDeleteItemDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Item',
          style: texttheme.bodyLarge?.copyWith(color: colorscheme.primary),
        ),
        content: Text(
          'Are you sure you want to remove "${item['name'] ?? 'this item'}" from your cart?',
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
              await ref
                  .read(cartProvider.notifier)
                  .removeItem(item['id'] ?? item['name']);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: texttheme.labelMedium?.copyWith(color: colorscheme.error),
            ),
          ),
        ],
      ),
    );
  }

  // Keep your existing methods but simplified:
  Widget _buildLoadingState(ColorScheme colorscheme, TextTheme texttheme) {
    return Center(child: CircularProgressIndicator());
  }

  // ignore: strict_top_level_inference
  Widget _buildErrorState(error, ColorScheme colorscheme, TextTheme texttheme) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildEmptyState(ColorScheme colorscheme, TextTheme texttheme) {
    return SizedBox(
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              // 'assets/Icons/Shopping Cart.json',
              'assets/Icons/Empty Cart.json',
              height: 200,
              width: 250,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 60),
            Text(
              'Cart is empty',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorscheme.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Browse our menu and add items to your cart',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: colorscheme.primaryContainer.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  // Build order summary
  Widget _buildOrderSummary(List<Map<String, dynamic>> items, WidgetRef ref) {
    // Calculate pricing
    double subtotal = 0;
    for (var item in items) {
      final price = _safeParseDouble(item['price']);
      final quantity = _safeParseInt(item['quantity'] ?? 1);
      subtotal += price * quantity;
    }

    const double taxRate = 0.10; // 10% tax
    final double tax = subtotal * taxRate;

    // Get voucher discount
    final voucherDiscount = ref.watch(voucherDiscountProvider);

    final double total = subtotal + tax - voucherDiscount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),

          // Taxes
          _buildSummaryRow('Taxes (10%)', '₹${tax.toStringAsFixed(2)}'),
          const SizedBox(height: 12),

          // Voucher discount (only show if applied)
          if (voucherDiscount > 0) ...[
            _buildSummaryRow('Voucher Discount', '-₹${voucherDiscount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
          ],

          // Divider
          const Divider(height: 1, color: Color(0xFFEAEAEA)),
          const SizedBox(height: 12),

          // Total you pay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total you pay',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
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

  // Build voucher section
  Widget _buildVoucherSection(ColorScheme colorScheme, TextTheme textTheme, WidgetRef ref) {
    final voucherCode = ref.watch(voucherCodeProvider);
    final voucherApplied = ref.watch(voucherAppliedProvider);
    final voucherDiscount = ref.watch(voucherDiscountProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have a Voucher?',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (!voucherApplied) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: voucherCode,
                    decoration: InputDecoration(
                      hintText: 'Enter voucher code',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF9B9B9B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(voucherCodeProvider.notifier).state = value;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: voucherCode.isNotEmpty ? () => _applyVoucher(ref, voucherCode) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC67C4E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voucher "$voucherCode" applied! Save ₹${voucherDiscount.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _removeVoucher(ref),
                    child: Text(
                      'Remove',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Apply voucher
  void _applyVoucher(WidgetRef ref, String voucherCode) {
    // Simple voucher validation - in a real app, this would check against a database
    const validVouchers = {
      'SAVE10': 10.0, // ₹10 off
      'SAVE20': 20.0, // ₹20 off
      'DISCOUNT50': 50.0, // ₹50 off
      'COFFEE15': 15.0, // ₹15 off
    };

    final discount = validVouchers[voucherCode.toUpperCase()];

    if (discount != null) {
      ref.read(voucherDiscountProvider.notifier).state = discount;
      ref.read(voucherAppliedProvider.notifier).state = true;

      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text('Voucher applied! You save ₹${discount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: const Text('Invalid voucher code'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Remove voucher
  void _removeVoucher(WidgetRef ref) {
    ref.read(voucherCodeProvider.notifier).state = '';
    ref.read(voucherDiscountProvider.notifier).state = 0.0;
    ref.read(voucherAppliedProvider.notifier).state = false;

    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: const Text('Voucher removed'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Build summary row
  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF9B9B9B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Build checkout button
  Widget _buildCheckoutButton(
    BuildContext context,
    List<Map<String, dynamic>> items,
    WidgetRef ref,
  ) {
    // Calculate total
    double subtotal = 0;
    for (var item in items) {
      final price = _safeParseDouble(item['price']);
      final quantity = _safeParseInt(item['quantity'] ?? 1);
      subtotal += price * quantity;
    }

    const double taxRate = 0.10; // 10% tax
    final double tax = subtotal * taxRate;
    final voucherDiscount = ref.watch(voucherDiscountProvider);
    final double total = subtotal + tax - voucherDiscount;

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
            _proceedToCheckout(context, items, total, ref);
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
            'ORDER NOW ₹${total.toStringAsFixed(2)}',
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
  // void _proceedToCheckout(
  //   BuildContext context,
  //   List<Map<String, dynamic>> items,
  //   double total,
  //   WidgetRef ref,
  // ) async {
  //   final user = ref.read(currentUserProvider);

  //   log('=== Cart Checkout Details ===');
  //   log('Total Items: ${items.length}');
  //   log('Total Amount: ₹${total.toStringAsFixed(2)}');

  //   // Check if user is logged in
  //   if (user == null || user.phoneNumber == null) {
  //     log('User not authenticated with phone number');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           'Please login with your phone number before making a payment.',
  //         ),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     context.push('/login-screen');
  //     return;
  //   }

  //   final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';

  //   try {
  //     log('Initiating payment from cart...');

  //     // Calculate total quantity from all cart items
  //     final totalQuantity = items.fold(
  //       0,
  //       (int sum, item) => sum + ((item['quantity'] as num).toInt() ?? 1),
  //     );

  //     // Use the first item's name or create a generic name for cart order
  //     final productName = items.isNotEmpty
  //         ? items.first['name'] ?? 'Cart Items'
  //         : 'Cart Order';

  //     await ref
  //         .read(paymentProvider.notifier)
  //         .initiatePayment(
  //           amount: total,
  //           productName: 'Cart - $productName & ${items.length - 1} more',
  //           quantity: totalQuantity,
  //           orderId: orderId,
  //         );

  //     // Optional: Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Proceeding to payment with ${items.length} items',
  //           style: GoogleFonts.dmSans(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //         backgroundColor: const Color(0xFF36C07E),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         margin: EdgeInsets.all(16),
  //       ),
  //     );
  //   } catch (e) {
  //     log('Checkout error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Checkout failed: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     );
  //   }
  // }
  void _proceedToCheckout(
    BuildContext context,
    List<Map<String, dynamic>> items,
    double total,
    WidgetRef ref,
  ) async {
    final user = ref.read(currentUserProvider);
    final orderType = ref.read(orderTypeProvider);
    final tableNumber = ref.read(selectedtableNumberProvider);
    final customerName = ref.read(customerNameProvider);

    // Calculate total with voucher discount
    double subtotal = 0;
    for (var item in items) {
      final price = _safeParseDouble(item['price']);
      final quantity = _safeParseInt(item['quantity'] ?? 1);
      subtotal += price * quantity;
    }
    const double taxRate = 0.10;
    final double tax = subtotal * taxRate;
    final voucherDiscount = ref.read(voucherDiscountProvider);
    final double finalTotal = subtotal + tax - voucherDiscount;

    log('=== Cart Checkout Details ===');
    log('Total Items: ${items.length}');
    log('Subtotal: ₹${subtotal.toStringAsFixed(2)}');
    log('Tax: ₹${tax.toStringAsFixed(2)}');
    log('Voucher Discount: ₹${voucherDiscount.toStringAsFixed(2)}');
    log('Final Total: ₹${finalTotal.toStringAsFixed(2)}');
    log('Order Type: $orderType');

    if (orderType == 'Coffee Hub') {
      log('Table Number: $tableNumber');
    } else {
      log('Customer Name: $customerName');
    }

    // Validation
    if (orderType == 'Coffee Hub' && tableNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a table number for Coffee Hub order'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (orderType == 'Parcel' &&
        (customerName == null || customerName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name for parcel order'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
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
      final totalQuantity = items.fold(
        0,
        (int sum, item) => sum + ((item['quantity'] as num).toInt()),
      );

      // Use the first item's name or create a generic name for cart order
      final productName = items.isNotEmpty
          ? items.first['name'] ?? 'Cart Items'
          : 'Cart Order';

      // Create order description based on type
      final orderDescription = orderType == 'Coffee Hub'
          ? 'Table $tableNumber - $productName & ${items.length - 1} more'
          : 'Parcel for $customerName - $productName & ${items.length - 1} more';

      // Get voucher information
      final voucherCode = ref.read(voucherCodeProvider);

      await ref
          .read(paymentProvider.notifier)
          .initiatePayment(
            amount: finalTotal,
            productName: orderDescription,
            quantity: totalQuantity,
            orderId: orderId,
            orderType: orderType,
            customerName: customerName,
            tableNumber: tableNumber,
            cartItems: items,
            voucherDiscount: voucherDiscount,
            voucherCode: voucherCode.isNotEmpty ? voucherCode : null,
          );

      // Clear voucher state after successful payment
      ref.read(voucherCodeProvider.notifier).state = '';
      ref.read(voucherDiscountProvider.notifier).state = 0.0;
      ref.read(voucherAppliedProvider.notifier).state = false;

      // Optional: Show success message
      final successMessage = voucherDiscount > 0
          ? (orderType == 'Coffee Hub'
              ? 'Order placed for Table $tableNumber! Saved ₹${voucherDiscount.toStringAsFixed(2)} with voucher.'
              : 'Parcel order placed for $customerName! Saved ₹${voucherDiscount.toStringAsFixed(2)} with voucher.')
          : (orderType == 'Coffee Hub'
              ? 'Order placed for Table $tableNumber'
              : 'Parcel order placed for $customerName');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successMessage,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: const Color(0xFF36C07E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  // Build quantity controls
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
                    .updateQuantity(item['id'] ?? item['name'], quantity - 1);
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
                  .updateQuantity(item['id'] ?? item['name'], quantity + 1);
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
}
