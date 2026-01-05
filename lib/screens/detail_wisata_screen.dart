import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailWisataScreen extends StatefulWidget {
  final String title;
  final String description;
  final String location;

  const DetailWisataScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.location,
  }) : super(key: key);

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  

  // ================== LOKASI ==================
  /// ================== DATA LOKASI ==================
  final Map<String, LatLng> _locations = {
    'Kasepuhan': const LatLng(-6.7063, 108.5571),
    'Kanoman': const LatLng(-6.7089, 108.5577),
    'Trupark': const LatLng(-6.7324, 108.5520),
    'Empal': const LatLng(-6.7069, 108.5565),
    'Jamblang': const LatLng(-6.7210, 108.5618),
    'Docang': const LatLng(-6.7075, 108.5559),
    'Gunung Jati': const LatLng(-6.6629, 108.5361),
    'Masjid Agung': const LatLng(-6.7083, 108.5567),
    'Syekh': const LatLng(-6.7264, 108.5503),
  };

  /// ================== JAM OPERASIONAL ==================
  final Map<String, String> _jamOperasional = {
    'Kasepuhan': '09.00 - 17.00 WIB',
    'Kanoman': '09.00 - 16.30 WIB',
    'Trupark': '10.00 - 22.00 WIB',
    'Empal': '07.00 - 21.00 WIB',
    'Jamblang': '06.00 - 12.00 WIB',
    'Docang': '06.00 - 10.00 WIB',
    'Gunung Jati': '08.00 - 17.00 WIB',
    'Masjid Agung': '24 Jam',
    'Syekh': '08.00 - 17.00 WIB',
  };

  String _getImagePath(String title) {
    // Budaya
    if (title.contains('Kasepuhan')) return 'assets/image/kasepuhan.jpg';
    if (title.contains('Kanoman')) return 'assets/image/kanoman.jpg';
    if (title.contains('Trupark')) return 'assets/image/trupak.jpg';

    // Kuliner
    if (title.contains('Empal')) return 'assets/image/empalgentong.jpg';
    if (title.contains('Jamblang')) return 'assets/image/nasijamblang.jpg';
    if (title.contains('Docang')) return 'assets/image/docang.jpg';

    // Religi
    if (title.contains('Gunung Jati')) return 'assets/image/sunangunungjati.jpg';
    if (title.contains('Masjid Agung')) return 'assets/image/masjidagung.jpg';
    if (title.contains('Syekh')) return 'assets/image/syekhdatuk.jpg';

    return 'assets/image/default.jpg';
  }

  LatLng _getCoordinates(String title) {
    for (var key in _locations.keys) {
      if (title.contains(key)) {
        return _locations[key]!;
      }
    }
    return const LatLng(-6.7063, 108.5571); // default Cirebon
  }

    String _getJamOperasional(String title) {
    for (var key in _jamOperasional.keys) {
      if (title.contains(key)) {
        return _jamOperasional[key]!;
      }
    }
    return '08.00 - 17.00 WIB';
  }

  // ================== GOOGLE MAPS EKSTERNAL ==================
  Future<void> _openGoogleMaps(LatLng coordinates) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coordinates.latitude},${coordinates.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

final List<Map<String, String>> _reviews = [
  {
    'user': 'kudafluburung',
    'rating': '⭐⭐⭐⭐',
    'comment': 'Tempatnya sangat bersejarah dan dijaga dengan sangat baik. Bersih!',
  },
  {
    'user': 'doratravelworld',
    'rating': '⭐⭐⭐⭐⭐',
    'comment': 'Wajib dikunjungi kalau ke Cirebon. Guide-nya ramah.',
  },
];

// controller form
final TextEditingController _ulasanController = TextEditingController();
int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupMarker();
  }

  void _setupMarker() {
    final coordinates = _getCoordinates(widget.title);
    _markers.add(
      Marker(
        markerId: MarkerId(widget.title),
        position: coordinates,
        infoWindow: InfoWindow(title: widget.title, snippet: widget.location),
      ),
    );
  }

  @override
void dispose() {
  _tabController.dispose();
  _mapController?.dispose();
  _ulasanController.dispose();
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
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _getImagePath(widget.title),
                  fit: BoxFit.cover,
                  alignment: widget.title.contains('Kanoman')
                      ? Alignment.bottomCenter
                      : Alignment.center,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'kucinkmosing',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================== CONTENT ==================
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
                            widget.title,
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
                                  widget.location,
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
                      indicatorWeight: 3,
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
        ],
      ),
    );
  }

  // ================== OVERVIEW ==================
  Widget _buildOverviewTab(ScrollController sc) {
    final coordinates = _getCoordinates(widget.title);

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
          widget.description,
          style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.6),
        ),
        const SizedBox(height: 24),

        // JAM OPERASIONAL (TETAP CARD ASLI)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_filled, color: Colors.orangeAccent),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jam Operasional',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getJamOperasional(widget.title),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // MAP
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: coordinates,
                zoom: 16,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // BUTTON GOOGLE MAPS
        ElevatedButton.icon(
          onPressed: () => _openGoogleMaps(coordinates),
          icon: const Icon(Icons.directions),
          label: const Text('Buka di Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  // ================== ULASAN ==================
  Widget _buildUlasanTab(ScrollController sc) {
  return ListView(
    controller: sc,
    padding: const EdgeInsets.all(24),
    children: [
      _buildFormUlasan(),
      const SizedBox(height: 24),

      // LIST ULASAN
      ..._reviews.map(
        (review) => _buildReviewItem(
          review['user']!,
          review['rating']!,
          review['comment']!,
        ),
      ),
      const SizedBox(height: 30),
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
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // RATING
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                Icons.star,
                color: index < _selectedRating
                    ? Colors.orangeAccent
                    : Colors.white24,
              ),
              onPressed: () {
                setState(() {
                  _selectedRating = index + 1;
                });
              },
            );
          }),
        ),

        // ULASAN
        TextField(
          controller: _ulasanController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Tulis ulasan...'),
        ),
        const SizedBox(height: 16),

        // BUTTON SIMPAN
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Kirim Ulasan'),
          ),
        ),
      ],
    ),
  );
}
InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
void _submitReview() {
  if (_ulasanController.text.isEmpty) {
    return;
  }

  setState(() {
    _reviews.insert(0, {
      'user': 'Pengunjung',
      'rating': '⭐' * _selectedRating,
      'comment': _ulasanController.text,
    });
  });

  _ulasanController.clear();
  _selectedRating = 5;
}



  Widget _buildReviewItem(String user, String rating, String comment) {
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
                user,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(rating, style: const TextStyle(fontSize: 12)),
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
