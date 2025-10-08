import 'package:flutter/material.dart';
import 'package:flutter_movie_app/HomePage/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ), // // ThemeData
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomePage(),
    ); // // MaterialApp
  }
}