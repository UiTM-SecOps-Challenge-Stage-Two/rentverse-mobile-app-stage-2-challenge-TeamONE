import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentverse/features/map/presentation/screen/open_map_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapPicker extends StatelessWidget {
  const MapPicker({
    super.key,
    required this.initialLat,
    required this.initialLon,
    this.onLocationSelected,
  });

  final double initialLat;
  final double initialLon;
  final void Function(
    double lat,
    double lon,
    String? city,
    String? country,
    String? displayName,
  )?
  onLocationSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (_) =>
                OpenMapScreen(initialLat: initialLat, initialLon: initialLon),
          ),
        );
        if (result == null) return;
        final lat = (result['lat'] as num).toDouble();
        final lon = (result['lon'] as num).toDouble();
        final displayName = result['displayName'] as String?;
        final city = result['city'] as String?;
        final country = result['country'] as String?;
        if (onLocationSelected != null) {
          onLocationSelected!(lat, lon, city, country, displayName);
        }
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: const Text('Tap to pick location'),
      ),
    );
  }
}

class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    required this.lat,
    required this.lon,
    this.displayName,
    this.onTap,
  });

  final double lat;
  final double lon;
  final String? displayName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lon),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.rentverse',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lon),
                      width: 60,
                      height: 60,
                      child: Icon(LucideIcons.mapPin,
                        size: 50,
                        color: Colors.redAccent,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (displayName != null)
            Text(
              displayName!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          Text(
            'Lat: ${lat.toStringAsFixed(5)}, Lon: ${lon.toStringAsFixed(5)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
