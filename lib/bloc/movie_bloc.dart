import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/movie_repository.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;

  MovieBloc({required this.movieRepository}) : super(MovieInitial()) {
    on<FetchMovies>(_onFetchMovies);
  }

  void _onFetchMovies(FetchMovies event, Emitter<MovieState> emit) async {
    emit(MovieLoading());
    try {
      final movies = await movieRepository.fetchMovies();
      emit(MovieLoaded(movies: movies));
    } catch (e) {
      emit(MovieError(message: e.toString()));
    }
  }
}