import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_finder/models/movie.dart';
import 'package:movie_finder/pages/account_page.dart';
import 'package:movie_finder/pages/movie_detail_page.dart';
import 'package:movie_finder/pages/search_page.dart';
import 'package:movie_finder/pages/view_all_page.dart';
import 'package:movie_finder/providers/favorites_provider.dart';
import 'package:movie_finder/services/api_service.dart';

class HomePage extends ConsumerStatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  late Future<List<Movie>> _trendingMoviesFuture;
  late Future<List<Movie>> _upcomingMoviesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _trendingMoviesFuture = _apiService.fetchPopularMovies();
    _upcomingMoviesFuture = _apiService.fetchUpcomingMovies();
  }

  void _navigateToDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movie: movie, userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const Center(child: Text('Halaman Bioskop')),
      const AccountPage(),
    ];

    return Scaffold(
      appBar: _selectedIndex != 2 ? _buildAppBar() : null,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: 'Bioskop'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: const Text('Movie Finder', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Cari Film',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage(userId: widget.userId)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset('assets/images/avatar.jpg', height: 180, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Coming Soon', onViewAll: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAllPage(title: 'Coming Soon', moviesFuture: _upcomingMoviesFuture, userId: widget.userId)));
        }),
        const SizedBox(height: 16),
        _buildApiHorizontalList(_upcomingMoviesFuture),
        const SizedBox(height: 24),
        _buildSectionHeader('Trending', onViewAll: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAllPage(title: 'Trending', moviesFuture: _trendingMoviesFuture, userId: widget.userId)));
        }),
        const SizedBox(height: 16),
        _buildApiHorizontalList(_trendingMoviesFuture),
        const SizedBox(height: 24),
        _buildFavoritesSection(),
      ],
    );
  }

  Widget _buildApiHorizontalList(Future<List<Movie>> futureMovies) {
    return FutureBuilder<List<Movie>>(
      future: futureMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return SizedBox(height: 250, child: Center(child: Text('Gagal memuat film.')));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildHorizontalMovieList(snapshot.data!);
        } else {
          return const SizedBox(height: 250, child: Center(child: Text('Tidak ada film ditemukan.')));
        }
      },
    );
  }

  Widget _buildHorizontalMovieList(List<Movie> moviesToShow) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moviesToShow.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final movie = moviesToShow[index];
          return GestureDetector(
            onTap: () => _navigateToDetail(movie),
            child: Container(
              margin: const EdgeInsets.only(right: 12.0),
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(movie.posterUrl, fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.movie, color: Colors.grey));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesSection() {
    final favoriteMoviesMap = ref.watch(favoritesProvider(widget.userId));
    if (favoriteMoviesMap.isEmpty) return const SizedBox.shrink();

    final favoriteMovieObjects = favoriteMoviesMap.map((movieMap) => Movie.fromDbMap(movieMap)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Favorit'),
        const SizedBox(height: 16),
        _buildHorizontalMovieList(favoriteMovieObjects),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text('View All')),
        ],
      ),
    );
  }
}