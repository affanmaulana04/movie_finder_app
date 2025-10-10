import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/database_helper.dart';

class FavoritesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final int userId;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  FavoritesNotifier(this.userId) : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoritesData = await _dbHelper.getFavorites(userId);
    state = favoritesData.map((movie) {
      final actorsString = movie['actors'] as String?;
      return {
        'title': movie['title'] as String,
        'posterUrl': movie['posterUrl'] as String,
        'synopsis': movie['synopsis'] as String,
        'genre': movie['genre'] as String?,
        'actors': actorsString != null ? json.decode(actorsString) : [],
      };
    }).toList();
  }

  bool isFavorite(Map<String, dynamic> movie) {
    return state.any((favMovie) => favMovie['title'] == movie['title']);
  }

  Future<void> addFavorite(Map<String, dynamic> movie) async {
    final movieDataToSave = {
      'userId': userId,
      'title': movie['title'] as String,
      'posterUrl': movie['posterUrl'] as String,
      'synopsis': movie['synopsis'] as String,
      'genre': movie['genre'] as String?,
      'actors': json.encode(movie['actors']),
    };
    await _dbHelper.addFavorite(movieDataToSave);
    // Refresh state dari database untuk memastikan konsistensi
    _loadFavorites();
  }

  Future<void> removeFavorite(Map<String, dynamic> movie) async {
    await _dbHelper.removeFavorite(userId, movie['title']! as String);
    // Refresh state dari database
    _loadFavorites();
  }
}

final favoritesProvider =
StateNotifierProvider.family<FavoritesNotifier, List<Map<String, dynamic>>, int>((ref, userId) {
  return FavoritesNotifier(userId);
});