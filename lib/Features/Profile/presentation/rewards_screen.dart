// ignore_for_file: deprecated_member_use
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../profile.dart';

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
            _buildUserProfileSection(height, width, colorScheme, textTheme,currentPoints),
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
              onTap: (){
                 context.push('/app-reference');
              }
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
              color: colorscheme.shadow.withOpacity(0.05),
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
                color: colorscheme.onPrimaryFixedVariant.withOpacity(0.1),
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
              color: colorscheme.shadow.withOpacity(0.05),
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
    return GestureDetector(
      onTap: () {
        _showRewardSnackbar(context, requiredCoins, colorscheme, texttheme);
      },
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: colorscheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorscheme.shadow.withOpacity(0.05),
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
                color: colorscheme.onSecondary.withOpacity(0.2),
              ),
              child: Center(
                child: Image(
                  image: AssetImage(iconPath),
                  height: height * 0.03,
                  width: width * 0.06,
                  color: colorscheme.onSecondary,
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
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorscheme.onSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$requiredCoins coins",
                style: texttheme.bodyMedium?.copyWith(
                  color: colorscheme.onSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardSnackbar(
    BuildContext context,
    int requiredCoins,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Complete $requiredCoins coins to apply",
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
