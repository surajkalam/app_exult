// providers/search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return [];
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String searchTerm = searchQuery.toLowerCase();
  
  // Define your categories
  final List<String> categories = ['coffee', 'tea', 'frozen', 'snacks', 'dessert'];
  List<Map<String, dynamic>> results = [];

  try {
    // Search in each category
    for (final category in categories) {
      final QuerySnapshot categorySnapshot = await firestore
          .collection('items')
          .doc('1757264051191711')
          .collection(category)
          .get();

      for (final doc in categorySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String name = (data['name'] ?? '').toString().toLowerCase();
        final String itemCategory = (data['category'] ?? '').toString().toLowerCase();
        
        // Check if search term matches name OR category
        if (name.contains(searchTerm) || itemCategory.contains(searchTerm)) {
          data['id'] = doc.id;
          data['firebaseCategory'] = category; // Store the collection category
          results.add(data);
        }
      }
    }
    
    return results;
  } catch (e) {
    print('Search error: $e');
    return [];
  }
});
enum SearchState { idle, searching, results, noResults }

final searchStateProvider = StateProvider<SearchState>((ref) => SearchState.idle);