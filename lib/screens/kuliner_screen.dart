import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'detail_wisata_screen.dart';
import 'package:explorecirebon/data/favorite_data.dart';
import '../controllers/destinasi_controller.dart';
import '../models/destinasi_model.dart';
import 'package:explorecirebon/config.dart';

class KulinerScreen extends StatefulWidget {
  const KulinerScreen({Key? key}) : super(key: key);

  @override
  State<KulinerScreen> createState() => _KulinerScreenState();
}

class _KulinerScreenState extends State<KulinerScreen> {
  @override
  void initState() {
    super.initState();
    // Mengambil data kategori Kuliner lewat Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinasiController>().fetchDestinasi('Kuliner');
    });
  }

  void _toggleFavorite(Destinasi item) {
    setState(() {
      int index = favoriteList.indexWhere((fav) => fav.title == item.nama);

      if (index >= 0) {
        favoriteList.removeAt(index);
        _showSnackBar('Dihapus dari Favorit', Colors.red.shade400);
      } else {
        favoriteList.add(
          FavoriteItem(
            title: item.nama,
            description: item.deskripsi ?? '',
            location: item.lokasi,
            imagePath: item.gambar ?? '',
            category: 'Kuliner',
          ),
        );
        _showSnackBar('Ditambahkan ke Favorit', Colors.green.shade400);
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DestinasiController>();
    // MENGGUNAKAN GETTER SPESIFIK: kulinerList
    final listKuliner = controller.kulinerList;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1F4D), Color(0xFF212859), Color(0xFF3F467E)],
              ),
            ),
          ),

          // Dekorasi Lingkaran
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
            child: Builder(
              builder: (context) {
                // Tampilan Loading
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                // Tampilan jika data kosong (menggunakan listKuliner)
                if (listKuliner.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu, color: Colors.white24, size: 80),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada data kuliner",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        TextButton(
                          onPressed: () => controller.fetchDestinasi('Kuliner'),
                          child: const Text("Coba Lagi", style: TextStyle(color: Colors.blueAccent)),
                        )
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchDestinasi('Kuliner'),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: listKuliner.length,
                    itemBuilder: (context, index) {
                      final item = listKuliner[index];
                      return _buildKulinerCard(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKulinerCard(BuildContext context, Destinasi item) {
    bool isFavorited = favoriteList.any((fav) => fav.title == item.nama);

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
                Image.network(
                  item.gambar ?? '',
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 190,
                      color: Colors.white.withOpacity(0.1),
                      child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 50),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(item),
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
                    item.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.deskripsi ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.lokasi,
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
                            builder: (_) => DetailWisataScreen(destinasi: item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.explore_rounded, size: 20),
                      label: const Text(
                        'JELAJAHI SEKARANG',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
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