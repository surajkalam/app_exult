import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:coffee_exult_app/Features/Cart/provider/cart_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/menu_provider.dart';
import 'package:coffee_exult_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class SearchMenuScreen extends ConsumerStatefulWidget {
  const SearchMenuScreen({super.key});

  @override
  ConsumerState<SearchMenuScreen> createState() => _SearchMenuScreenState();
}

class _SearchMenuScreenState extends ConsumerState<SearchMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allMenuItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAllMenuItems();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllMenuItems() {
    final menuCategoriesAsync = ref.read(menuCategoriesProvider);
    menuCategoriesAsync.whenData((menuCategories) {
      final List<Map<String, dynamic>> items = [];
      menuCategories.forEach((category, categoryItems) {
        items.addAll(categoryItems);
      });
      setState(() {
        _allMenuItems = items;
        _searchResults = items; // Show all items by default
      });
    });
  }

  void _onSearchChanged() {
    _search();
  }

  void _search() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = _allMenuItems; // Show all items if search is empty
      } else {
        _searchResults = _allMenuItems.where((item) {
          final itemName = item['name']?.toLowerCase() ?? '';
          final itemCategory = item['category']?.toLowerCase() ?? '';
          return itemName.contains(query) || itemCategory.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'Search Menu',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        // CustomAppBar does not have a 'leading' parameter, using default back button
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for coffee, tea, or menu items...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primaryContainer,
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  color: colorScheme.primaryContainer,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.secondaryFixed,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _search();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty && _isSearching
                ? Center(
                    child: Text(
                      'Sorry, it\'s not available. Try others.',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Adjust as needed
                        ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return _buildMenuItemCard(
                        context,
                        item,
                        colorScheme,
                        textTheme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    Map<String, dynamic> item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final itemName = item['name'] ?? 'Unknown Item';
    final itemDescription = item['description'] ?? 'No description available.';
    final itemPrice = item['price'] ?? 'N/A';
    final itemImage = item['image'];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSecondaryFixed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: itemImage != null
                    ? Image.network(
                        itemImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 120,
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.coffee,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
              // Not Available Badge
              if (item['isAvailable'] == false)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NOT AVAILABLE',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  itemDescription,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹$itemPrice",
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryFixedVariant,
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // Handle order now tap - add to cart
                        await _addToCart(context, item, colorScheme, ref);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryFixedVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Order Now",
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSecondaryFixed,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        _showAddToCartError(
          context,
          'Please log in to add items to cart',
          colorscheme,
        );
        if (context.mounted) {
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
