import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:movie_finder/models/movie.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';

class MovieDetailPage extends ConsumerStatefulWidget {
  final Movie movie;
  final int userId;

  const MovieDetailPage({super.key, required this.movie, required this.userId});

  @override
  ConsumerState<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends ConsumerState<MovieDetailPage> {
  late Future<Map<String, dynamic>> _movieDetailsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _apiService.fetchMovieDetails(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    final movieAsMap = {
      'id': widget.movie.id,
      'title': widget.movie.title,
      'posterUrl': widget.movie.posterUrl,
      'synopsis': widget.movie.synopsis,
      'genre': widget.movie.genre,
      'actors': [],
    };

    final isFavorite = ref.watch(favoritesProvider(widget.userId))
        .any((favMovie) => favMovie['title'] == widget.movie.title);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2.0, color: Colors.black)]),
              ),
              background: Image.network(
                widget.movie.posterUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  final notifier = ref.read(favoritesProvider(widget.userId).notifier);
                  if (isFavorite) {
                    notifier.removeFavorite(movieAsMap);
                  } else {
                    notifier.addFavorite(movieAsMap);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, size: 24),
                onPressed: () {
                  Share.share('Hey, check out this movie: ${widget.movie.title}!\n\n${widget.movie.posterUrl}');
                },
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sinopsis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.synopsis.isEmpty ? 'Sinopsis tidak tersedia.' : widget.movie.synopsis,
                      style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    const Text('Pemeran', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    FutureBuilder<Map<String, dynamic>>(
                      future: _movieDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Gagal memuat daftar pemeran.'));
                        } else if (snapshot.hasData) {
                          final List<dynamic> actors = (snapshot.data!['credits']['cast'] as List<dynamic>).take(10).toList();
                          if (actors.isEmpty) return const Text('Data pemeran tidak tersedia.');

                          return SizedBox(
                            height: 200,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisSpacing: 12, childAspectRatio: 1.6),
                              itemCount: actors.length,
                              itemBuilder: (context, index) {
                                final actor = actors[index] as Map<String, dynamic>;
                                final profilePath = actor['profile_path'];
                                if (profilePath == null) return const SizedBox.shrink();

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network('https://image.tmdb.org/t/p/w200$profilePath', fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                          // KODE YANG DIPERBAIKI ADA DI SINI
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter, // <-- 'Center' ditambahkan
                                            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Text(
                                        actor['name']! as String,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                        // Tambahkan return ini untuk kasus lain
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}