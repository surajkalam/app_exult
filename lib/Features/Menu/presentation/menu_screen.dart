import 'package:coffee_exult_app/Features/Menu/Provider/menu_provider.dart';
import 'package:coffee_exult_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';


class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuCategoriesAsync = ref.watch(menuCategoriesProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      // appBar: _buildAppBar(context),
      appBar: CustomAppBar(
        titleText: 'Menu',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.search_normal,
              color: colorScheme.secondaryFixed,
            ),
            onPressed: () {
              context.push('/search-menu');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              menuCategoriesAsync.when(
                loading: () => _buildLoadingState(height, width, colorScheme),
                error: (error, stack) =>
                    _buildErrorState(error, height, width, colorScheme, ref),
                data: (menuCategories) => _buildCategoryGrid(
                  height,
                  width,
                  menuCategories,
                  colorScheme,
                  textTheme,
                ),
              ),
              SizedBox(height: height * 0.03),
              GestureDetector(
                onTap: (){
                  context.push('/voucher-screen');
                },
                child: _buildSectionTitle(
                  "Buy For Home",
                  "Perfect for your home brewing",
                  colorScheme,
                  textTheme,
                ),
              ),
              SizedBox(height: height * 0.02),
              _buildHorizontalScrollSection(
                context,
                height,
                width,
                "home",
                colorScheme,
                textTheme,
              ),
              SizedBox(height: height * 0.03),
              _buildSectionTitle(
                "Seasonal Specials",
                "Limited time offerings",
                colorScheme,
                textTheme,
              ),
              SizedBox(height: height * 0.02),
              _buildHorizontalScrollSection(
                context,
                height,
                width,
                "seasonal",
                colorScheme,
                textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    double height,
    double width,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      height: height * 0.6,
      child: Center(
        child: Lottie.asset('Assets/Icons/coffee-break.json',
        height: 200,
        width: 150
        ),
      ),
    );
  }

  Widget _buildErrorState(
    Object error,
    double height,
    double width,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    return SizedBox(
      height: height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            SizedBox(height: 16),
            Text(
              'Error loading menu: $error',
              style: TextStyle(color: colorScheme.error, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(menuCategoriesProvider),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Build section title with subtitle
  Widget _buildSectionTitle(
    String title,
    String subtitle,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              color: colorscheme.primaryContainer,
              // fontWeight: FontWeight.w400,
              // fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorscheme.secondary,
              fontWeight: FontWeight.w400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Build category grid
  Widget _buildCategoryGrid(
    double height,
    double width,
    Map<String, List<Map<String, dynamic>>> menuCategories,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    // Filter out empty categories to avoid errors
    final nonEmptyCategories = menuCategories.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: colorscheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1, top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Categories",
              style: texttheme.labelMedium?.copyWith(
                color: colorscheme.primaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: nonEmptyCategories.length,
              itemBuilder: (context, categoryIndex) {
                final categoryEntry = nonEmptyCategories[categoryIndex];
                final categoryName = categoryEntry.key;
                final categoryItems = categoryEntry.value;

                // Safe access to first item with fallback
                final firstItem = categoryItems.isNotEmpty
                    ? categoryItems.first
                    : {};
                final hasImage = firstItem['image'] != null;

                return InkWell(
                  onTap: () {
                    if (categoryItems.isNotEmpty) {
                      context.push('/menu/$categoryName', extra: categoryItems);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorscheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorscheme.shadow,
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: colorscheme.onPrimary,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: colorscheme.shadow),
                          ),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: hasImage
                                  ? SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Image.network(
                                        firstItem['image'] ?? Icon(Icons.coffee,color: colorscheme.secondaryFixed,),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, __) =>
                                            _buildFallbackIcon(
                                              categoryName,
                                              colorscheme,
                                            ),
                                      ),
                                    )
                                  : _buildFallbackIcon(
                                      categoryName,
                                      colorscheme,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 60,
                            maxHeight: 32,
                          ),
                          child: Text(
                            categoryName,
                            style: texttheme.bodySmall?.copyWith(
                              color: categoryItems.isNotEmpty
                                  ? colorscheme.primary
                                  : colorscheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build horizontal scroll section
  Widget _buildHorizontalScrollSection(
    BuildContext context,
    double height,
    double width,
    String type,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final isHomeSection = type == "home";
    final imagePath = isHomeSection
        ? "Assets/Images/coffee-powder.png"
        : "Assets/Images/cappucino.jpg";
    final title = isHomeSection ? 'Blich Berry' : 'Strawberry cream coffee';
    final description = isHomeSection
        ? 'You try this for your health'
        : 'Try this its new in our shop';

    return SizedBox(
      height: height * 0.36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(width: 8),
          _buildProductCard(
            context,
            height,
            width,
            imagePath,
            title,
            description,
            isHomeSection,
            colorscheme,
            texttheme,
            
          ),
          const SizedBox(width: 16),
          _buildProductCard(
             context,
            height,
            width,
            imagePath,
            title,
            description,
            isHomeSection,
            colorscheme,
            texttheme,
           
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Build product card
  Widget _buildProductCard(
    BuildContext context,
    double height,
    double width,
    String imagePath,
    String itemName,
    String itemDescription,
    bool isHomeSection,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 2),
      width: width * 0.7,
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
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.asset(
                  imagePath,
                  height: height * 0.2,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorscheme.onSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.star1,
                        size: 14,
                        color: colorscheme.onSecondaryFixed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "4.5",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorscheme.onSecondaryFixed,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isHomeSection)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorscheme.onPrimaryFixedVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Home Brew",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorscheme.onSecondaryFixed,
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorscheme.primary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  itemDescription,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorscheme.secondary,
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
                      "₹456",
                      style: textTheme.titleSmall?.copyWith(
                        color: colorscheme.onPrimaryFixedVariant,
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        context.push('/online-order');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorscheme.onPrimaryFixedVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Order Now",
                          style: textTheme.titleSmall?.copyWith(
                            color: colorscheme.onSecondaryFixed,
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

  Widget _buildFallbackIcon(String categoryName, ColorScheme colorscheme) {
    return Icon(
      _getIconForCategory(categoryName),
      size: 24,
      color: colorscheme.secondaryFixed,
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return Iconsax.coffee;
      case 'tea':
        return Iconsax.cup;
      case 'frozen':
        return Iconsax.cake;
      case 'cooler':
        return Iconsax.driver;
      default:
        return Iconsax.menu_board;
    }
  }
}

// Define a color palette for the app
