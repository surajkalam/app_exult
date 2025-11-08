// ignore_for_file: deprecated_member_use
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/core.dart';
import '../profile.dart';
import '../../../Authentication/provider/current_user.dart';

class RewarsScreens extends ConsumerWidget {
  RewarsScreens({super.key});
  final user = FirebaseAuth.instance.currentUser;
  late final phoneNumber = user?.phoneNumber;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('user : $user');
    log("Welcome to rewards screen");
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentPoints = ref.watch(currentPointsProvider);
    log('current points: $currentPoints');
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'Reward',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileSection(
              height,
              width,
              colorScheme,
              textTheme,
              currentPoints,
            ),
            SizedBox(height: height * 0.03),
            _buildSectionTitle("How to Earn", colorScheme, textTheme),
            SizedBox(height: height * 0.02),
            _buildEarnRewardTile(
              context: context,
              title: "Orders",
              subtitle: "Earn 1 coin for every \$1 spent",
              iconPath: "Assets/Icons/shopping-bag_9002748.png",
              height: height,
              width: width,
              onTap: () {
                context.push('/navbar');
              },
              colorscheme: colorScheme,
              texttheme: textTheme,
            ),
            SizedBox(height: height * 0.02),
            _buildEarnRewardTile(
              context: context,
              title: "Refer a Friend",
              subtitle: "Earn 10 coins for every friend you refer",
              iconPath: "Assets/Icons/shopping-bag_9002748.png",
              height: height,
              width: width,
              colorscheme: colorScheme,
              texttheme: textTheme,
              onTap: () {
                context.push('/app-reference');
              },
            ),
            SizedBox(height: height * 0.03),
            _buildSectionTitle("Rewards", colorScheme, textTheme),
            SizedBox(height: height * 0.02),
            _buildRewardTile(
              context: context,
              title: "Free Coffee",
              subtitle: "Redeem 100 coins for free coffee",
              iconPath: "Assets/Icons/shopping-bag_9002748.png",
              height: height,
              width: width,
              requiredCoins: 100,
              colorscheme: colorScheme,
              texttheme: textTheme,
            ),
            SizedBox(height: height * 0.02),
            _buildRewardTile(
              context: context,
              title: "Free Pastry",
              subtitle: "Redeem 200 coins for free pastry",
              iconPath: "Assets/Icons/shopping-bag_9002748.png",
              height: height,
              width: width,
              requiredCoins: 200,
              colorscheme: colorScheme,
              texttheme: textTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme texttheme,
    int points,
  ) {
    return Center(
      child: Container(
        width: width * 0.9,
        padding: EdgeInsets.all(width * 0.06),
        decoration: BoxDecoration(
          color: colorscheme.onPrimary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorscheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorscheme.surface, width: 2),
              ),
              child: CircleAvatar(
                backgroundImage: const AssetImage("Assets/Icons/avtar2.png"),
                radius: width * 0.12,
                backgroundColor: colorscheme.onSecondaryFixed,
              ),
            ),
            SizedBox(height: height * 0.015),
            Text(
              "$phoneNumber",
              style: texttheme.bodyLarge?.copyWith(
                color: colorscheme.primaryContainer,
                fontSize: 14,
              ),
            ),
            SizedBox(height: height * 0.005),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorscheme.onPrimaryFixedVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorscheme.onPrimaryFixedVariant),
              ),
              child: Text(
                '$points Points',
                style: texttheme.bodyLarge?.copyWith(
                  color: colorscheme.onPrimaryFixedVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: texttheme.bodyMedium?.copyWith(
          color: colorscheme.primaryContainer,
          // fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEarnRewardTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String iconPath,
    required double height,
    required double width,
    VoidCallback? onTap,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: colorscheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorscheme.shadow.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: height * 0.06,
              width: width * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorscheme.surface,
              ),
              child: Center(
                child: Image(
                  image: AssetImage(iconPath),
                  height: height * 0.03,
                  width: width * 0.06,
                  color: colorscheme.secondaryFixed,
                ),
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: texttheme.bodyMedium?.copyWith(
                      color: colorscheme.primaryContainer,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    subtitle,
                    style: texttheme.bodyMedium?.copyWith(
                      color: colorscheme.secondary,
                      fontSize: 10,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorscheme.secondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String iconPath,
    required double height,
    required double width,
    required int requiredCoins,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final currentPoints = ref.watch(currentPointsProvider);
        final canClaim = currentPoints >= requiredCoins;

        return GestureDetector(
          onTap: () {
            if (canClaim) {
              _showClaimDialog(
                context,
                ref,
                title,
                requiredCoins,
                colorscheme,
                texttheme,
              );
            } else {
              _showRewardSnackbar(
                context,
                requiredCoins - currentPoints,
                colorscheme,
                texttheme,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: canClaim
                  ? colorscheme.primaryContainer.withValues(alpha: 0.1)
                  : colorscheme.onPrimary,
              borderRadius: BorderRadius.circular(16),
              border: canClaim
                  ? Border.all(color: colorscheme.primary, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: colorscheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: height * 0.06,
                  width: width * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: canClaim
                        ? colorscheme.primary.withValues(alpha: 0.2)
                        : colorscheme.onSecondary.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Image(
                      image: AssetImage(iconPath),
                      height: height * 0.03,
                      width: width * 0.06,
                      color: canClaim
                          ? colorscheme.primary
                          : colorscheme.onSecondary,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: texttheme.bodyMedium?.copyWith(
                          color: colorscheme.primaryContainer,
                          fontSize: 13,
                          fontWeight: canClaim
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        subtitle,
                        style: texttheme.bodyMedium?.copyWith(
                          color: colorscheme.secondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canClaim
                        ? Colors.green.withValues(alpha: 0.1)
                        : colorscheme.onSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: canClaim ? Border.all(color: Colors.green) : null,
                  ),
                  child: Text(
                    canClaim ? "Claim" : "$requiredCoins coins",
                    style: texttheme.bodyMedium?.copyWith(
                      color: canClaim
                          ? Colors.green[700]
                          : colorscheme.onSecondary,
                      fontSize: 10,
                      fontWeight: canClaim
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClaimDialog(
    BuildContext context,
    WidgetRef ref,
    String rewardTitle,
    int requiredCoins,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    showDialog(
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
                // Reward Icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_cafe,
                    size: 48,
                    color: Colors.green[600],
                  ),
                ),
                SizedBox(height: 16),
                // Title
                Text(
                  'Claim $rewardTitle',
                  style: texttheme.titleMedium?.copyWith(
                    color: colorscheme.primaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Message
                Text(
                  'Congratulations! You have enough points to claim your $rewardTitle.',
                  textAlign: TextAlign.center,
                  style: texttheme.bodyMedium?.copyWith(
                    color: colorscheme.secondary,
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
                          side: BorderSide(color: colorscheme.secondary),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: colorscheme.secondary),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Claim Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _claimReward(
                            context,
                            ref,
                            rewardTitle,
                            requiredCoins,
                            colorscheme,
                            texttheme,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Claim',
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

  void _claimReward(
    BuildContext context,
    WidgetRef ref,
    String rewardTitle,
    int requiredCoins,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) async {
    try {
      // Deduct points
      final currentPoints = ref.read(currentPointsProvider);
      final newPoints = currentPoints - requiredCoins;
      ref.read(currentPointsProvider.notifier).state = newPoints;

      // Update points in Firebase
      final user = ref.read(currentUserProvider);
      if (user?.phoneNumber != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.phoneNumber)
            .update({'points': newPoints});

        // Log the reward claim
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.phoneNumber!)
            .collection('claimedRewards')
            .add({
              'rewardTitle': rewardTitle,
              'pointsUsed': requiredCoins,
              'claimedAt': FieldValue.serverTimestamp(),
            });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('🎉 $rewardTitle claimed successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to coffee category if it's a coffee reward
      if (rewardTitle.toLowerCase().contains('coffee')) {
        Future.delayed(Duration(seconds: 1), () {
          context.push('/coffee-category');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim reward. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showRewardSnackbar(
    BuildContext context,
    int remainingCoins,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "You need $remainingCoins more coins to claim this reward",
          style: texttheme.labelMedium?.copyWith(
            color: colorscheme.onSecondaryFixed,
            fontSize: 11,
          ),
        ),
        backgroundColor: colorscheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
