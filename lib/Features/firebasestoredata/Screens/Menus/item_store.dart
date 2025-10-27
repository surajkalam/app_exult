// screens/items_store_screen.dart
import 'dart:developer';

import 'package:coffee_exult_app/Features/Home/models/items_model.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/Menus/edit_items.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/provider/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemsStoreScreen extends ConsumerStatefulWidget {
  const ItemsStoreScreen({super.key});

  @override
  ConsumerState<ItemsStoreScreen> createState() => _ItemsStoreScreenState();
}

class _ItemsStoreScreenState extends ConsumerState<ItemsStoreScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch all items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchItems();
      // Check Firebase structure
      ref.read(firebaseStructureProvider.future);
    });
  }

  // In your items_store_screen.dart, just use this simple fetch:
  void _fetchItems() {
    log('🔄 Fetching items from Firebase...');
    if (_selectedCategory == 'All') {
      ref.read(itemsProvider.notifier).fetchAllItems();
    } else {
      ref.read(itemsProvider.notifier).fetchItemsByCategory(_selectedCategory);
    }
  }

  void _onSearchChanged(String query) {
    log('🔍 Searching for: $query');
    setState(() {});
  }

  List<Item> _getFilteredItems(List<Item> allItems) {
    final searchQuery = _searchController.text.toLowerCase();

    var filteredItems = _selectedCategory == 'All'
        ? allItems
        : allItems
              .where(
                (item) =>
                    item.category.toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();

    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery) ||
                item.type.toLowerCase().contains(searchQuery) ||
                item.category.toLowerCase().contains(searchQuery),
          )
          .toList();
    }

    log('📊 Displaying ${filteredItems.length} filtered items');
    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsProvider);
    final categories = ref.watch(categoriesProvider);

    // Debug output
    ref.read(debugProvider);

    final displayedItems = _getFilteredItems(itemsState.items);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Items Store Management'),
        backgroundColor: Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Items',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          // Category Filter
          _buildCategoryFilter(categories),
          // Statistics Cards
          _buildStatistics(displayedItems),
          // Items List
          Expanded(child: _buildItemsList(itemsState, displayedItems)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItem(context),
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        tooltip: 'Add New Item',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search items by name, type, or category...',
          hintStyle: TextStyle(color: Colors.black, fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.grey,
            ), // Grey border when not focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.grey,
            ), // Grey border when enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.black,
            ), // Black border when focused
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 10, right: 10, bottom: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    selected: _selectedCategory == category,
                    selectedColor: Color(0xFF6D4C41),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _fetchItems();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Item> items) {
    final totalItems = items.length;
    final totalValue = items.fold(0.0, (sum, item) => sum + item.price);
    final averagePrice = totalItems > 0 ? totalValue / totalItems : 0;
    final activeItems = items.where((item) => item.isAvailable).length;
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          _buildStatCard(
            'Total Items',
            totalItems.toString(),
            Icons.inventory,
            const Color(0xFF6D4C41),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Active Items',
            activeItems.toString(),
            Icons.check_circle,
            const Color(0xFF2E7D32),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Total Value',
            '\$${totalValue.toStringAsFixed(2)}',
            Icons.attach_money,
            const Color(0xFF1565C0),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Avg Price',
            '\$${averagePrice.toStringAsFixed(2)}',
            Icons.trending_up,
            const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: color),
            SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 6, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(ItemsState itemsState, List<Item> displayedItems) {
    if (itemsState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6D4C41)),
            SizedBox(height: 16),
            Text(
              'Loading items from Firebase...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (itemsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading items',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                itemsState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (displayedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coffee_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _selectedCategory == 'All'
                  ? 'No items found in Firebase'
                  : 'No items in $_selectedCategory category',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Search query: "${_searchController.text}"',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToAddItem(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
              ),
              child: const Text('Add New Item'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: displayedItems.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = displayedItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.image),
                  fit: BoxFit.cover,
                  // errorBuilder: (context, error, stackTrace) {
                  //   return Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[200],
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: const Icon(Icons.coffee, size: 40, color: Colors.grey),
                  //   );
                  // },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Text(
                            'Not available',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.type,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      // // Icon(Icons.attach_money, size: 16, color: Colors.green),
                      // const SizedBox(width: 2),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 55,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              item.category,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                color: _getCategoryColor(item.category),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ID:${item.id?.substring(0, 8) ?? "N/A"}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value, item),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.brown),
                      SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 14, color: Colors.brown),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_availability',
                  child: Row(
                    children: [
                      Icon(
                        item.isAvailable ? Icons.block : Icons.check_circle,
                        size: 18,
                        color: item.isAvailable ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.isAvailable ? 'Not Available' : 'Mark Available',
                        style: TextStyle(
                          fontSize: 14,
                          color: item.isAvailable
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return const Color(0xFF6D4C41);
      case 'tea':
        return const Color(0xFF4CAF50);
      case 'cooler':
        return const Color(0xFF2196F3);
      case 'snacks':
        return const Color(0xFFFF9800);
      case 'frozen':
        return const Color(0xFF00BCD4);
      case 'crispy delicious':
        return const Color(0xFF9C27B0);
      case 'breadcraft':
        return const Color(0xFF795548);
      case 'house specials':
        return const Color(0xFFF44336);
      case 'continental':
        return const Color(0xFF607D8B);
      case 'dessertduo':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF6D4C41);
    }
  }

  void _handleMenuAction(String action, Item item) {
    switch (action) {
      case 'edit':
        _navigateToEditItem(context, item);
        break;
      case 'toggle_availability':
        _toggleItemAvailability(item);
        break;
      case 'delete':
        _showDeleteDialog(item);
        break;
    }
  }

  void _toggleItemAvailability(Item item) {
    log('🔄 Toggling availability for ${item.name}');
    final updatedItem = item.copyWith(isAvailable: !item.isAvailable);

    ref
        .read(itemsProvider.notifier)
        .updateItem(updatedItem, item.category)
        .then((_) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${item.name} marked as ${updatedItem.isAvailable ? 'Available' : 'Sold Out'}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating item: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }
  void _navigateToAddItem(BuildContext context){
    log('➕ Navigating to Add Item screen');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
    ).then((_) {
      // Refresh items after adding/editing
      _fetchItems();
    });
  }
  void _navigateToEditItem(BuildContext context, Item item) {
    log('✏️ Navigating to Edit Item screen for ${item.name}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditItemScreen(item: item)),
    ).then((_) {
      // Refresh items after editing
      _fetchItems();
    });
  }

  void _showDeleteDialog(Item item) {
    log('🗑️ Showing delete dialog for ${item.name}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(Item item) async {
    log('🗑️ Deleting item: ${item.name}');
    try {
      await ref
          .read(itemsProvider.notifier)
          .deleteItem(item.id!, item.category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.name}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('💥 Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
