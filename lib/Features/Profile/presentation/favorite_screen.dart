
import 'dart:developer';
// Make sure this imports the updated providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/widget/widgets.dart';
import '../../Menu/Provider/Provider.dart';
class FavoriteMenuScreen extends ConsumerWidget {
  const FavoriteMenuScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final favoritesAsync = ref.watch(favoritesStreamProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        titleText: 'Favorites',
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: favoritesAsync.when(
        loading: () => _buildLoadingState(width, height),
        error: (error, stack) => _buildErrorState(error, ref, width, height),
        data: (favorites) =>
            _buildFavoritesList(favorites, ref, width, height, context),
      ),
    );
  }

  Widget _buildLoadingState(double width, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: height * 0.02),
          Text(
            'Loading your favorites...',
            style: GoogleFonts.dmSans(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    dynamic error,
    WidgetRef ref,
    double width,
    double height,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
              // ignore: deprecated_member_use
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Unable to load favorites',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: height * 0.03),
            _buildRetryButton(ref, width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(WidgetRef ref, double width, double height) {
    return ElevatedButton(
      onPressed: () => ref.refresh(favoritesStreamProvider),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.015,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Try Again',
        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFavoritesList(
    List favorites,
    WidgetRef ref,
    double width,
    double height,
    BuildContext context,
  ) {
    log('favorites item :$favorites');
    if (favorites.isEmpty) {
      return _buildEmptyState(width, height);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.02,
      ),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => SizedBox(height: height * 0.02),
      itemBuilder: (context, index) {
        final item = favorites[index];
        return _buildFavoriteItem(item, ref, width, height, context);
      },
    );
  }

  Widget _buildEmptyState(double width, double height) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 60,
              // ignore: deprecated_member_use
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'No favorites yet',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Items you mark as favorite will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(
    item,
    WidgetRef ref,
    double width,
    double height,
    BuildContext context,
  ) {
    final hasImage = item['image'] != null;
    // Watch reactive favorite status
    final isFavorite = ref.watch(itemFavoriteStatusProvider(item['name']));

    return GestureDetector(
      onTap: () {
        context.push('/toproduct', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: width * 0.22,
                  width: width * 0.22,
                  color: AppColors.primaryLight,
                  child: hasImage
                      ? Image.network(
                          item['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _buildPlaceholderIcon(width),
                        )
                      : _buildPlaceholderIcon(width),
                ),
              ),
              SizedBox(width: width * 0.04),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'No Name',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: height * 0.008),
                    _buildRatingRow(item, width),
                    SizedBox(height: height * 0.012),
                    Row(
                      children: [
                        Text(
                          'INR ${item['price'] ?? '0'}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        _buildFavoriteButton(
                          context,
                          ref,
                          item['name'],
                          width,
                          isFavorite, // Pass reactive state
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(double width) {
    return Center(
      child: Icon(
        Icons.coffee_rounded,
        size: width * 0.1,
        color: AppColors.primary,
      ),
    );
  }

  // ignore: strict_top_level_inference
  Widget _buildRatingRow(item, double width) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: 4),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.accent,
                size: width * 0.04,
              ),
              SizedBox(width: width * 0.01),
              Text(
                (item['rating']?.toStringAsFixed(1) ?? '0.0'),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: width * 0.02),
        Text(
          '${item['ratingCount'] ?? '0'} reviews',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(
    BuildContext context,
    WidgetRef ref,
    String itemName,
    double width,
    bool isFavorite, // Add parameter
  ) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: Colors.red,
        size: width * 0.06,
      ),
      onPressed: () => _showRemoveConfirmation(context, ref, itemName, width),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    WidgetRef ref,
    String itemName,
    double width,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove from favorites?"),
          content: Text(
            "Are you sure you want to remove this item from your favorites?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _removeFavorite(ref, itemName);
                Navigator.of(context).pop();
              },
              child: Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFavorite(WidgetRef ref, String itemName) async {
    // Use the reactive state notifier
    await ref.read(favoritesStateProvider.notifier).removeFavorite(itemName);
  }
}
