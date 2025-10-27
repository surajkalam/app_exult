import 'package:coffee_exult_app/Features/Menu/Provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteIcon extends ConsumerStatefulWidget {
  final Map<String, dynamic> itemData;

  const FavoriteIcon({super.key, required this.itemData});

  @override
  ConsumerState<FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends ConsumerState<FavoriteIcon> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    setState(() => _isLoading = true);
    try {
      final isFav = await ref
          .read(favoritesProvider.notifier)
          .isFavorite(widget.itemData['name']);
      setState(() => _isFavorite = isFav);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(favoritesProvider.notifier)
          .toggleFavorite(widget.itemData);
      setState(() => _isFavorite = !_isFavorite);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width;
    var height=MediaQuery.of(context).size.width;
    return _isLoading
        ? SizedBox(
            width: width*0.02,
            height:height*0.02,
            child: CircularProgressIndicator(
              strokeWidth: 0.1,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: width*0.068,
            ),
            onPressed: _toggleFavorite,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          );
  }
}
