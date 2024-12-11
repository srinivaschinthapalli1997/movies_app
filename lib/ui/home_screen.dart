import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../bloc/movie_bloc.dart';
import '../bloc/movie_state.dart';
import '../model/movie_model.dart';
import 'movie_details_screen.dart';



class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<Movie>> _filteredMovies = ValueNotifier([]);
  final ValueNotifier<Set<Movie>> _favoriteMovies = ValueNotifier({});
  int _selectedTabIndex = 0; // Track the selected tab index

  @override
  void dispose() {
    _searchController.dispose();
    _filteredMovies.dispose();
    _favoriteMovies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTabIndex == 0 ? 'Animated Movies' : 'Favorites'),
        centerTitle: true,
      ),
      body: _selectedTabIndex == 0 ? _buildHomeTab() : _buildFavoritesTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search movies...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterMovies, // Trigger filtering
          ),
        ),
        // Movie List
        Expanded(
          child: BlocBuilder<MovieBloc, MovieState>(
            builder: (context, state) {
              if (state is MovieInitial || state is MovieLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MovieError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is MovieLoaded) {
                if (_filteredMovies.value.isEmpty && _searchController.text.isEmpty) {
                  _filteredMovies.value = state.movies;
                }
                return ValueListenableBuilder<List<Movie>>(
                  valueListenable: _filteredMovies,
                  builder: (context, filteredMovies, child) {
                    return _buildMovieList(filteredMovies);
                  },
                );
              }
              return const Center(child: Text('Something went wrong'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return ValueListenableBuilder<Set<Movie>>(
      valueListenable: _favoriteMovies,
      builder: (context, favoriteMovies, child) {
        if (favoriteMovies.isEmpty) {
          return const Center(child: Text('No favorite movies'));
        }
        return ListView.builder(
          itemCount: favoriteMovies.length,
          itemBuilder: (context, index) {
            final movie = favoriteMovies.elementAt(index);
            final isFavorite = _favoriteMovies.value.contains(movie);
            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterURL,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(movie),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _filterMovies(String query) {
    final currentState = context.read<MovieBloc>().state;
    if (currentState is MovieLoaded) {
      final movies = currentState.movies;
      if (query.isEmpty) {
        _filteredMovies.value = movies;
      } else {
        _filteredMovies.value = movies
            .where((movie) => movie.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }
  }

  Widget _buildMovieList(List<Movie> movies) {
    if (movies.isEmpty) {
      return const Center(child: Text('No movies found'));
    }
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final isFavorite = _favoriteMovies.value.contains(movie);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: movie),
              ),
            );
          },
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterURL,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(movie),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(Movie movie) {
    final currentFavorites = _favoriteMovies.value;
    if (currentFavorites.contains(movie)) {
      currentFavorites.remove(movie);
    } else {
      currentFavorites.add(movie);
    }
    _favoriteMovies.value = {...currentFavorites}; // Trigger rebuild
  }
}
