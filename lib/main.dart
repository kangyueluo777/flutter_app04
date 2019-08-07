import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


// Make a network request
Future<List<Photo>> fetchPhotos(http.Client client) async{
  final response =
    await client.get('https://jsonplaceholder.typicode.com/photos');

  //Use the compute function to run parsePhotos in seperate isolate.
  return parsePhotos(response.body);
}


// A function that convert a response body into a List<Photo>
List<Photo> parsePhotos(String responseBody){
  final parse = json.decode(responseBody).cast<Map<String,dynamic>>();

  return parse.map<Photo>((json) => Photo.fromJson(json)).toList();
}


class Photo{
  final int id;
  final String title;
  final String thumbnailUrl;

  Photo({this.id,this.title,this.thumbnailUrl});

  factory Photo.fromJson(Map<String,dynamic>json){
    return Photo(
      id:json['id']as int,
      title:json['title'] as String,
      thumbnailUrl: json['thumbnailUrl']as String,
    );
  }
}





void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Isolate Demo';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context,snapshot){
          if(snapshot.hasError)print(snapshot.error);

            return snapshot.hasData
                ? PhotosList(photos:snapshot.data)
                :Center(child: CircularProgressIndicator());
          },
      ),
    );
  }
}


class PhotosList extends StatelessWidget{

  final List<Photo> photos;

  PhotosList({Key key, this.photos}):super(key:key);

  @override
  Widget build(BuildContext context){
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2
        ),
        itemCount: photos.length,
        itemBuilder: (context,index){
          return Image.network(photos[index].thumbnailUrl);
        },
    );
  }

}


