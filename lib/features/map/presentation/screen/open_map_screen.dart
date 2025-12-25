import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/map/presentation/cubit/reverse_geocode_cubit.dart';
import 'package:rentverse/features/map/presentation/cubit/reverse_geocode_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OpenMapScreen extends StatefulWidget {
  const OpenMapScreen({
    super.key,
    this.initialLat = -6.200000,
    this.initialLon = 106.816666,
  });

  final double initialLat;
  final double initialLon;

  @override
  State<OpenMapScreen> createState() => _OpenMapScreenState();
}

class _OpenMapScreenState extends State<OpenMapScreen> {
  late LatLng _center;
  late final MapController _mapController;

  Timer? _debounce;
  late final ReverseGeocodeCubit _reverseCubit;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.initialLat, widget.initialLon);
    _mapController = MapController();
    _reverseCubit = ReverseGeocodeCubit(sl())
      ..fetch(_center.latitude, _center.longitude);

  }

  @override
  void dispose() {
    _debounce?.cancel();
    _reverseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reverseCubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pick Location')),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 15,
                      onTap: (_, point) {
                        _mapController.move(point, _mapController.camera.zoom);

                      },
                      onPositionChanged: (pos, hasGesture) {
                        final newCenter = pos.center ?? _center;
                        setState(() => _center = newCenter);

                        _debounce?.cancel();
                        if (hasGesture) {
                          _debounce = Timer(
                            const Duration(milliseconds: 600),
                            () {
                              _reverseCubit.fetch(
                                _center.latitude,
                                _center.longitude,
                              );
                            },
                          );
                        } else {

                          _reverseCubit.fetch(
                            _center.latitude,
                            _center.longitude,
                          );
                        }
                      },
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
                            point: _center,
                            width: 48,
                            height: 48,
                            child: Icon(LucideIcons.mapPin,
                              size: 48,
                              color: Colors.redAccent,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
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
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))
              ),
              child: BlocBuilder<ReverseGeocodeCubit, ReverseGeocodeState>(
                builder: (context, state) {
                  if (state.status == ReverseGeocodeStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Loading address...'),
                        ],
                      ),
                    );
                  }

                  final location = state.location;
                  final displayName =
                      location?.displayName ?? 'Tap map to select';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (location != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${location.lat.toStringAsFixed(5)}, ${location.lon.toStringAsFixed(5)}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: customLinearGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: location != null
                                ? () {
                                    Navigator.of(context).pop({
                                      'lat': location.lat,
                                      'lon': location.lon,
                                      'displayName': location.displayName,
                                      'city': location.city,
                                      'country': location.country,
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                'Select Location',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(
                                      location != null ? 1.0 : 0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
