import 'package:coffee_exult_app/Features/Profile/data/levelmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final levelProvider = StateNotifierProvider<LevelNotifier, List<Level>>((ref) {
  return LevelNotifier();
});

class LevelNotifier extends StateNotifier<List<Level>> {
  LevelNotifier()
      : super([
          Level(
            name: 'Bean Beginner',
            description: 'You\'re getting the taste for it! Discover new drinks and earn faster rewards.',
            imagePath: 'Assets/Icons/Pyro_Elemental_Dice_Icon-removebg-preview.png',
            pointsRequired: 0,
            isUnlocked: true,
          ),
          Level(
            name: 'Brew Explorer',
            description: 'You\'re getting the taste for it! Discover new drinks and earn faster rewards.',
            imagePath: 'Assets/Icons/Dendro_Elemental_Dice_Icon-removebg-preview.png',
            pointsRequired: 200,
            isUnlocked: false,
          ),
          Level(
            name: 'Latte Lover',
            description: 'You\'re getting the taste for it! Discover new drinks and earn faster rewards.',
            imagePath: 'Assets/Icons/Anemo_Elemental_Dice_Icon-removebg-preview.png',
            pointsRequired: 300,
            isUnlocked: false,
          ),
          Level(
            name: 'Cappuccino Lover',
            description: 'You\'re getting the taste for it! Discover new drinks and earn faster rewards.',
            imagePath: 'Assets/Icons/level4.png',
            pointsRequired: 600,
            isUnlocked: false,
          ),
          Level(
            name: 'Espresso Elite',
            description: 'You\'re getting the taste for it! Discover new drinks and earn faster rewards.',
            imagePath: 'Assets/Icons/BONUS_ICON-removebg-preview.png',
            pointsRequired: 1000,
            isUnlocked: false,
          ),
          Level(
            name: 'Master Roaster',
            description: 'You\'re getting the taste for it! Discover new drinks and earn faster rewards.',
            imagePath: 'Assets/Icons/Platinum_Rank__1_-removebg-preview.png',
            pointsRequired: 2000,
            isUnlocked: false,
          ),
        ]);

  void updateLevels(int totalPoints) {
    state = state.map((level) {
      return level.copyWith(isUnlocked: totalPoints >= level.pointsRequired);
    }).toList();
  }

  Level getCurrentLevel(int totalPoints) {
    // Get the highest unlocked level
    for (int i = state.length - 1; i >= 0; i--) {
      if (totalPoints >= state[i].pointsRequired) {
        return state[i];
      }
    }
    return state.first;
  }

  Level getNextLevel(int totalPoints) {
    // Get the next level to unlock
    for (final level in state) {
      if (totalPoints < level.pointsRequired) {
        return level;
      }
    }
    return state.last;
  }

  double getProgressPercentage(int totalPoints, Level nextLevel) {
    if (nextLevel.pointsRequired == 0) return 1.0;
    
    final currentLevelIndex = state.indexOf(getCurrentLevel(totalPoints));
    final nextLevelIndex = state.indexOf(nextLevel);
    
    if (currentLevelIndex == state.length - 1) return 1.0;
    
    final currentLevelPoints = state[currentLevelIndex].pointsRequired;
    final pointsForNextLevel = nextLevel.pointsRequired - currentLevelPoints;
    final pointsEarnedTowardsNext = totalPoints - currentLevelPoints;
    
    return (pointsEarnedTowardsNext / pointsForNextLevel).clamp(0.0, 1.0);
  }
}