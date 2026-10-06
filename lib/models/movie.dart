class Movie {
  Movie({
    required this.title,
    required this.genre,
    required this.year,
    this.inWatchlist = false,
    this.watched = false,
  });

  final String title;
  final String genre;
  final int year;
  bool inWatchlist;
  bool watched;
}
