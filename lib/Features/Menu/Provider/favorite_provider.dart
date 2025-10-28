import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/core/provider/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Authentication/provider/current_user.dart';
// import '../../../core/provider/firebase_providers.dart';
// import '../../Auth/provider/auth_provider.dart';

// Provider for the current user's phone number
final userPhoneProvider = Provider<String?>((ref) {
  final currentuser = ref.read(currentUserProvider);
  return currentuser?.phoneNumber;
});

// Reactive favorites state provider
final favoritesStateProvider = StateNotifierProvider<FavoritesStateNotifier, Set<String>>((ref) {
  return FavoritesStateNotifier(
    firestore: ref.watch(firestoreProvider),
    getPhoneNumber: () => ref.read(userPhoneProvider),
  );
});

class FavoritesStateNotifier extends StateNotifier<Set<String>> {
  final FirebaseFirestore firestore;
  final String? Function() getPhoneNumber;

  FavoritesStateNotifier({
    required this.firestore,
    required this.getPhoneNumber,
  }) : super(<String>{}) {
    _loadFavorites();
  }

  // Load all favorites on initialization
  Future<void> _loadFavorites() async {
    try {
      final userPhoneNumber = getPhoneNumber();
      if (userPhoneNumber == null) return;

      final snapshot = await firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('favorites')
          .get();

      final favoriteNames = snapshot.docs.map((doc) => doc.id).toSet();
      state = favoriteNames;
    } catch (e) {
      // Handle error silently
    }
  }

  // Check if item is favorite
  bool isFavorite(String itemName) {
    return state.contains(itemName);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Map<String, dynamic> itemData) async {
    try {
      final userPhoneNumber = getPhoneNumber();
      if (userPhoneNumber == null) throw Exception('User not logged in');

      final itemName = itemData['name'];
      final favoritesRef = firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('favorites')
          .doc(itemName);

      final doc = await favoritesRef.get();

      if (doc.exists) {
        // Remove from favorites
        await favoritesRef.delete();
        state = {...state}..remove(itemName);
      } else {
        // Add to favorites
        await favoritesRef.set({
          ...itemData,
          'addedAt': FieldValue.serverTimestamp(),
        });
        state = {...state, itemName};
      }
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  // Remove specific favorite
  Future<void> removeFavorite(String itemName) async {
    try {
      final userPhoneNumber = getPhoneNumber();
      if (userPhoneNumber == null) return;

      await firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('favorites')
          .doc(itemName)
          .delete();

      state = {...state}..remove(itemName);
    } catch (e) {
      // Handle error
    }
  }

  // Refresh favorites from server
  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }
}

// Main favorites provider (for backward compatibility)
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<void>>((ref) {
  return FavoritesNotifier(
    firestore: ref.watch(firestoreProvider),
    getPhoneNumber: () => ref.read(userPhoneProvider),
    favoritesState: ref.read(favoritesStateProvider.notifier),
  );
});

class FavoritesNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore firestore;
  final String? Function() getPhoneNumber;
  final FavoritesStateNotifier favoritesState;

  FavoritesNotifier({
    required this.firestore,
    required this.getPhoneNumber,
    required this.favoritesState,
  }) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(Map<String, dynamic> itemData) async {
    state = const AsyncValue.loading();
    try {
      await favoritesState.toggleFavorite(itemData);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> isFavorite(String itemName) async {
    return favoritesState.isFavorite(itemName);
  }
}

// Favorites stream provider (updated to use reactive state)
final favoritesStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userPhoneNumber = ref.watch(userPhoneProvider);

  if (userPhoneNumber == null) return Stream.value([]);

  return firestore
      .collection('users')
      .doc(userPhoneNumber)
      .collection('favorites')
      .orderBy('addedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        // Update the reactive state when stream changes
        final favoriteNames = snapshot.docs.map((doc) => doc.id).toSet();
        ref.read(favoritesStateProvider.notifier).state = favoriteNames;
        
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
});

// Individual item favorite status provider
final itemFavoriteStatusProvider = Provider.family<bool, String>((ref, itemName) {
  final favorites = ref.watch(favoritesStateProvider);
  return favorites.contains(itemName);
});
