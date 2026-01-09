import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/destinasi_model.dart';
import '../controllers/destinasi_controller.dart';
import '../controllers/auth_controller.dart';
import 'package:explorecirebon/controllers/ulasan_controller.dart';

class DetailWisataScreen extends StatefulWidget {
  final Destinasi destinasi;

  const DetailWisataScreen({Key? key, required this.destinasi})
    : super(key: key);

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  // PERBAIKAN: Gunakan satu nama controller yang konsisten untuk TextField ulasan
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
          snippet: widget.destinasi.lokasi,
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${widget.destinasi.latitude},${widget.destinasi.longitude}";
    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

void _submitReview() async {
    final authController = context.read<AuthController>();
    final ulasanController = context.read<UlasanController>();
    final destinasiController = context.read<DestinasiController>(); // Tambahkan ini

    final String? token = authController.token;

    if (token == null) return;

    bool success = await ulasanController.postUlasan(
      destinasiId: widget.destinasi.id,
      rating: _selectedRating,
      komentar: _ulasanController.text,
      token: token,
    );

    if (success) {
      _ulasanController.clear();
      
      // TARUH DI SINI:
      // Tujuannya agar list ulasan di bawah langsung bertambah otomatis
      await destinasiController.fetchDestinasi(widget.destinasi.kategori); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil dikirim!')),
        );
      }
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
  final String imageUrl = widget.destinasi.gambar ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4D),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF2D325A)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        const Color(0xFF1A1F4D),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.destinasi.nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.destinasi.lokasi,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
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
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white38,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Ulasan'),
                      ],
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
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
        const Text(
          'Deskripsi Wisata',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.destinasi.deskripsi ?? '-',
          style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.6),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          Icons.confirmation_number,
          'Harga Tiket',
          widget.destinasi.harga ?? 'Gratis',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.access_time_filled,
          'Jam Operasional',
          widget.destinasi.jamOprasional ?? '24 Jam',
        ),
        const SizedBox(height: 24),
        const Text(
          'Lokasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _openGoogleMaps,
          icon: const Icon(Icons.directions),
          label: const Text('Buka di Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUlasanTab(ScrollController sc) {
    final controller = context.watch<DestinasiController>();

    // Ambil data terbaru dari list kategori agar UI ulasan auto-update
    final currentDestinasi = controller
        .getDestinasiByCategory(widget.destinasi.kategori)
        .firstWhere(
          (element) => element.id == widget.destinasi.id,
          orElse: () => widget.destinasi,
        );
    final listUlasan = currentDestinasi.ulasan;

    return ListView(
      controller: sc,
      padding: const EdgeInsets.all(24),
      children: [
        _buildFormUlasan(),
        const SizedBox(height: 24),
        const Text(
          'Ulasan Pengunjung',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (listUlasan.isEmpty)
          const Center(
            child: Text(
              "Belum ada ulasan",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ...listUlasan
            .map(
              (review) => _buildReviewItem(
                review.user?.name,
                '⭐' * review.rating,
                review.komentar,
              ),
            )
            .toList(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildFormUlasan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Ulasan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                icon: Icon(
                  Icons.star,
                  color: index < _selectedRating
                      ? Colors.orangeAccent
                      : Colors.white24,
                ),
                onPressed: () => setState(() => _selectedRating = index + 1),
              ),
            ),
          ),
          TextField(
            controller:
                _ulasanController, // Pastikan menggunakan variabel yang sudah di-dispose
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Bagaimana pengalaman Anda?',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Kirim Ulasan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String? user, String rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (user == null || user.isEmpty) ? 'Anonim' : user,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
