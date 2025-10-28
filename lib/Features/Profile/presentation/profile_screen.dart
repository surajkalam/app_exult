
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../Authentication/Authentication.dart';
import '../../../Authentication/provider/current_user.dart';
import '../Profile.dart';
import 'widgets/coffee_glass_widget.dart';
import '../Provider/coffee_loyalty_provider.dart';

// List of available asset images
final List<String> assetImages = [
  "Assets/Icons/avtar2.png",
  "Assets/Icons/avtrars (3).png",
  "Assets/Icons/avtrars (4).png",
  "Assets/Icons/avtrars (6).png",
  "Assets/Icons/avtrars (7).png",
  "Assets/Icons/avtrars (8).png",
  "Assets/Icons/avtrars (9).png",
  "Assets/Icons/avtrars (11).png",
  "Assets/Icons/avtrars (14).png",
  "Assets/Icons/avtrars (12).png",
];

final selectedImageProvider = StateProvider<String>((ref) {
  return "Assets/Icons/avtar2.png"; // Default image
});


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final selectedImage = ref.watch(selectedImageProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentPoints = ref.watch(currentPointsProvider);

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: _buildAppBar(context, colorScheme, textTheme),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildSignUpPrompt(context, colorScheme, textTheme);
          } else {
            return _buildProfileContent(
              user,
              ref,
              context,
              selectedImage,
              colorScheme,
              textTheme,
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _buildSignUpPrompt(context, colorScheme, textTheme),
      ),
    );
  }

  // Build iOS-style app bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    colorscheme,
    textTheme,
  ) {
    return AppBar(
      backgroundColor: colorscheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Profile',
        style: textTheme.titleSmall?.copyWith(
          color: colorscheme.primaryContainer,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(BuildContext context, colorscheme, texttheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'Assets/Icons/404 error. oops page not found.json',
              height: 200,
              width: 280,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 16),
            Text(
              'Sign In to View Profile',
              style: texttheme.titleMedium?.copyWith(
                color: colorscheme.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Create an account or sign in to access your profile information',
              textAlign: TextAlign.center,
              style: texttheme.labelSmall?.copyWith(
                color: colorscheme.secondary,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/login-screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorscheme.onPrimaryFixedVariant,
                  foregroundColor: colorscheme.onSecondaryFixed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Login',
                  style: texttheme.bodyMedium?.copyWith(
                    color: colorscheme.onSecondaryFixed,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.go('/navbar'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colorscheme.onPrimaryFixedVariant),
                ),
                child: Text(
                  'Go To Home',
                  style: texttheme.bodyMedium?.copyWith(
                    color: colorscheme.onPrimaryFixedVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    User user,
    WidgetRef ref,
    BuildContext context,
    String selectedImage,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final String primaryContact =
        user.phoneNumber != null && user.phoneNumber!.isNotEmpty
        ? user.phoneNumber!
        : user.email ?? 'Unknown User';
    // final String email = user.email ?? 'Unknown User';
    final profile = ref.watch(profileProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final paymentsAsync = ref.watch(userPaymentsProvider);
    int? totalPoints;
    ref.watch(calculatedPointsProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(
            user,
            primaryContact,
            profile,
            selectedImage,
            height,
            width,
            context,
            ref,
            colorscheme,
            texttheme,
          ),
          SizedBox(height: 24),
          _buildAccountLevelSection(
            context,
            primaryContact,
            ref,
            profile,
            paymentsAsync,
            totalPoints,
            height,
            width,
            colorscheme,
            texttheme,
          ),
          SizedBox(height: 24),
          _buildAccountOptionsSection(
            height,
            width,
            context,
            ref,
            colorscheme,
            texttheme,
          ),
        ],
      ),
    );
  }

  // Build profile header section
  Widget _buildProfileHeader(
    User user,
    contact,
    profile,
    String selectedImage,
    double height,
    double width,
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    final String displayContact =
        user.phoneNumber != null && user.phoneNumber!.isNotEmpty
        ? user.phoneNumber! // Show phone number if available
        : user.email ?? 'Unknown User'; // Fall back to email

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorscheme.onPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorscheme.shadow,
                offset: Offset(4, 4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorscheme.onPrimary,
                    backgroundImage: AssetImage(selectedImage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImagePickerBottomSheet(
                        context,
                        ref,
                        colorscheme,
                        texttheme,
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorscheme.onPrimaryFixedVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorscheme.primaryContainer,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Iconsax.edit,
                          size: 20,
                          color: colorscheme.onSecondaryFixed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                user.displayName ?? user.email?.split('@').first ?? 'User',
                style: texttheme.titleMedium?.copyWith(
                  color: colorscheme.primaryContainer,
                ),
              ),
              SizedBox(height: 4),
              Text(
                displayContact,
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.secondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Member since ${profile.joinDate}",
                style: texttheme.bodySmall?.copyWith(
                  color: colorscheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build account level section
  Widget _buildAccountLevelSection(
    BuildContext context,
    contact,
    WidgetRef ref,
    profile,
    AsyncValue<List<Map<String, dynamic>>> paymentsAsync,
    int? totalPoints,
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
      final pointsAsync = ref.watch(calculatedPointsProvider);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorscheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/scratch-cart');
            },
            child: Text(
              "Account Level",
              style: texttheme.titleMedium?.copyWith(
                color: colorscheme.primaryContainer,
              ),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/level-screen'),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorscheme.tertiaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.medal,
                    size: 28,
                    color: colorscheme.secondaryFixed,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final levels = ref.watch(levelProvider);
                           final currentPoints = ref.watch(totalPointsProvider);
                          final currentLevel = ref
                              .read(levelProvider.notifier)
                              // .getCurrentLevel(totalPoints ?? 0);
                              .getCurrentLevel(currentPoints);

                          return Text(
                            currentLevel.name,
                            style: texttheme.labelLarge?.copyWith(
                              color: colorscheme.primaryContainer,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      paymentsAsync.when(
                        data: (data) {
                          int paymentPoints = data.length * 10;
                          totalPoints = profile.points + paymentPoints;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(levelProvider.notifier)
                                .updateLevels(totalPoints!);
                          });

                          return Consumer(
                            builder: (context, ref, child) {
                              final nextLevel = ref
                                  .read(levelProvider.notifier)
                                  .getNextLevel(totalPoints!);
                              final progress = ref
                                  .read(levelProvider.notifier)
                                  .getProgressPercentage(
                                    totalPoints!,
                                    nextLevel,
                                  );
                              final levels = ref.watch(levelProvider);
                              final unlockedLevels = levels
                                  .where((level) => level.isUnlocked)
                                  .length;
                              final totalLevels = levels.length;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: colorscheme.tertiaryFixed,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorscheme.onPrimaryFixedVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    minHeight: 8,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}% to ${nextLevel.name}',
                                    style: texttheme.bodySmall?.copyWith(
                                      color: colorscheme.secondary,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Text(
                                    "$unlockedLevels of $totalLevels levels unlocked",
                                    style: texttheme.labelMedium?.copyWith(
                                      color: colorscheme.primaryContainer,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        loading: () => CircularProgressIndicator(
                          strokeWidth: 1,
                          color: colorscheme.onPrimary,
                        ),
                        error: (error, stack) => Text(
                          'Error loading points',
                          style: texttheme.labelMedium?.copyWith(
                            color: colorscheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 20,
                  color: colorscheme.secondary,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Divider(height: 1, color: colorscheme.shadow),
          SizedBox(height: 16),
          Center(
            child: Consumer(
              builder: (context, ref, child) {
                // Get the latest total points value
                final paymentsData = ref.watch(userPaymentsProvider);
                return paymentsData.when(
                  data: (data) {
                    int paymentPoints = data.length * 10;
                    int currentTotalPoints = profile.points + paymentPoints;
                    // ref.read(currentPointsProvider.notifier).state =
                    //     currentTotalPoints;
                    Future.microtask(() {
                      ref.read(currentPointsProvider.notifier).state =
                          currentTotalPoints;
                    });
                    return Text(
                      "$currentTotalPoints points",
                      style: texttheme.titleMedium?.copyWith(
                        color: colorscheme.onPrimaryFixedVariant,
                      ),
                    );
                  },
                  loading: () => Text(
                    "Loading points...",
                    style: texttheme.titleMedium?.copyWith(
                      color: colorscheme.onPrimaryFixedVariant,
                    ),
                  ),
                  error: (error, stack) => Text(
                    "Error loading points",
                    style: texttheme.titleMedium?.copyWith(
                      color: colorscheme.error,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build account options section
  Widget _buildAccountOptionsSection(
    double height,
    double width,
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    // Load loyalty data
    ref.watch(loyaltyDataLoader);
    final loyaltyState = ref.watch(coffeeLoyaltyProvider);

    final options = [
      {
        'title': 'Favorite Items',
        'icon': Iconsax.heart,
        'onTap': () => context.push('/favorite'),
      },
      {
        'title': 'Vouchers',
        'icon': Iconsax.ticket,
        'onTap': () => context.push('/voucher-screen'),
      },
      {
        'title': 'Recent Orders',
        'icon': Iconsax.receipt,
        'onTap': () => context.push('/recent-order'),
      },
      {
        'title': 'Rewards',
        'icon': Iconsax.gift,
        'onTap': () => context.push('/reward'),
      },
      {
        'title': 'Billing Info',
        'icon': Iconsax.card,
        'onTap': () => context.push('/billing-info'),
      },
      {
        'title': 'Help & Support',
        'icon': Iconsax.message_question,
        'onTap': () => context.push('/help-support'),
      },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        'onTap': () => _showLogoutConfirmation(context, colorscheme, ref),
      },
    ];

    return Column(
      children: [
        // Coffee Loyalty Glass
        CoffeeGlassWidget(
          filledLayers: loyaltyState.filledLayers,
          height: height,
          width: width,
          onFreeCoffeeEarned: () async {
            final user = ref.read(currentUserProvider);
            await ref.read(coffeeLoyaltyProvider.notifier).claimFreeCoffee(user?.phoneNumber);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Free coffee claimed! Enjoy your reward!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
        ),
        SizedBox(height: 24),
        // Existing account options container
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorscheme.onPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorscheme.shadow,
                offset: Offset(4, 4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account",
                style: texttheme.titleMedium?.copyWith(
                  color: colorscheme.primaryContainer,
                ),
              ),
              SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: colorscheme.shadow),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      option['icon'] as IconData,
                      size: 24,
                      color: colorscheme.secondaryFixed,
                    ),
                    title: Text(
                      option['title'] as String,
                      style: texttheme.labelMedium?.copyWith(
                        color: colorscheme.primaryContainer,
                      ),
                    ),
                    trailing: Icon(
                      Iconsax.arrow_right_3,
                      size: 20,
                      color: colorscheme.secondary,
                    ),
                    onTap: option['onTap'] as VoidCallback?,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }


 Future<void> _showLogoutConfirmation(BuildContext context, ColorScheme colorscheme, WidgetRef ref) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                Icons.logout_rounded,
                size: 48,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              // Title
              Text(
                'Confirm Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // Message
              Text(
                'Are you sure you want to logout from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Logout Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // FIX: Use the correct method call
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logged out successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _showImagePickerBottomSheet(
    BuildContext context,
    WidgetRef ref,
    colorscheme,
    texttheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: colorscheme.onPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final selectedImage = ref.watch(selectedImageProvider);
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorscheme.onPrimary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choose Profile Image',
                          style: texttheme.titleMedium?.copyWith(
                            color: colorscheme.primaryContainer,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.close_circle,
                            color: colorscheme.primaryContainer,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: assetImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedImageProvider.notifier).state =
                                  assetImages[index];
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedImage == assetImages[index]
                                      ? colorscheme.onPrimaryFixedVariant
                                      : colorscheme.shadow,
                                  width: selectedImage == assetImages[index]
                                      ? 3
                                      : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  assetImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: colorscheme.onPrimary,
                                      child: Icon(
                                        Iconsax.gallery_slash,
                                        color: colorscheme.secondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  //   void _navigateToEditProfile(
  //     BuildContext context,
  //     WidgetRef ref,
  //     ColorScheme colorscheme,
  //     TextTheme texttheme,
  //   ) {
  //     showModalBottomSheet(
  //       context: context,
  //       backgroundColor: colorscheme.onPrimary,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //       ),
  //       builder: (context) {
  //         final profile = ref.read(profileProvider);
  //         TextEditingController nameController = TextEditingController(
  //           text: profile.name,
  //         );

  //         return Padding(
  //           padding: EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Edit Profile',
  //                 style: texttheme.titleMedium?.copyWith(
  //                   color: colorscheme.primaryContainer,
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               TextField(
  //                 controller: nameController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Name',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   prefixIcon: Icon(
  //                     Iconsax.user,
  //                     color: colorscheme.secondaryFixed,
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     ref
  //                         .read(profileProvider.notifier)
  //                         .updateName(nameController.text);
  //                     Navigator.pop(context);
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: colorscheme.onPrimaryFixedVariant,
  //                     foregroundColor: colorscheme.onSecondaryFixed,
  //                     padding: EdgeInsets.symmetric(vertical: 16),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Save Changes',
  //                     style: texttheme.labelLarge?.copyWith(
  //                       color: colorscheme.onSecondaryFixed,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(height: 16),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
}
