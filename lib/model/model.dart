//Access to some meta programming keywords we want to use
import 'package:meta/meta.dart';

class Movie {
  Movie({
    // when adding braces helps us make values optional values try removing braces
    @required this.id,
    @required this.title,
    @required this.posterPath,
    @required this.overview,
    this.favored,
  });

  String id,title,posterPath,overview;
  bool favored;

  Movie.fromJson(Map json):
        title = json['title'],
        posterPath = json["poster_path"],
        //convert the  id which is integer to string
        id = json["id"].toString(),
        overview = json ["overview"],
        // add favored to be false by default
        favored = false;

}

