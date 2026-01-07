import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/destinasi_model.dart';
import '../controllers/destinasi_controller.dart';
import 'package:explorecirebon/screens/profile_screen.dart';

class DetailWisataScreen extends StatefulWidget {
  final Destinasi destinasi;

  const DetailWisataScreen({
    Key? key,
    required this.destinasi,
  }) : super(key: key);

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final DestinasiController _apiController = DestinasiController();
  final TextEditingController _ulasanController = TextEditingController();
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupMarker();
  }

  void _setupMarker() {
    final lat = double.tryParse(widget.destinasi.latitude ?? '0') ?? 0.0;
    final lng = double.tryParse(widget.destinasi.longitude ?? '0') ?? 0.0;
    
    _markers.add(
      Marker(
        markerId: MarkerId(widget.destinasi.id.toString()),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: widget.destinasi.nama, 
          snippet: widget.destinasi.lokasi
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final lat = widget.destinasi.latitude;
    final lng = widget.destinasi.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _submitReview() async {
    if (_ulasanController.text.isEmpty) return;

    bool success = await _apiController.postUlasan(
      widget.destinasi.id,
      _ulasanController.text,
      _selectedRating,
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil dikirim!')),
      );
      _ulasanController.clear();
      setState(() {
        _selectedRating = 5;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ulasanController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4D),
      body: Stack(
        children: [
          // ================== HERO IMAGE ==================
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  "http://10.0.2.2:8000/storage/${widget.destinasi.gambar}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 50),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        const Color(0xFF1A1F4D),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================== HEADER ==================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Text('Profile', style: TextStyle(color: Colors.white, fontSize: 12)),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 14, 
                            backgroundColor: Colors.blueAccent, 
                            child: Icon(Icons.person, size: 16, color: Colors.white)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================== CONTENT SHEET ==================
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.55,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF212859),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.destinasi.nama, 
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.destinasi.lokasi, 
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.blueAccent,
                      tabs: const [Tab(text: 'Overview'), Tab(text: 'Ulasan')],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(scrollController),
                          _buildUlasanTab(scrollController),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ScrollController sc) {
    final lat = double.tryParse(widget.destinasi.latitude ?? '0') ?? 0.0;
    final lng = double.tryParse(widget.destinasi.longitude ?? '0') ?? 0.0;

    return ListView(
      controller: sc,
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Deskripsi Wisata', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(widget.destinasi.deskripsi ?? '-', style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.6)),
        const SizedBox(height: 24),
        _buildInfoCard(Icons.confirmation_number, 'Harga Tiket', widget.destinasi.harga ?? 'Gratis'),
        const SizedBox(height: 12),
        _buildInfoCard(Icons.access_time_filled, 'Jam Operasional', widget.destinasi.jamOprasional ?? '24 Jam'),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 16),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              zoomControlsEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _openGoogleMaps,
          icon: const Icon(Icons.directions),
          label: const Text('Buka di Google Maps'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

Widget _buildUlasanTab(ScrollController sc) {
  // Sekarang widget.destinasi.ulasan adalah List<Ulasan>, bukan List<Map>
  final listUlasan = widget.destinasi.ulasan;

  return ListView(
    controller: sc,
    padding: const EdgeInsets.all(24),
    children: [
      _buildFormUlasan(),
      const SizedBox(height: 24),
      
      if (listUlasan.isEmpty)
        const Center(child: Text("Belum ada ulasan", style: TextStyle(color: Colors.white54))),

      ...listUlasan.map((review) {
        // Mengakses property menggunakan titik (.) karena sudah jadi Model
        final userName = review.user?.name ?? 'Anonim';
        final ratingInt = review.rating;
        
        return _buildReviewItem(
          userName,
          '⭐' * ratingInt,
          review.komentar,
        );
      }).toList(),
    ],
  );
}

  Widget _buildFormUlasan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tambah Ulasan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: List.generate(5, (index) => IconButton(
              icon: Icon(Icons.star, color: index < _selectedRating ? Colors.orangeAccent : Colors.white24),
              onPressed: () => setState(() => _selectedRating = index + 1),
            )),
          ),
          TextField(
            controller: _ulasanController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tulis ulasan...', 
              hintStyle: const TextStyle(color: Colors.white38), 
              filled: true, 
              fillColor: Colors.white.withOpacity(0.05), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, 
            child: ElevatedButton(
              onPressed: _submitReview, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent), 
              child: const Text('Kirim Ulasan')
            )
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String user, String rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(user, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            Text(rating, style: const TextStyle(fontSize: 12, color: Colors.orangeAccent)),
          ]),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}