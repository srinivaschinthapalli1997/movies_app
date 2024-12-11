import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/movie_model.dart';

class MovieRepository {
  final String apiUrl = 'https://api.sampleapis.com/movies/animation';

  Future<List<Movie>> fetchMovies() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Movie> movies = body.map((dynamic item) => Movie.fromJson(item)).toList();
        return movies;
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}