// File: lib/models/movie.dart

class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String synopsis;
  final String genre; // Tambahkan properti genre

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.synopsis,
    required this.genre,
  });

  factory Movie.fromJson(Map<String, dynamic> json, List<dynamic> allGenres) {
    // Fungsi untuk mencari nama genre dari ID-nya
    String getGenreName(int genreId) {
      final genre = allGenres.firstWhere(
            (g) => g['id'] == genreId,
        orElse: () => {'name': 'Unknown'},
      );
      return genre['name'];
    }

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      posterUrl: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : '',
      synopsis: json['overview'] ?? 'No Synopsis',
      genre: (json['genre_ids'] as List).isNotEmpty
          ? getGenreName((json['genre_ids'] as List).first)
          : 'N/A',
    );
  }

  factory Movie.fromDbMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? 'No Title',
      posterUrl: map['posterUrl'] ?? '',
      synopsis: map['synopsis'] ?? '',
      genre: map['genre'] ?? 'N/A',
    );
  }
}