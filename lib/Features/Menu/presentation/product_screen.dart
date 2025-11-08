import 'dart:developer';
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/favorite_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/menu_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/paymentProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../Profile/Provider/voucher_provider.dart';

final quantityProvider = StateProvider<int>((ref) => 1);

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({super.key, required this.product});
  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentuser = ref.watch(currentUserProvider);
    // Watch reactive favorite status
    final isFavorite = ref.watch(
      itemFavoriteStatusProvider(widget.product['name']),
    );
    final isAvailable = widget.product['isAvailable'] ?? '';
    log('isAvailable: $isAvailable');
    log('welcome menu description screen');
    log(
      'Current user: ${currentuser?.uid ?? "No user logged in"}, '
      'Phone: ${currentuser?.phoneNumber ?? "N/A"}',
    );
    // final user = FirebaseAuth.instance.currentUser;
    // log('${user?.phoneNumber}');
    final appliedVoucherId = ref.watch(appliedVoucherIdProvider);
    final voucherDiscount = ref.watch(voucherDiscountProvider);
    final voucherError = ref.watch(voucherErrorProvider);
    final isChecking = ref.watch(isCheckingVoucherProvider);

    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      log('Payment State Changed:');
      log('Previous: ${previous?.paymentSuccess}');
      log('Next: ${next.paymentSuccess}');
      if (next.paymentSuccess && mounted) {
        final paymentData = ref
            .read(paymentProvider.notifier)
            .getLastPaymentData();
        log('paymentdata : $paymentData');

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            context.push('/payment-success', extra: paymentData);
            ref.read(paymentProvider.notifier).clearSuccess();
          }
        });
      }
    });
    final quantity = ref.watch(quantityProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final product = widget.product;
    final price = product['price'] != null
        ? (product['price'] is num
              ? product['price'] as num
              : (double.tryParse(product['price'].toString()) ?? 0.0))
        : 0.0;
    // Calculate discount and final price
    final discountAmount = (price * quantity * voucherDiscount) / 100;
    final totalPrice = price * quantity;
    final finalPrice = totalPrice - discountAmount;
    log('starting product :$product');
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: _buildAppBar(
        context,
        product['name'] ?? 'Product Details',
        colorScheme,
        textTheme,
        isFavorite, // Use reactive state
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with iOS-style design
            _buildProductImage(
              MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width,
              ref,
              product,
              colorScheme,
              textTheme,
            ),
            const SizedBox(height: 24),

            // Product Name and Rating
            _buildProductHeader(
              context,
              ref,
              MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width,
              quantity,
              price,
              product,
              colorScheme,
              textTheme,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Voucher Input Section
            _buildVoucherSection(
              context,
              ref,
              appliedVoucherId,
              voucherDiscount,
              voucherError,
              isChecking,
              colorScheme,
              textTheme,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Price Section
            _buildPriceSection(
              price,
              totalPrice,
              finalPrice,
              discountAmount,
              quantity,
              appliedVoucherId,
              voucherDiscount,
              colorScheme,
              textTheme,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Description (if available)
            if (product['description'] != null)
              _buildDescriptionSection(
                MediaQuery.of(context).size.height,
                product,
                colorScheme,
                textTheme,
              ),

            // Add to Cart Button
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            // _buildCheckoutButton(
            //   context,
            //   ref,
            //   product,
            //   quantity,
            //   price,
            //   finalPrice,
            //   colorScheme,
            //   textTheme,
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(favoritesProvider.notifier).toggleFavorite(widget.product);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Build iOS-style app bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String title,
    ColorScheme colorscheme,
    TextTheme texttheme,
    bool isFavorite, // Use parameter instead of local state
  ) {
    return AppBar(
      backgroundColor: colorscheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: texttheme.titleLarge?.copyWith(
          color: colorscheme.primaryContainer,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left, color: colorscheme.primary),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        _isLoading
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
                  color: isFavorite ? Colors.red : colorscheme.secondaryFixed,
                ),
                onPressed: _toggleFavorite,
              ),
      ],
    );
  }

  // Build product image section
  Widget _buildProductImage(
    double height,
    double width,
    ref,
    Map<String, dynamic> product,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final isAvailable = product['isAvailable'] ?? true;
    return Stack(
      children: [
        Container(
          height: height * 0.32,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorscheme.onSecondaryFixed,
            boxShadow: [
              BoxShadow(
                color: colorscheme.shadow,
                offset: Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: product['image'] != null
                ? Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _buildImagePlaceholder(colorscheme),
                  )
                : _buildImagePlaceholder(colorscheme),
          ),
        ),
        // Not Available Overlay Badge
        if (!isAvailable)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.7),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'NOT AVAILABLE',
                    style: texttheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Build image placeholder
  Widget _buildImagePlaceholder(ColorScheme colorscheme) {
    return Center(
      child: Icon(
        Iconsax.coffee,
        size: 60,
        // ignore: deprecated_member_use
        color: colorscheme.secondaryFixed.withValues(alpha: 0.3),
      ),
    );
  }

  // Build product header with name, rating, and quantity controls
  Widget _buildProductHeader(
    BuildContext context,
    WidgetRef ref,
    double height,
    double width,
    int quantity,
    num price,
    Map<String, dynamic> product,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          product['name'] ?? 'No Name',
          style: texttheme.bodyLarge?.copyWith(
            color: colorscheme.primaryContainer,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: height * 0.01),

        // Rating and Quantity Controls
        Row(
          children: [
            // Rating
            _buildRatingStars(product, colorscheme, texttheme),
            SizedBox(width: 8),
            Text(
              (product['rating']?.toStringAsFixed(1) ?? '0.0'),
              style: texttheme.titleMedium?.copyWith(
                color: colorscheme.secondary,
              ),
            ),
            Spacer(),
            // Quantity Controls
            _buildQuantityControls(
              ref,
              height,
              width,
              quantity,
              colorscheme,
              texttheme,
            ),
          ],
        ),
      ],
    );
  }

  // Build rating stars
  Widget _buildRatingStars(
    Map<String, dynamic> product,
    colorscheme,
    texttheme,
  ) {
    return Row(
      children: List.generate(5, (index) {
        IconData icon;
        if (index < (product['rating']?.floor() ?? 0)) {
          icon = Iconsax.star1;
        } else if (index == (product['rating']?.floor() ?? 0) &&
            (product['rating'] ?? 0) % 1 >= 0.5) {
          icon = Iconsax.star;
        } else {
          icon = Iconsax.star;
        }
        return Icon(icon, color: colorscheme.onPrimaryFixed, size: 20);
      }),
    );
  }

  // Build quantity controls
  Widget _buildQuantityControls(
    WidgetRef ref,
    double height,
    double width,
    int quantity,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorscheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorscheme.shadow),
      ),
      child: Row(
        children: [
          // Decrease button
          IconButton(
            onPressed: () {
              if (quantity > 1) {
                ref.read(quantityProvider.notifier).state--;
                log('Item count: ${quantity - 1}');
              }
            },
            icon: Icon(
              Iconsax.minus,
              size: 20,
              color: quantity > 1
                  ? colorscheme.secondaryFixed
                  : colorscheme.secondary,
            ),
            splashRadius: 20,
          ),
          // Quantity display
          SizedBox(
            width: width * 0.08,
            child: Center(
              child: Text(
                "$quantity",
                style: texttheme.labelMedium?.copyWith(
                  color: colorscheme.primaryContainer,
                ),
              ),
            ),
          ),
          // Increase button
          IconButton(
            onPressed: () {
              if (quantity < 50) {
                ref.read(quantityProvider.notifier).state++;
              } else {
                _showLimitDialog();
              }
              // ref.read(quantityProvider.notifier).state++;
              // log('Item count: ${quantity + 1}');
            },
            icon: Icon(
              Iconsax.add,
              size: 20,
              color: colorscheme.secondaryFixed,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quantity Limit Reached'),
          content: const Text(
            'You have reached the maximum quantity limit of 50.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Build voucher section
  Widget _buildVoucherSection(
    BuildContext context,
    WidgetRef ref,
    String? appliedVoucherId,
    double voucherDiscount,
    String? voucherError,
    bool isChecking,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final voucherController = ref.read(voucherControllerProvider);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorscheme.onSecondaryFixed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apply Voucher',
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.primary,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: voucherController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.black),
                    errorText: voucherError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              isChecking
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(
                        Iconsax.discount_shape,
                        color: colorscheme.secondaryFixed,
                      ),
                      onPressed: () async {
                        final voucherId = voucherController.text.trim();
                        if (voucherController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Enter coupon code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        if (voucherId.isNotEmpty) {
                          final applied = await applyVoucher(ref, voucherId);
                          if (!applied && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(voucherError ?? 'Invalid cupon'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
            ],
          ),
          if (appliedVoucherId != null) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied Voucher:',
                  style: texttheme.bodySmall?.copyWith(
                    color: colorscheme.secondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$appliedVoucherId ($voucherDiscount% off)',
                  style: texttheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            ElevatedButton(
              onPressed: () => removeVoucher(ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorscheme.error,
                foregroundColor: colorscheme.onError,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Remove Voucher'),
            ),
          ],
        ],
      ),
    );
  }

  // Build price section
  Widget _buildPriceSection(
    num price,
    num totalPrice,
    num finalPrice,
    num discountAmount,
    int quantity,
    String? appliedVoucherId,
    double voucherDiscount,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final pricingResult = ref.watch(
      productPricingProvider(totalPrice.toDouble()),
    );
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorscheme.onSecondaryFixed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Details',
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.primary,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unit Price:',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${price.toStringAsFixed(2)}',
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity:',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                  fontSize: 12,
                ),
              ),
              Text(
                quantity.toString(),
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${pricingResult.subtotal.toStringAsFixed(2)}',
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.primary,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Charges:',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${pricingResult.deliveryCharge.toStringAsFixed(2)}',
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Charges:',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${pricingResult.serviceCharge.toStringAsFixed(2)}',
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxes (10%):',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${pricingResult.tax.toStringAsFixed(2)}',
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.primary,
                ),
              ),
            ],
          ),
          // Discount if applied
          if (pricingResult.voucherDiscountPercentage > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${pricingResult.voucherDiscountPercentage}%):',
                  style: texttheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '-₹${pricingResult.discountAmount.toStringAsFixed(2)}',
                  style: texttheme.bodyMedium?.copyWith(color: Colors.green),
                ),
              ],
            ),
          ],

          SizedBox(height: 8),
          Divider(height: 1, color: colorscheme.shadow),
          SizedBox(height: 8),

          // Final Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${pricingResult.grandTotal.toStringAsFixed(2)}',
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.secondaryFixed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build description section
  Widget _buildDescriptionSection(
    double height,
    Map<String, dynamic> product,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorscheme.onSecondaryFixed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.primary,
              fontSize: 13,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            product['description'],
            style: texttheme.bodySmall?.copyWith(
              color: colorscheme.secondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Build checkout button
  // Widget _buildCheckoutButton(
  //   BuildContext context,
  //   WidgetRef ref,
  //   Map<String, dynamic> product,
  //   int quantity,
  //   num price,
  //   num finalPrice,
  //   ColorScheme colorscheme,
  //   TextTheme texttheme,
  // ) {
  //   final isLoggedIn = ref.watch(isLoggedInProvider);
  //   final isAvailable = product['isAvailable'] ?? true;

  //   // Calculate final pricing
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: (isLoggedIn && isAvailable)
  //           ? () {
  //               final user = ref.read(currentUserProvider);
  //               final subtotal = price * quantity;
  //               final pricingResult = ref.watch(
  //                 productPricingProvider(subtotal.toDouble()),
  //               );
  //               if (user == null) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text("Please log in before making a payment"),
  //                     margin: EdgeInsets.all(16),
  //                     behavior: SnackBarBehavior.floating,
  //                     backgroundColor: Colors.red,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(12)),
  //                     ),
  //                   ),
  //                 );
  //                 return;
  //               } else {
  //                 _handleCheckout(
  //                   context,
  //                   ref,
  //                   product,
  //                   quantity,
  //                   price,
  //                   pricingResult.grandTotal, // Pass the correct grand total
  //                   colorscheme,
  //                   texttheme,
  //                 );
  //               }
  //             }
  //           : null,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: isAvailable
  //             ? colorscheme.onPrimaryFixedVariant
  //             : Colors.grey,
  //         foregroundColor: colorscheme.onSecondaryFixed,
  //         padding: EdgeInsets.symmetric(vertical: 16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         elevation: (isLoggedIn && isAvailable) ? 4 : 0,
  //         // ignore: deprecated_member_use
  //         shadowColor: colorscheme.shadow.withValues(alpha:0.3),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             isAvailable ? Iconsax.shopping_cart : Icons.block,
  //             size: 20,
  //             color: colorscheme.onSecondaryFixed,
  //           ),
  //           SizedBox(width: 8),
  //           Text(
  //             isAvailable
  //                 ? 'Proceed to Checkout ($quantity items) ₹${finalPrice.toStringAsFixed(2)}'
  //                 : 'Product Not Available',
  //             style: texttheme.bodySmall?.copyWith(
  //               color: colorscheme.onSecondaryFixed,
  //               fontSize: 10,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //   void _handleCheckout(
  //     BuildContext context,
  //     WidgetRef ref,
  //     Map<String, dynamic> product,
  //     int quantity,
  //     num price,
  //     num finalPrice, // This is the old parameter - we'll replace it
  //     ColorScheme colorscheme,
  //     TextTheme texttheme,
  //   ) async {
  //     final user = ref.read(currentUserProvider);
  //     final appliedVoucherId = ref.read(appliedVoucherIdProvider);

  //     // Calculate the current pricing using the provider
  //     final subtotal = price * quantity;
  //     final pricingResult = ref.read(productPricingProvider(subtotal.toDouble()));

  //     log('User: ${user?.uid ?? "No user"}');
  //     log('Phone: ${user?.phoneNumber ?? "N/A"}');
  //     log('=== Checkout Details ===');
  //     log('Product: ${product['name']}');
  //     log('Quantity: $quantity');
  //     log('Unit Price: ₹${price.toStringAsFixed(2)}');
  //     log('Subtotal: ₹${pricingResult.subtotal.toStringAsFixed(2)}');
  //     log('Delivery: ₹${pricingResult.deliveryCharge.toStringAsFixed(2)}');
  //     log('Service: ₹${pricingResult.serviceCharge.toStringAsFixed(2)}');
  //     log('Tax: ₹${pricingResult.tax.toStringAsFixed(2)}');

  //     if (pricingResult.voucherDiscountPercentage > 0) {
  //       log(
  //         'Discount: ${pricingResult.voucherDiscountPercentage}% (-₹${pricingResult.discountAmount.toStringAsFixed(2)})',
  //       );
  //     }

  //     log('Grand Total: ₹${pricingResult.grandTotal.toStringAsFixed(2)}');

  //     if (appliedVoucherId != null) {
  //       log('Applied Voucher: $appliedVoucherId');
  //     }

  //     if (user == null || user.phoneNumber == null) {
  //       log('User not authenticated with phone number');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text(
  //             'Please login with your phone number before making a payment.',
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       context.push('/login-screen');
  //       return;
  //     }

  //     final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';

  //     try {
  //       log('Initiating payment...');
  //       await ref
  //           .read(paymentProvider.notifier)
  //           .initiatePayment(
  //             amount:
  //                 pricingResult.grandTotal, // Use pricing provider's grand total
  //             productName: product['name'],
  //             quantity: quantity,
  //             orderId: orderId,
  //           );
  //     } catch (e) {
  //       log('Payment initiation error: $e');
  //       // ignore: use_build_context_synchronously
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Payment failed: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       );
  //     }

  //     log('=======================');
  //   }
}
//  in featurefirestorestoredata/menus/items_store.dart every card having three dot on tap not available then update in database and show in feture /menu/presentation/product_screen.dart  their show batch not available if available show their 