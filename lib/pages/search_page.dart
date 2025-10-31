// File: lib/pages/search_page.dart

import 'package:flutter/material.dart';
import 'package:movie_finder/models/movie.dart';
import 'package:movie_finder/pages/movie_detail_page.dart';
import 'package:movie_finder/services/api_service.dart';

class SearchPage extends StatefulWidget {
  final int userId;
  const SearchPage({super.key, required this.userId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Movie> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false; // Untuk tahu apakah user sudah pernah mencari

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _apiService.searchMovies(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle error jika ada
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar berisi TextField untuk pencarian
        title: TextField(
          controller: _searchController,
          autofocus: true, // Keyboard langsung muncul saat halaman dibuka
          onSubmitted: _performSearch,
          decoration: const InputDecoration(
            hintText: 'Cari judul film...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Text('Cari film berdasarkan judul.', style: TextStyle(color: Colors.grey)),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Film tidak ditemukan.', style: TextStyle(color: Colors.grey)),
      );
    }

    // Tampilkan hasil dalam ListView
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return ListTile(
          leading: movie.posterUrl.isNotEmpty
              ? Image.network(movie.posterUrl, width: 50, fit: BoxFit.cover)
              : null,
          title: Text(movie.title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(movie: movie, userId: widget.userId),
              ),
            );
          },
        );
      },
    );
  }
}