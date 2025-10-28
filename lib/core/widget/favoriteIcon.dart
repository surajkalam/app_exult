import 'package:coffee_exult_app/Features/Menu/Provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteIcon extends ConsumerWidget {
  final Map<String, dynamic> itemData;

  const FavoriteIcon({super.key, required this.itemData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    // Watch the reactive favorite status
    final isFavorite = ref.watch(itemFavoriteStatusProvider(itemData['name']));
    final favoritesNotifier = ref.watch(favoritesProvider);

    return favoritesNotifier.when(
      loading: () => SizedBox(
        width: width * 0.02,
        height: height * 0.02,
        child: const CircularProgressIndicator(
          strokeWidth: 0.1,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      error: (error, stack) => IconButton(
        icon: Icon(
          Icons.favorite_border,
          color: Colors.red,
          size: width * 0.068,
        ),
        onPressed: () => _toggleFavorite(ref),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      data: (_) => IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
          size: width * 0.068,
        ),
        onPressed: () => _toggleFavorite(ref),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref) async {
    try {
      await ref.read(favoritesProvider.notifier).toggleFavorite(itemData);
    } catch (e) {
      // Handle error if needed
    }
  }
}
