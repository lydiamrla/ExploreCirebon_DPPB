import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CirebonMapScreen extends StatelessWidget {
  const CirebonMapScreen({super.key});

  static const LatLng cirebon = LatLng(-6.7320, 108.5523);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Kota Cirebon'),
        backgroundColor: const Color(0xFF212859),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: cirebon,
          zoom: 12,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('cirebon'),
            position: cirebon,
            infoWindow: InfoWindow(
              title: 'Kota Cirebon',
              snippet: 'Jawa Barat',
            ),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
