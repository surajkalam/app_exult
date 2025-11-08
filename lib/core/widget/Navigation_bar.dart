// ignore: file_names
import 'package:coffee_exult_app/Features/Cart/presentation/cart_screen.dart';
import 'package:coffee_exult_app/Features/Event/presentation/event_book.dart';
import 'package:coffee_exult_app/Features/Home/presentation/home_screen.dart';
import 'package:coffee_exult_app/Features/Menu/presentation/menu_screen.dart';
import 'package:coffee_exult_app/Features/Profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

// Create a provider for the current index
final currentIndexProvider = StateProvider<int>((ref) => 0);

class MainAppere extends ConsumerWidget {
  const MainAppere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> screens = [
      const HomeScreen(),
      const MenuScreen(),
      const CartScreen(),
      const EventBookingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      extendBody: true,
      bottomNavigationBar: _buildFloatingBottomNavBar(
        context,
        ref,
        currentIndex,
        colorScheme,
      ),
    );
  }

  Widget _buildFloatingBottomNavBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 1),
      height: 75,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main navbar container
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  ref: ref,
                  index: 0,
                  icon: Iconsax.home_2,
                  activeIcon: Iconsax.home_25,
                  isActive: currentIndex == 0,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 1,
                  icon: Iconsax.shopping_bag,
                  activeIcon: Iconsax.discount_shape5,
                  isActive: currentIndex == 1,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 2,
                  icon: Icons.shopping_cart,
                  activeIcon: Iconsax.shopping_cart5,
                  isActive: currentIndex == 2,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 3,
                  icon: Iconsax.calendar,
                  activeIcon: Iconsax.calendar5,
                  isActive: currentIndex == 3,
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 4,
                  icon: Iconsax.profile_circle,
                  activeIcon: Iconsax.profile_circle5,
                  isActive: currentIndex == 4,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          // Elevated active icon
          _buildElevatedActiveIcon(currentIndex, colorScheme, ref),
        ],
      ),
    );
  }

  Widget _buildElevatedActiveIcon(
    int currentIndex,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    // Calculate position based on active index
    final double itemWidth =
        (MediaQuery.of(ref.context).size.width - 40) /
        5; // Screen width minus margins divided by items
    final double leftPosition =
        (currentIndex * itemWidth) +
        (itemWidth / 2) -
        28; // Center the 56px container

    final List<IconData> activeIcons = [
      Icons.home_filled,
      Icons.menu_book,
      Icons.shopping_cart,
      Icons.event,
      Iconsax.profile_circle5,
    ];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: leftPosition,
      top: -09,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme
                .onPrimaryFixedVariant, // Green color from your theme
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: colorScheme.shadow.withValues(alpha: 0.3),
                blurRadius: 1,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                // ignore: deprecated_member_use
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                activeIcons[currentIndex],
                key: ValueKey(currentIndex),
                color: colorScheme.onSecondaryFixed,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(currentIndexProvider.notifier).state = index;
      },
      child: SizedBox(
        width: 40,
        height: 55,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive
                ? 0.0
                : 1.0, // Hide the icon when it's active (shown in elevated container)
            child: Icon(icon, color: colorScheme.secondaryFixed, size: 20),
          ),
        ),
      ),
    );
  }
}
