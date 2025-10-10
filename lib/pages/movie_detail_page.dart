import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/favorites_provider.dart';

class MovieDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> movie;
  // DIUBAH: Menambahkan userId sebagai parameter wajib
  final int userId;

  const MovieDetailPage({super.key, required this.movie, required this.userId});

  @override
  ConsumerState<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends ConsumerState<MovieDetailPage> {

  void _showShareDialog() {
    Share.share('Hey, check out this movie: ${widget.movie['title']}!\n\nSynopsis: ${widget.movie['synopsis']}');
  }

  @override
  Widget build(BuildContext context) {
    // DIUBAH: Menggunakan widget.userId, bukan widget.movie['userId']
    final isFavorite = ref.watch(favoritesProvider(widget.userId))
        .any((favMovie) => favMovie['title'] == widget.movie['title']);


    final List<dynamic> actors = widget.movie['actors'] as List<dynamic>? ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie['title']! as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                widget.movie['posterUrl']! as String,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  // DIUBAH: Menggunakan widget.userId
                  final notifier = ref.read(favoritesProvider(widget.userId).notifier);
                  if (isFavorite) {
                    notifier.removeFavorite(widget.movie);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dihapus dari favorit.'), duration: Duration(seconds: 1)),
                    );
                  } else {
                    notifier.addFavorite(widget.movie);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ditambahkan ke favorit.')),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _showShareDialog,
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sinopsis',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (widget.movie['synopsis'] ?? 'Sinopsis tidak tersedia.') as String,
                          style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        if (actors.isNotEmpty) ...[
                          const Text(
                            'Pemeran',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 200,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.6,
                              ),
                              itemCount: actors.length,
                              itemBuilder: (context, index) {
                                final actor = actors[index] as Map<String, dynamic>;
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        actor['photoUrl']! as String,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ]
            ),
          ),
        ],
      ),
    );
  }
}