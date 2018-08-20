import 'package:flutter/material.dart';
// Import movie model to be used here
import 'package:moovie/model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import'package:moovie/auth/keys.dart';

//import 'dart:async' show Future;
//converting data from json
import 'dart:convert';


//var secret;
//void getkey(){
//  Future<Secret> secret = SecretLoader(secretPath: "secrets.json").load();
//  print(secret);
//}


// ADD API Key HERE 
const key = '';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Moovy',
      theme: new ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}


class HomeState extends State<HomePage> {
  List<Movie>movies = List();
  bool hasLoaded = true;

  // returns an observable object rather than a string
  final PublishSubject subject = PublishSubject<String>();


  @override
  void dispose() {
    // TODO: implement dispose--close the widget after we are done.
    subject.close();
    super.dispose();
  }

  // Add search movie function
  void searchMovies(query){
    // reset every single time we go for querying
    resetMovies();
    // check query if empty
    if(query.isEmpty){
      //if empty
      setState((){
        hasLoaded = true;
          });
    }
    setState(()=> hasLoaded = false);
        http.get('https://api.themoviedb.org/3/search/movie?api_key=$key&query=$query')
        //pull out or response
        .then((res)=> (res.body))
        .then(json.decode)
        .then((map)=> map["results"])
        .then((movies)=> movies.forEach(addMovie))
        .catchError(onError)
        .then((e) {
          setState((){
            hasLoaded = true;

        });
        });

  }

  void onError(dynamic d) {
    setState(() {
      hasLoaded = true;
    });
  }
  void addMovie(item){
    setState((){
      movies.add(Movie.fromJson(item));
    });
    print('${movies.map((m)=> m.title)}');
  }

  void resetMovies(){
    setState(()=> movies.clear());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //debounce helps us create an observable that has some latency on when it can send data through the stream
    //deboounce method helps us to specify the time lag when the user makes a call to the api and when the data shows up in the view
    subject.stream.debounce(Duration(milliseconds:400)).listen(searchMovies);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Searcher')
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          TextField(
            onChanged: (String string) => (subject.add(string)),
          ),
          hasLoaded ? Container(): CircularProgressIndicator(),
          Expanded(child: ListView.builder(
            padding:EdgeInsets.all(10.0),
            itemCount: movies.length,
            itemBuilder: (BuildContext context,int index){
              return new MovieView(movies[index]);
            },
          ),)
        ],
        )
      )     
    );
  }


}

class MovieView extends StatefulWidget {
  MovieView(this.movie);
  final Movie movie;

  @override
  MovieViewState createState()=> MovieViewState();

}
class MovieViewState extends State<MovieView>{
  Movie movieState;
  
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    movieState = widget.movie;
  }


  //Return a card
  @override
  Widget build(BuildContext context){
    return Card(
      child: Container(
        height:200.0,
        padding: EdgeInsets.all(10.0),
        child:Row(
          children: <Widget>[
             movieState.posterPath != null
              ? Hero(
               child: Image.network(
                 "https://image.tmdb.org/t/p/w92${movieState.posterPath}"
               ),
               tag: movieState.id,
             )
                 : Container(),
          ]
        )
      )
    );
  }
}

