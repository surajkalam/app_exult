import 'package:coffee_shop/Features/Profile/Provider/fetchpaymentdata.dart';
import 'package:coffee_shop/Features/Profile/Provider/levelprovider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String name;
  final String joinDate;
  final int points;
  final String accountLevel;

  ProfileState({
    this.name = "Suraj",
    this.joinDate = "2025",
    this.points = 0,
    this.accountLevel = "Silver",
  });

  ProfileState copyWith({
    String? name,
    String? joinDate,
    int? points,
    String? accountLevel,
  }) {
    return ProfileState(
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
      points: points ?? this.points,
      accountLevel: accountLevel ?? this.accountLevel,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState());

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void updatePoints(int newPoints) {
    state = state.copyWith(points: newPoints);
  }

  void updateAccountLevel(String newLevel) {
    state = state.copyWith(accountLevel: newLevel);
  }
}
//
final currentPointsProvider = StateProvider<int>((ref) => 0);

// Provider to calculate and update the current points
final updateCurrentPointsProvider = FutureProvider<void>((ref) async {
  final profile = ref.read(profileProvider);
  final paymentsAsync = ref.read(userPaymentsProvider);
  
  paymentsAsync.when(
    data: (payments) {
      int paymentPoints = payments.length * 10;
      int totalPoints = profile.points + paymentPoints;

      ref.read(currentPointsProvider.notifier).state = totalPoints;
    },
    loading: () {},
    error: (error, stack) {},
  );
});






//

final totalPointsProvider = StateProvider<int>((ref) {
  return 0;
});

final calculatedPointsProvider = FutureProvider<int>((ref) async {
  final profile = ref.watch(profileProvider);
  final paymentsAsync = await ref.watch(userPaymentsProvider.future);
  
  final int paymentPoints = paymentsAsync.length * 10;
  final int totalPoints = profile.points + paymentPoints;
  
  // Update the total points state
  ref.read(totalPointsProvider.notifier).state = totalPoints;
  
  // Also update levels
  ref.read(levelProvider.notifier).updateLevels(totalPoints);
  
  return totalPoints;
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});