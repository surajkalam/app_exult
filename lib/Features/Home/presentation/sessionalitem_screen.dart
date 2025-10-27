import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:coffee_exult_app/DATABASE_HELPER/cart_data.dart';
import 'package:coffee_exult_app/Features/Cart/provider/cart_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/core.dart';
import '../models/models.dart';
import '../provider/provider.dart';

class SessionalItemsScreen extends ConsumerWidget {
  const SessionalItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionalItemAsync = ref.watch(seasonalItemsProvider);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'Sessional Specials',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: sessionalItemAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 16),
              Text(
                'Failed to load Sessional Specials',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primaryContainer,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Check your connection and try again',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.coffee, size: 60, color: colorScheme.secondaryFixed),
                  SizedBox(height: 16),
                  Text(
                    'No new Sessional available',
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
            );
          }

          return Padding(
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
                final hasImage = item.image.isNotEmpty;

                return _buildProductCard(
                  context,
                  height,
                  width,
                  item,
                  hasImage,
                  colorScheme,
                  textTheme,
                  ref,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Build product card with iOS design
  Widget _buildProductCard(
    BuildContext context,
    double height,
    double width,
    Item item,
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
                height: height * 0.12,
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
                          item.image,
                          fit: BoxFit.fill,
                          errorBuilder: (_, _, _) =>
                              _buildImagePlaceholder(colorscheme),
                        )
                      : _buildImagePlaceholder(colorscheme),
                ),
              ),
              Positioned(
                top: 1,
                right: 1,
                child: FavoriteIcon(
                  itemData: {
                    'name': item.name,
                    'type': item.type,
                    'rating': item.rating,
                    'image': item.image,
                    'description': item.description,
                    'price': item.price,
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: _buildRatingBadge(
                  item.rating,
                  colorscheme,
                  texttheme,
                ),
              ),
            ],
          ),

          // Product Details Section
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.name,
                  style: texttheme.bodyLarge?.copyWith(
                    color: colorscheme.primaryContainer,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Product Description (if available)
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: texttheme.bodySmall?.copyWith(
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
                        '₹${item.price}',
                        style: texttheme.bodyMedium?.copyWith(
                          color: colorscheme.onPrimaryFixedVariant,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await _addToCart(context, item, colorscheme, ref);
                          if (context.mounted) {
                            context.pushNamed(
                              'product',
                              pathParameters: {'id': item.name},
                              extra: item.toMap(),
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
            style: texttheme.labelMedium?.copyWith(color: colorscheme.primary),
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
        color: colorscheme.onPrimaryFixedVariant.withOpacity(0.5),
      ),
    );
  }

  // Add to cart function
  Future<void> _addToCart(
    BuildContext context,
    Item item,
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
      final itemName = item.name;
      final currentUser = ref.read(currentUserProvider);
      final userId = UserUtils.getUserIdentifier(user);
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.phoneNumber)
          .collection('cart')
          .doc(itemName)
          .set({
            ...item.toMap(),
            'quantity': FieldValue.increment(1),
            'addedAt': FieldValue.serverTimestamp(),
            'userId': userId,
          }, SetOptions(merge: true));

      await DatabaseHelper.instance.insertCartItem({
        'product_id': item.id ?? item.name,
        'name': item.name,
        'price': item.price,
        'quantity': 1,
        'image': item.image,
        'rating': item.rating,
      });

      if (context.mounted) {
        final ref = ProviderScope.containerOf(context);
        ref.refresh(cartProvider);
      }

      _showAddToCartSuccess(context, item.name, colorscheme);

      if (context.mounted) {
        final ref = ProviderScope.containerOf(context);
        ref.refresh(cartProvider);
      }
    } catch (e) {
      _showAddToCartError(context, e.toString(), colorscheme);
    }
  }

  // Show success feedback
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