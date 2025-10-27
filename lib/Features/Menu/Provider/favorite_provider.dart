import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for Firebase Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for Firebase Auth instance
final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider for the current user's phone number (sanitized for Firestore)
final userPhoneProvider = Provider<String?>((ref) {
  final currentuser = ref.read(currentUserProvider);
  // return currentuser!.phoneNumber!.replaceAll('+', '').replaceAll(' ', '_');
  return currentuser!.phoneNumber;
});

// Main favorites provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<void>>((ref) {
      return FavoritesNotifier(
        firestore: ref.watch(firestoreProvider),
        getPhoneNumber: () => ref.read(userPhoneProvider),
      );
    });
class FavoritesNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore firestore;
  final String? Function() getPhoneNumber;


  FavoritesNotifier({required this.firestore, required this.getPhoneNumber})
    : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(Map<String, dynamic> itemData) async {
    state = const AsyncValue.loading();
    try {
      // Use the same method to get phone number consistently
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
        await favoritesRef.delete();
      } else {
        await favoritesRef.set({
          ...itemData,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> isFavorite(String itemName) async {
    try {
      final userPhoneNumber = getPhoneNumber();
      if (userPhoneNumber == null) return false;

      final doc = await firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('favorites')
          .doc(itemName)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}

// Favorites stream provider
// final favoritesStreamProvider =
//     StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
//       final firestore = ref.watch(firestoreProvider);

//       final usernumber = FirebaseAuth.instance.currentUser;
//       late final phoneNumber = usernumber?.phoneNumber;
//       if (phoneNumber == null) return Stream.value([]);
//       return firestore
//           .collection('users')
//           .doc(userPhoneNumber)
//           .collection('favorites')
//           .snapshots()
//           .map((snapshot) {
//             return snapshot.docs.map((doc) {
//               // Combine document ID with document data
//               final data = doc.data();
//               return {
//                 'id': doc.id, // This is the item name (document ID)
//                 ...data, // This contains all the item data
//               };
//             }).toList();
//           });
//     });
final favoritesStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final firestore = ref.watch(firestoreProvider);
      final userPhoneNumber = ref.watch(userPhoneProvider); // Use the provider

      if (userPhoneNumber == null) return Stream.value([]);

      return firestore
          .collection('users')
          .doc(userPhoneNumber) // Use the sanitized phone number
          .collection('favorites')
          .orderBy('addedAt', descending: true) // Optional: order by date
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id, // This is the item name (document ID)
                ...data, // This contains all the item data
              };
            }).toList();
          });
    });
// Cart provider (if you need one)
final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<void>>((
  ref,
) {
  return CartNotifier(
    firestore: ref.watch(firestoreProvider),
    getPhoneNumber: () => ref.read(userPhoneProvider),
  );
});

class CartNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore firestore;
  final String? Function() getPhoneNumber;

  CartNotifier({required this.firestore, required this.getPhoneNumber})
    : super(const AsyncValue.data(null));

  Future<void> addToCart(Map<String, dynamic> itemData) async {
    state = const AsyncValue.loading();
    try {
      final userPhoneNumber = getPhoneNumber();
      if (userPhoneNumber == null) throw Exception('User not logged in');

      final cartRef = firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('cart')
          .doc();

      await cartRef.set({...itemData, 'addedAt': FieldValue.serverTimestamp()});
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> removeFromCart(String itemId) async {
    state = const AsyncValue.loading();
    try {
      final userPhoneNumber = getPhoneNumber();
      if (userPhoneNumber == null) throw Exception('User not logged in');

      await firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('cart')
          .doc(itemId)
          .delete();

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Cart stream provider
final cartStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final userPhoneNumber = ref.watch(userPhoneProvider);
      final firestore = ref.watch(firestoreProvider);

      if (userPhoneNumber == null) return Stream.value([]);

      return firestore
          .collection('users')
          .doc(userPhoneNumber)
          .collection('cart')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => doc.data()..['id'] = doc.id)
                .toList(),
          );
    });
