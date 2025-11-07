import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';

import 'package:coffee_exult_app/core/core.dart';
import 'package:coffee_exult_app/Features/Cart/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../data/data.dart';

class CategoryItemsScreen extends ConsumerWidget {
  final String categoryName;
  final List<Map<String, dynamic>> items;

  const CategoryItemsScreen({
    super.key,
    required this.categoryName,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  
    log('welcome menu description screen');
    final currentUser = ref.watch(currentUserProvider);
    log('Current user: ${currentUser?.phoneNumber?? "No user logged in"}, '
        'Phone: ${currentUser?.phoneNumber ?? "N/A"}');
    log('categoryName : $categoryName');
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.onPrimary,
        appBar: CustomAppBar(
          titleText: categoryName,
          centerTitle: true,
          backgroundColor: colorScheme.surface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.coffee, size: 60, color: colorScheme.secondaryFixed),
              SizedBox(height: 16),
              Text(
                'No items available',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primaryContainer,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for new additions',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      // appBar: _buildAppBar(categoryName, context),
      appBar: CustomAppBar(
        titleText: categoryName,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            log('items: $item');
            final hasImage = item['image'] != null;
            return _buildProductCard(
              context,
              height,
              width,
              item,
              hasImage,
              colorScheme,
              textTheme,
              ref
            );
          },
        ),
      ),
    );
  }
 Future<List<Product>> getProductsByCategory(String category) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      log('Fetching products for category: $category');

      final QuerySnapshot categorySnapshot = await firestore
          .collection('items')
          .doc('1757264051191711')
          .collection(category)
          .get();

      log('Total products found in $category: ${categorySnapshot.docs.length}');

      // Print each product's data to console
      for (final doc in categorySnapshot.docs) {
        log('Product ID: ${doc.id}');
        log('Product data: ${doc.data()}');
        log('-----------------------------');
      }

      final List<Product> allProducts = categorySnapshot.docs.map((productDoc) {
        final data = productDoc.data() as Map<String, dynamic>;
        // Include the document ID in the data
        data['id'] = productDoc.id;
        return Product.fromMap(data);
      }).toList();

      log(
        'Successfully fetched ${allProducts.length} products from category $category',
      );
      return allProducts;
    } catch (e) {
      log('Error getting products: $e');
      rethrow;
    }
  }

  // Build product card with iOS design
  Widget _buildProductCard(
    BuildContext context,
    double height,
    double width,
    Map<String, dynamic> item,
    bool hasImage,
    ColorScheme colorscheme,
    TextTheme texttheme,
    WidgetRef ref, 
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorscheme.onSecondaryFixed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: height * 0.133,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: colorscheme.onSecondaryFixed,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: hasImage
                      ? Image.network(
                          item['image'],
                          fit: BoxFit.fill,
                          errorBuilder: (_, _, _) =>
                              _buildImagePlaceholder(colorscheme),
                        )
                      : _buildImagePlaceholder(colorscheme),
                ),
              ),
              // Not Available Badge
              if (item['isAvailable'] == false)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.black.withOpacity(0.6),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NOT AVAILABLE',
                          style: texttheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 1,
                right: 1,
                child: FavoriteIcon(
                  itemData: {
                    'name': item['name'] ?? '',
                    'type': item['type'] ?? '',
                    'rating': item['rating'] ?? 0,
                    'image': item['image'] ?? '',
                    'description': item['description'] ?? '',
                    'price': item['price'] ?? 0,
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: _buildRatingBadge(
                  item['rating'] ?? 0,
                  colorscheme,
                  texttheme,
                ),
              ),
            ],
          ),
          // Product Details Section
          Padding(
            padding:EdgeInsets.only(left: width * 0.01,right: width * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item['name'] ?? 'No Name',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorscheme.primaryContainer,
                    fontSize: 14,
                  ),
                  // maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Product Description (if available)
                if (item['description'] != null &&
                    item['description'].isNotEmpty)
                  Text(
                    item['description'],
                    style: textTheme.bodySmall?.copyWith(
                      color: colorscheme.secondary,
                      fontSize: 9,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 6),
                // Price and Add to Cart Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item['price'] ?? '0'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorscheme.onPrimaryFixedVariant,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await _addToCart(context, item, colorscheme,ref);
                          if (context.mounted) {
                            context.pushNamed(
                              'product',
                              pathParameters: {'id': item['name'].toString()},
                              extra: item,
                            );
                          }
                        },
                        child: _buildAddToCartButton(colorscheme, texttheme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build rating badge
  Widget _buildRatingBadge(
    double rating,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: colorscheme.onSecondaryFixed.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.star1, size: 14, color: colorscheme.secondaryFixed),
          SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: textTheme.labelMedium?.copyWith(color: colorscheme.primary),
          ),
        ],
      ),
    );
  }

  // Build add to cart button
  Widget _buildAddToCartButton(ColorScheme colorscheme, TextTheme texttheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorscheme.onPrimaryFixedVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Iconsax.add, size: 18, color: colorscheme.onSecondaryFixed),
    );
  }

  // Build image placeholder
  Widget _buildImagePlaceholder(ColorScheme colorscheme) {
    return Center(
      child: Icon(
        Iconsax.coffee,
        size: 40,
        // ignore: deprecated_member_use
        color: colorscheme.onPrimaryFixedVariant.withOpacity(0.5),
      ),
    );
  }

  // Add to cart function
  Future<void> _addToCart(
    BuildContext context,
    Map<String, dynamic> itemData,
    ColorScheme colorscheme,
    WidgetRef ref,
  ) async {
    try {
      final user = ref.read(currentUserProvider); 
     if (user == null) {
        _showAddToCartError(context, 'Please log in to add items to cart', colorscheme);
        if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please log in to add items to cart'),
              backgroundColor: colorscheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(16),
            ),
          );
          context.push('/login-screen');
        }
        return;
      }

      final itemName = itemData['name'];
      final currentUser = ref.read(currentUserProvider);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.phoneNumber)
          .collection('cart')
          .doc(itemName)
          .set({
            ...itemData,
            'quantity': FieldValue.increment(1),
            'addedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (context.mounted) {
        final ref = ProviderScope.containerOf(context);
        ref.refresh(cartProvider);
      }

      // ignore: use_build_context_synchronously
      _showAddToCartSuccess(context, itemData['name'], colorscheme);

      if (context.mounted) {
        final ref = ProviderScope.containerOf(context);
        ref.refresh(cartProvider);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showAddToCartError(context, e.toString(), colorscheme);
    }
  }

  // Show success feedback with iOS-style animation
  void _showAddToCartSuccess(
    BuildContext context,
    String itemName,
    ColorScheme colorscheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart'),
        backgroundColor: colorscheme.onSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Show error feedback
  void _showAddToCartError(
    BuildContext context,
    String error,
    ColorScheme colorscheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to add to cart: $error'),
        backgroundColor: colorscheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
