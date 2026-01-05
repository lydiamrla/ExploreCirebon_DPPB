import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ExploreCirebonApp());
}

class ExploreCirebonApp extends StatelessWidget {
  const ExploreCirebonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExploreCirebon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E2D60), // Gunakan primaryColor
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E2D60), // Warna custom Anda
          primary: const Color(0xFF1E2D60),
        ),
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}