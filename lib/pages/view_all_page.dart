// File: lib/pages/view_all_page.dart

import 'package:flutter/material.dart';
import 'package:movie_finder/models/movie.dart';
import 'package:movie_finder/pages/movie_detail_page.dart';

class ViewAllPage extends StatelessWidget {
  final String title;
  final Future<List<Movie>> moviesFuture;
  final int userId;

  const ViewAllPage({
    super.key,
    required this.title,
    required this.moviesFuture,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Movie>>(
        future: moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat film: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final movies = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              // Konfigurasi Grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 poster per baris
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.6, // Rasio lebar:tinggi poster
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman detail saat poster diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: movie, userId: userId),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                      // Tampilkan placeholder jika gambar gagal dimuat
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.movie, color: Colors.grey));
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Tidak ada film ditemukan.'));
          }
        },
      ),
    );
  }
}