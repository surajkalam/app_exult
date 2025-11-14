import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../Provider/Provider.dart';
import '../profile.dart';

class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final totalPoints = ref.watch(totalPointsProvider);
    final levels = ref.watch(levelProvider);

    // Update levels based on current points
    // ref.read(levelProvider.notifier).updateLevels(totalPoints);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(levelProvider.notifier).updateLevels(totalPoints);
      });
    });

    final currentLevel = ref
        .read(levelProvider.notifier)
        .getCurrentLevel(totalPoints);
    final nextLevel = ref
        .read(levelProvider.notifier)
        .getNextLevel(totalPoints);
    final progress = ref
        .read(levelProvider.notifier)
        .getProgressPercentage(totalPoints, nextLevel);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Calculate unlocked levels count
    final unlockedLevelsCount = levels
        .where((level) => level.isUnlocked)
        .length;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'Levels',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.02,
          horizontal: width * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressHeader(
              context,
              width,
              height,
              progress,
              nextLevel,
              unlockedLevelsCount,
              levels.length,
              colorScheme,
              textTheme,
            ),
            SizedBox(height: height * 0.03),
            Expanded(
              child: ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  final isCurrentLevel = level.name == currentLevel.name;

                  // Calculate progress for this specific level
                  double levelProgress = 0.0;
                  if (level.isUnlocked) {
                    levelProgress = 1.0;
                  } else if (index > 0) {
                    final previousLevel = levels[index - 1];
                    if (totalPoints > previousLevel.pointsRequired) {
                      final pointsRange =
                          level.pointsRequired - previousLevel.pointsRequired;
                      final pointsEarned =
                          totalPoints - previousLevel.pointsRequired;
                      levelProgress = (pointsEarned / pointsRange).clamp(
                        0.0,
                        1.0,
                      );
                    }
                  }

                  return _buildLevelCard(
                    context: context,
                    level: level,
                    isCurrentLevel: isCurrentLevel,
                    progress: levelProgress,
                    height: height,
                    width: width,
                    colorscheme: colorScheme,
                    texttheme: textTheme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    double width,
    double height,
    double progress,
    Level nextLevel,
    int unlockedCount,
    int totalLevels,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: colorscheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: texttheme.bodyLarge?.copyWith(
              color: colorscheme.primaryContainer,
              fontSize: 14,
            ),
          ),
          SizedBox(height: height * 0.015),
          SizedBox(
            width: width - 30,
            child: LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(10),
              minHeight: 12,
              valueColor: AlwaysStoppedAnimation<Color>(colorscheme.primary),
              backgroundColor: colorscheme.surface,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% to ${nextLevel.name}',
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.secondary,
              fontSize: 11,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            "$unlockedCount of $totalLevels levels unlocked",
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.secondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required Level level,
    required bool isCurrentLevel,
    required double progress,
    required double height,
    required double width,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.02),
      decoration: BoxDecoration(
        color: colorscheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentLevel
            ? Border.all(color: colorscheme.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Row(
          children: [
            // Level Image with Status Badge
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: width * 0.18,
                  height: width * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: level.isUnlocked
                        ? colorscheme.surface
                        : Colors.grey[200],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(level.imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
                if (level.isUnlocked)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorscheme.onSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: colorscheme.onSecondaryFixed,
                    ),
                  ),
              ],
            ),
            SizedBox(width: width * 0.04),

            // Level Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        level.name,
                        style: texttheme.labelMedium?.copyWith(
                          color: level.isUnlocked
                              ? colorscheme.primaryContainer
                              : colorscheme.secondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // if (isCurrentLevel)
                      //   Container(
                      //     margin: EdgeInsets.only(left: 8),
                      //     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //     decoration: BoxDecoration(
                      //       color: colorscheme.primary,
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Text(
                      //       "Current",
                      //       style: texttheme.labelSmall?.copyWith(
                      //         color: colorscheme.onPrimary,
                      //         fontSize: 8,
                      //       ),
                      //     ),
                      //   ),
                      Spacer(),
                      if (!level.isUnlocked)
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: colorscheme.secondary,
                        ),
                    ],
                  ),
                  SizedBox(height: height * 0.008),
                  Text(
                    level.description,
                    style: texttheme.bodySmall?.copyWith(
                      color: colorscheme.secondary,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height * 0.008),
                  Text(
                    "${level.pointsRequired} points required",
                    style: texttheme.bodySmall?.copyWith(
                      color: colorscheme.onPrimaryFixedVariant,
                      fontSize: 9,
                    ),
                  ),
                  SizedBox(height: height * 0.012),
                  if (!level.isUnlocked && progress > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Progress to unlock:",
                          style: texttheme.bodySmall?.copyWith(
                            color: colorscheme.onPrimaryFixedVariant,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: height * 0.006),
                        LinearProgressIndicator(
                          value: progress,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorscheme.onPrimaryFixedVariant,
                          ),
                          backgroundColor: colorscheme.surface,
                        ),
                        SizedBox(height: height * 0.004),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: texttheme.bodySmall?.copyWith(
                            color: colorscheme.onPrimaryFixedVariant,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Action Button
            if (level.isUnlocked)
              Column(
                children: [
                  if (isCurrentLevel)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorscheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Current",
                        style: texttheme.labelSmall?.copyWith(
                          color: colorscheme.onPrimary,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  SizedBox(height: height * 0.029),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _viewLevelBenefits(
                      context,
                      level,
                      colorscheme,
                      texttheme,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorscheme.onPrimaryFixedVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "View",
                        style: texttheme.labelMedium?.copyWith(
                          color: colorscheme.onSecondaryFixed,
                          fontSize: 10,
                        ),
                      ),
                    ), minimumSize: Size(0, 0),
                  ),
                ],
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorscheme.secondary,
              ),
          ],
        ),
      ),
    );
  }

  void _viewLevelBenefits(
    BuildContext context,
    Level level,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          "${level.name} Benefits",
          style: texttheme.bodyMedium?.copyWith(color: colorscheme.secondary),
        ),
        message: Text(
          _getLevelBenefits(level.name),
          style: texttheme.bodyMedium?.copyWith(
            color: colorscheme.secondary,
            fontSize: 12,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _shareAchievement(context, level.name, colorscheme, texttheme);
            },
            child: Text(
              "Share Achievement",
              style: texttheme.bodyMedium?.copyWith(
                color: colorscheme.primaryContainer,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: texttheme.bodyMedium?.copyWith(
                color: colorscheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelBenefits(String levelName) {
    switch (levelName) {
      case 'Bean Beginner':
        return "• 5% discount on all drinks\n• Free size upgrade once per week\n• Priority ordering\n• Exclusive beginner offers";
      case 'Brew Explorer':
        return "• 10% discount on all drinks\n• Free pastries with purchase\n• Early access to new drinks\n• Monthly free drink";
      case 'Latte Lover':
        return "• 15% discount on all drinks\n• Free customizations\n• VIP tasting events\n• Quarterly gift box";
      case 'Cappuccino Lover':
        return "• 20% discount on all drinks\n• Free merchandise\n• Barista training session\n• Annual coffee subscription";
      case 'Espresso Elite':
        return "• 25% discount on all drinks\n• Personal barista service\n• Exclusive events\n• Coffee farm tour";
      case 'Master Roaster':
        return "• 30% discount on all drinks\n• Lifetime membership\n• Coffee roasting experience\n• Global coffee tours";
      default:
        return "Enjoy exclusive benefits and rewards at this level!";
    }
  }

  void _shareAchievement(
    BuildContext context,
    String levelName,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Shared $levelName achievement!"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorscheme.onSecondary,
      ),
    );
  }
}
