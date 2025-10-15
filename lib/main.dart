import 'package:flutter/material.dart';
import 'package:flutter_movie_app/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1922),
        primaryColor: Colors.cyan,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.tealAccent,
          surface: Color(0xFF0A1929),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flick',
      home: const SplashScreen(),
    );
  }
}