import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_finder/pages/login_page.dart';
import '../providers/favorites_provider.dart';
import 'account_page.dart';
import 'movie_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<String> _genres = ['All', 'Action', 'Comedy', 'Drama', 'Sci-Fi'];
  String _selectedGenre = 'All';

  final List<Map<String, dynamic>> _allMovies = [
    {
      'title': 'Game of Thrones',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
      'synopsis': 'Di benua mitos Westeros, beberapa keluarga bangsawan yang kuat berjuang untuk menguasai Tujuh Kerajaan.',
      'genre': 'Drama',
      'actors': [
        {'name': 'Emilia Clarke', 'photoUrl': 'https://image.tmdb.org/t/p/w200/r6i4n111kifwS43pMfbUe7i1r2I.jpg'},
        {'name': 'Kit Harington', 'photoUrl': 'https://image.tmdb.org/t/p/w200/1G5I3Jv3n0DoT33a1sQfH00a45T.jpg'},
        {'name': 'Peter Dinklage', 'photoUrl': 'https://image.tmdb.org/t/p/w200/aVHP433iAMzuKqco39b41E9a30o.jpg'},
      ]
    },
    {
      'title': 'Godzilla',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/2W0Yw0qrgVMgdsSCZRKtfvaAh0i.jpg',
      'synopsis': 'Kisah monster raksasa legendaris dari Jepang yang muncul kembali untuk mengancam umat manusia.',
      'genre': 'Action',
      'actors': [
        {'name': 'Aaron Taylor-Johnson', 'photoUrl': 'https://image.tmdb.org/t/p/w200/3oWEuQ0s4MkeB3bBvg2rUec6e17.jpg'},
        {'name': 'Elizabeth Olsen', 'photoUrl': 'https://image.tmdb.org/t/p/w200/6J3Gg1ohh8SVS2A8l2z7p3aXGj.jpg'},
        {'name': 'Bryan Cranston', 'photoUrl': 'https://image.tmdb.org/t/p/w200/fngCqy22G2PS2s0k922n5vjNFyk.jpg'},
      ]
    },
    {
      'title': 'Kung Fu Panda 4',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/kDp1vUBnMpe8ak4rjgl3cLELqjU.jpg',
      'synopsis': 'Po, yang akan menjadi Pemimpin Spiritual, mencari penggantinya sebagai Prajurit Naga sambil melawan penjahat baru.',
      'genre': 'Comedy',
      'actors': [
        {'name': 'Jack Black', 'photoUrl': 'https://image.tmdb.org/t/p/w200/rtKvpT4IOKd3B6XGIt8OLk2Vspa.jpg'},
        {'name': 'Awkwafina', 'photoUrl': 'https://image.tmdb.org/t/p/w200/wQic42rBtbuqsGl6mLE3b6MMf3d.jpg'},
        {'name': 'Viola Davis', 'photoUrl': 'https://image.tmdb.org/t/p/w200/4d55n72dcr2n3d2h7i3gU5dB92l.jpg'},
      ]
    },
    {
      'title': 'Spider-Man: Across the Spider-Verse',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      'synopsis': 'Miles Morales melintasi Multiverse, di mana ia bertemu dengan tim Spider-People yang bertugas melindungi keberadaannya.',
      'genre': 'Action',
      'actors': [
        {'name': 'Shameik Moore', 'photoUrl': 'https://image.tmdb.org/t/p/w200/6Pa3f9tKffL552jV4s423R3b3dC.jpg'},
        {'name': 'Hailee Steinfeld', 'photoUrl': 'https://image.tmdb.org/t/p/w200/1gW4rCw22jZ8Txeon5vA4rAOTMu.jpg'},
        {'name': 'Oscar Isaac', 'photoUrl': 'https://image.tmdb.org/t/p/w200/cVQ32W41k1PS6mY2IIaIeGk63e.jpg'},
      ]
    },
    {
      'title': 'Oppenheimer',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      'synopsis': 'Kisah fisikawan teoretis J. Robert Oppenheimer, yang karyanya di Proyek Manhattan melahirkan bom atom pertama.',
      'genre': 'Drama',
      'actors': [
        {'name': 'Cillian Murphy', 'photoUrl': 'https://image.tmdb.org/t/p/w200/2i2yZl2n2G3i7L1RmW22D9eT5sE.jpg'},
        {'name': 'Emily Blunt', 'photoUrl': 'https://image.tmdb.org/t/p/w200/jI42t5VQl42a2kId3G0A0c23Jls.jpg'},
        {'name': 'Matt Damon', 'photoUrl': 'https://image.tmdb.org/t/p/w200/7rwSXluNWZAluYMOEWBOUcFjnbg.jpg'},
      ]
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = _allMovies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() { _isSearching = true; });
    await Future.delayed(const Duration(seconds: 1));
    List<Map<String, dynamic>> results = [];
    if (query.isEmpty) {
      results = _allMovies;
    } else {
      results = _allMovies
          .where((movie) =>
          (movie['title'] as String).toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      _searchResults = results;
      _isSearching = false;
      _selectedGenre = 'All';
    });
  }

  void _navigateToDetail(Map<String, dynamic> movie) {
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
          if (index == 0) {
            _searchController.clear();
            _performSearch('');
            FocusScope.of(context).unfocus();
          }
        },
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: 'Cinema'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: TextField(
        controller: _searchController,
        onSubmitted: (query) => _performSearch(query),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildHomeContent() {
    final bool isSearchActive = _searchController.text.isNotEmpty;
    final String sectionTitle = isSearchActive ? 'Hasil Pencarian' : 'Trending';

    final List<Map<String, dynamic>> filteredMovies;
    if (_selectedGenre == 'All') {
      filteredMovies = _searchResults;
    } else {
      filteredMovies = _searchResults.where((movie) => movie['genre'] == _selectedGenre).toList();
    }

    return ListView(
      children: [
        if (!isSearchActive) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Coming Soon'),
          const SizedBox(height: 16),
          _buildPromoCarousel(),
          const SizedBox(height: 24),
        ],
        _buildSectionHeader(sectionTitle),
        const SizedBox(height: 16),
        _buildGenreChips(),
        const SizedBox(height: 16),
        _buildHorizontalMovieList(filteredMovies),
        const SizedBox(height: 24),
        if (!isSearchActive) _buildFavoritesSection(),
      ],
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          return ChoiceChip(
            label: Text(genre),
            selected: _selectedGenre == genre,
            onSelected: (isSelected) {
              if (isSelected) {
                setState(() { _selectedGenre = genre; });
              }
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<Map<String, dynamic>> moviesToShow) {
    return SizedBox(
      height: 250,
      child: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : moviesToShow.isEmpty
          ? const Center(child: Text('Film tidak ditemukan.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
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
                      child: Image.network(movie['posterUrl']! as String, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie['title']! as String,
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
    final favoriteMovies = ref.watch(favoritesProvider(widget.userId));
    if (favoriteMovies.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Favorit'),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteMovies.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
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
                          child: Image.network(movie['posterUrl']! as String, fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie['title']! as String,
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
        ),
      ],
    );
  }

  Widget _buildPromoCarousel() {
    final List<String> promoImageAssets = [
      'assets/images/avatar.jpg', // Sesuaikan dengan nama file gambar Anda
    ];
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: promoImageAssets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(promoImageAssets[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text('Coming Soon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          TextButton(onPressed: () {}, child: const Text('View All')),
        ],
      ),
    );
  }
}