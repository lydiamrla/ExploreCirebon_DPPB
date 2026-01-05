import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:explorecirebon/data/favorite_data.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  
  void _removeFavorite(int index) {
    setState(() {
      final item = favoriteList[index];
      favoriteList.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} dihapus dari favorit'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade400,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorit Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF191F51),
                  Color(0xFF2E3B8C),
                  Color(0xFF191F51),
                ],
              ),
            ),
          ),

          // 2. DEKORASI CAHAYA
          Positioned(
            top: 150,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.05),
              ),
            ),
          ),

          // 3. CONTENT
          SafeArea(
            child: favoriteList.isEmpty 
                ? _buildEmptyState(context)
                : _buildFavoriteList(),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE (Ketika belum ada favorit)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Icon(
                Icons.favorite_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Belum Ada Favorit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              'Sepertinya kamu belum menandai tempat wisata impianmu. Mulai jelajahi sekarang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // TOMBOL JELAJAHI
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 10,
              shadowColor: Colors.blueAccent.withOpacity(0.3),
            ),
            child: const Text(
              'Mulai Menjelajah',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // LIST FAVORIT (Ketika ada data)
  Widget _buildFavoriteList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: favoriteList.length,
      itemBuilder: (context, index) {
        final item = favoriteList[index];
        return _buildFavoriteCard(item, index);
      },
    );
  }

  // CARD FAVORIT
  Widget _buildFavoriteCard(FavoriteItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Row(
              children: [
                // GAMBAR
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Image.asset(
                    item.imagePath,
                    width: 120,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 140,
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(
                          _getCategoryIcon(item.category),
                          color: Colors.white24,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                
                // INFORMASI
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BADGE KATEGORI
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(item.category),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // JUDUL
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // LOKASI
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // TOMBOL HAPUS FAVORIT
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeFavorite(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER: GET CATEGORY ICON
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Budaya':
        return Icons.account_balance;
      case 'Kuliner':
        return Icons.restaurant_rounded;
      case 'Religi':
        return Icons.mosque_rounded;
      default:
        return Icons.place;
    }
  }

  // HELPER: GET CATEGORY COLOR
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Budaya':
        return Colors.purple.shade600;
      case 'Kuliner':
        return Colors.orange.shade600;
      case 'Religi':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}