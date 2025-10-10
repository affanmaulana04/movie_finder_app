import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_finder/pages/home_page.dart';
import 'package:movie_finder/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');

  runApp(
    ProviderScope(
      child: MyApp(
        userId: userId,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int? userId;
  const MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.blue,
      ),
      home: userId != null ? HomePage(userId: userId!) : const LoginPage(),
    );
  }
}