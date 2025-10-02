import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadingQuest',
      debugShowCheckedModeBanner: false,
      
      // Navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
      },
      
      // Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
    );
  }
}