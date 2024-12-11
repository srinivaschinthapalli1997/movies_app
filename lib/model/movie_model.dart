class Movie {
  final int id;
  final String title;
  final String posterURL;
  final String imdbId;

  Movie({
    required this.id,
    required this.title,
    required this.posterURL,
    required this.imdbId,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterURL: json['posterURL'],
      imdbId: json['imdbId'],
    );
  }
}