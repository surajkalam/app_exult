// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseCartService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String get _userPhone => _auth.currentUser?.phoneNumber ?? '';

//   // Future<List<Map<String, dynamic>>> getCartItems() async {
//   //   try {
//   //     if (_userPhone.isEmpty) {
//   //       throw Exception('User not logged in');
//   //     }

//   //     final snapshot = await _firestore
//   //         .collection('users')
//   //         .doc(_userPhone)
//   //         .collection('cart')
//   //         .orderBy('addedAt', descending: true)
//   //         .get();

//   //     return snapshot.docs.map((doc) {
//   //       final data = doc.data();
//   //       data['id'] = doc.id;
//   //       return data;
//   //     }).toList();
//   //   } catch (e) {
//   //     rethrow;
//   //   }
//   // }
//   Future<List<Map<String, dynamic>>> getCartItems() async {
//     try {
//       if (_userPhone.isEmpty) {
//         throw Exception('User not logged in');
//       }

//       final snapshot = await _firestore
//           .collection('users')
//           .doc(_userPhone)
//           .collection('cart')
//           .orderBy('addedAt', descending: true)
//           .get();

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;

//         // SANITIZE THE DATA - Ensure proper types
//         return _sanitizeCartItem(data);
//       }).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Map<String, dynamic> _sanitizeCartItem(Map<String, dynamic> item) {
//     final sanitized = Map<String, dynamic>.from(item);

//     // Ensure price is double
//     if (sanitized['price'] is String) {
//       sanitized['price'] = double.tryParse(sanitized['price']) ?? 0.0;
//     } else if (sanitized['price'] is int) {
//       sanitized['price'] = (sanitized['price'] as int).toDouble();
//     }

//     // Ensure quantity is int
//     if (sanitized['quantity'] is String) {
//       sanitized['quantity'] = int.tryParse(sanitized['quantity']) ?? 1;
//     } else if (sanitized['quantity'] is double) {
//       sanitized['quantity'] = (sanitized['quantity'] as double).toInt();
//     }

//     // Ensure rating is double
//     if (sanitized['rating'] is String) {
//       sanitized['rating'] = double.tryParse(sanitized['rating']) ?? 0.0;
//     } else if (sanitized['rating'] is int) {
//       sanitized['rating'] = (sanitized['rating'] as int).toDouble();
//     }

//     return sanitized;
//   }

//   Future<void> addToCart(Map<String, dynamic> itemData) async {
//     try {
//       if (_userPhone.isEmpty) {
//         throw Exception('User not logged in');
//       }

//       final itemName = itemData['name'];
//       await _firestore
//           .collection('users')
//           .doc(_userPhone)
//           .collection('cart')
//           .doc(itemName)
//           .set({
//             ...itemData,
//             'quantity': FieldValue.increment(1),
//             'addedAt': FieldValue.serverTimestamp(),
//           }, SetOptions(merge: true));
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> updateQuantity(String itemId, int newQuantity) async {
//     try {
//       if (_userPhone.isEmpty) {
//         throw Exception('User not logged in');
//       }

//       if (newQuantity <= 0) {
//         await removeItem(itemId);
//       } else {
//         await _firestore
//             .collection('users')
//             .doc(_userPhone)
//             .collection('cart')
//             .doc(itemId)
//             .update({'quantity': newQuantity});
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> removeItem(String itemId) async {
//     try {
//       if (_userPhone.isEmpty) {
//         throw Exception('User not logged in');
//       }

//       await _firestore
//           .collection('users')
//           .doc(_userPhone)
//           .collection('cart')
//           .doc(itemId)
//           .delete();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> clearCart() async {
//     try {
//       if (_userPhone.isEmpty) {
//         throw Exception('User not logged in');
//       }

//       final cartRef = _firestore
//           .collection('users')
//           .doc(_userPhone)
//           .collection('cart');

//       final snapshot = await cartRef.get();

//       for (var doc in snapshot.docs) {
//         await doc.reference.delete();
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseCartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userPhone => _auth.currentUser?.phoneNumber ?? '';

  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      if (_userPhone.isEmpty) {
        throw Exception('User not logged in');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(_userPhone)
          .collection('cart')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // SANITIZE THE DATA - Ensure proper types
        return _sanitizeCartItem(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCart(Map<String, dynamic> itemData) async {
    try {
      if (_userPhone.isEmpty) {
        throw Exception('User not logged in');
      }

      final itemName = itemData['name'];

      // SANITIZE THE DATA - Ensure price is stored as number
      final sanitizedData = _sanitizeCartItem(itemData);

      // Start with quantity 1
      sanitizedData['quantity'] = 1;

      await _firestore
          .collection('users')
          .doc(_userPhone)
          .collection('cart')
          .doc(itemName)
          .set({
            ...sanitizedData,
            'addedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      if (_userPhone.isEmpty) {
        throw Exception('User not logged in');
      }

      if (newQuantity <= 0) {
        await removeItem(itemId);
      } else {
        await _firestore
            .collection('users')
            .doc(_userPhone)
            .collection('cart')
            .doc(itemId)
            .update({'quantity': newQuantity});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      if (_userPhone.isEmpty) {
        throw Exception('User not logged in');
      }

      await _firestore
          .collection('users')
          .doc(_userPhone)
          .collection('cart')
          .doc(itemId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      if (_userPhone.isEmpty) {
        throw Exception('User not logged in');
      }

      final cartRef = _firestore
          .collection('users')
          .doc(_userPhone)
          .collection('cart');

      final snapshot = await cartRef.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to sanitize cart items and ensure correct data types
  Map<String, dynamic> _sanitizeCartItem(Map<String, dynamic> item) {
    final sanitized = Map<String, dynamic>.from(item);

    // Ensure price is double
    if (sanitized['price'] is String) {
      sanitized['price'] = double.tryParse(sanitized['price']) ?? 0.0;
    } else if (sanitized['price'] is int) {
      sanitized['price'] = (sanitized['price'] as int).toDouble();
    } else if (sanitized['price'] == null) {
      sanitized['price'] = 0.0;
    }

    // Ensure quantity is int
    if (sanitized['quantity'] is String) {
      sanitized['quantity'] = int.tryParse(sanitized['quantity']) ?? 1;
    } else if (sanitized['quantity'] is double) {
      sanitized['quantity'] = (sanitized['quantity'] as double).toInt();
    } else if (sanitized['quantity'] == null) {
      sanitized['quantity'] = 1;
    }

    // Ensure rating is double
    if (sanitized['rating'] is String) {
      sanitized['rating'] = double.tryParse(sanitized['rating']) ?? 0.0;
    } else if (sanitized['rating'] is int) {
      sanitized['rating'] = (sanitized['rating'] as int).toDouble();
    } else if (sanitized['rating'] == null) {
      sanitized['rating'] = 0.0;
    }

    return sanitized;
  }
}
