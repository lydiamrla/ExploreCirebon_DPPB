import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'controllers/auth_controller.dart';
import 'controllers/destinasi_controller.dart'; // Import controller baru
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  // Wajib ditambahkan jika ada fungsi async sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi controller
  final authController = AuthController();
  
  // Mencoba login otomatis jika token masih tersimpan
  await authController.initUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider(create: (_) => DestinasiController()),
      ],
      child: const ExploreCirebonApp(),
    ),
  );
}

class ExploreCirebonApp extends StatelessWidget {
  const ExploreCirebonApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Mengecek status login untuk menentukan layar awal
    final auth = context.read<AuthController>();

    return MaterialApp(
      title: 'Explore Cirebon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF212859),
        fontFamily: 'Poppins', // Sesuaikan jika kamu pakai font custom
      ),
      // Jika user sudah login (hasil initUser), langsung ke Home
      home: auth.user != null ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}