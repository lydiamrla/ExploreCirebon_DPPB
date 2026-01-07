import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'budaya_screen.dart';
import 'kuliner_screen.dart';
import 'religi_screen.dart';
import 'profile_screen.dart';

class DestinasiScreen extends StatelessWidget {
  final int initialIndex;

  const DestinasiScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1F4D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1F4D),
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false, // Kita buat header custom
          
          // 1. Tombol Back (Putih)
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),

          // 2. Logo di tengah/kiri atas menggunakan title agar rapi
          title: SvgPicture.asset(
            'assets/image/logo.svg', 
            height: 40, // Ukuran disesuaikan agar proporsional di AppBar
          ),

          // 3. Tombol Profil di Kanan Atas
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF212859),
                      child: Icon(Icons.person_outline, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 4. TabBar yang Didesain Ulang (Eksklusif)
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TabBar(
                // Efek garis bawah yang custom
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3,
                    color: Color.fromARGB(255, 232, 232, 232), // Bisa diganti warna neon favorit
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 30),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.4),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: 'Budaya'),
                  Tab(text: 'Kuliner'),
                  Tab(text: 'Religi'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            BudayaScreen(),
            KulinerScreen(),
            ReligiScreen(),
          ],
        ),
      ),
    );
  }
}