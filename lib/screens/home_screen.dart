import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:explorecirebon/data/berita_data.dart';
import 'berita_screen.dart';
import 'profile_screen.dart';
import 'budaya_screen.dart';
import 'kuliner_screen.dart';
import 'religi_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const LatLng cirebonLatLng = LatLng(-6.737246, 108.552253);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1F4D),
                  Color(0xFF212859),
                  Color(0xFF3F467E),
                ],
              ),
            ),
          ),

          Positioned(
            top: -50,
            right: -50,
            child: _buildBlurCircle(200, Colors.blue.withOpacity(0.15)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildHeroSection(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Eksplorasi Wisata'),
                        const SizedBox(height: 16),
                        _buildVerticalCategoryList(context),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Navigasi Cepat'),
                        const SizedBox(height: 16),
                        _buildQuickNavigation(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset('assets/image/logo.svg', height: 80),
          GestureDetector(
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
                radius: 18,
                backgroundColor: Color(0xFF212859),
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=-6.737246,108.552253',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ================= HERO (MAPS) =================
  Widget _buildHeroSection() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: GestureDetector(
              onTap: _openGoogleMaps,
              child: AbsorbPointer(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: cirebonLatLng,
                    zoom: 13,
                  ),
                  markers: {
                    const Marker(
                      markerId: MarkerId('cirebon'),
                      position: cirebonLatLng,
                    ),
                  },
                  zoomControlsEnabled: false,
                  liteModeEnabled: true,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  color: Colors.black.withOpacity(0.3),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tentang Cirebon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pusat peradaban Islam di Jawa Barat dengan kekayaan budaya, sejarah kesultanan, dan kuliner pesisir.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= KATEGORI =================
  Widget _buildVerticalCategoryList(BuildContext context) {
    return Column(
      children: [
        _buildCategoryCard(
          context,
          'Budaya',
          'assets/image/budaya.jpg',
          const BudayaScreen(),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          context,
          'Kuliner',
          'assets/image/kuliner.jpg',
          const KulinerScreen(),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          context,
          'Religi',
          'assets/image/religi.jpg',
          const ReligiScreen(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String image,
    Widget destination,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            alignment: title == 'Religi'
                ? Alignment.bottomCenter
                : Alignment.center,
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= BERITA =================
  Widget _buildNewsSlider() {
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        // Menambah 1 item untuk tombol "Lihat Semua"
        itemCount: cirebonNews.length + 1,
        itemBuilder: (context, index) {
          if (index == cirebonNews.length) {
            // Ini adalah item setelah slide terakhir
            return _buildViewMoreCard(context);
          }
          return _NewsCard(news: cirebonNews[index]);
        },
      ),
    );
  }

  // Widget tombol "Lihat Semua" di akhir slide
  Widget _buildViewMoreCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NewsScreen()),
      ),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lihat Semua\nBerita',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= WIDGET KARTU BERITA =================
class _NewsCard extends StatelessWidget {
  final NewsItem news;
  const _NewsCard({required this.news});

  Future<void> _openLink() async {
    final uri = Uri.parse(news.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openLink,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.asset(
                news.image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BERITA TERKINI',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white38,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
