import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:explorecirebon/data/favorite_data.dart';
import 'detail_wisata_screen.dart';

class ReligiScreen extends StatefulWidget {
  const ReligiScreen({Key? key}) : super(key: key);

  @override
  State<ReligiScreen> createState() => _ReligiScreenState();
}

class _ReligiScreenState extends State<ReligiScreen> {
  
  void _toggleFavorite(String title, String description, String location, String imagePath) {
    setState(() {
      int index = favoriteList.indexWhere((item) => item.title == title);
      
      if (index >= 0) {
        favoriteList.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dihapus dari Favorit'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red.shade400,
          ),
        );
      } else {
        favoriteList.add(FavoriteItem(
          title: title,
          description: description,
          location: location,
          imagePath: imagePath,
          category: 'Religi',
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ditambahkan ke Favorit'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green.shade400,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Wisata Religi Cirebon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
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
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildReligiCard(
                  'Makam Sunan Gunung Jati',
                  'Kompleks pemakaman salah satu Wali Songo yang merupakan pusat penyebaran Islam di Jawa Barat, dengan arsitektur unik perpaduan Jawa dan Tiongkok.',
                  'Astana Gunung Jati, Gunung Jati',
                  'assets/image/sunangunungjati.jpg',
                ),
                _buildReligiCard(
                  'Masjid Agung Sang Cipta Rasa',
                  'Masjid tertua di Cirebon yang dibangun pada tahun 1480 oleh Sunan Gunung Jati dan Sunan Kalijaga, sarat akan nilai sejarah dan spiritual.',
                  'Jl. Kasepuhan, Lemahwungkuk',
                  'assets/image/masjidagung.jpg',
                ),
                _buildReligiCard(
                  'Makam Syekh Datok Kahfi',
                  'Situs religi makam ulama besar sekaligus guru dari Sunan Gunung Jati, terletak di perbukitan yang tenang dan asri.',
                  'Jl. Panjunan, Lemahwungkuk',
                  'assets/image/syekhdatuk.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReligiCard(
    String title,
    String description,
    String location,
    String imagePath,
  ) {
    bool isFavorited = favoriteList.any((item) => item.title == title);

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 190,
                      color: Colors.white.withOpacity(0.1),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Colors.white24,
                        size: 50,
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // TOMBOL FAVORIT
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(title, description, location, imagePath),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.redAccent : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailWisataScreen(
                              title: title,
                              description: description,
                              location: location,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 20),
                      label: const Text(
                        'KUNJUNGI SEKARANG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
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