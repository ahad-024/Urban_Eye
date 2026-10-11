import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const Color _background = Color(0xFF08080A);
  static const Color _card = Color(0xFF141318);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _muted = Color(0xFF9A96A5);

  final MapController _mapController = MapController();

  // Same initial map center as the old React Leaflet map.
  LatLng _selectedPoint = const LatLng(24.8607, 67.0011);

  String _address = 'Karachi, Pakistan';
  String _street = '';
  String _area = '';
  String _city = 'Karachi';

  bool _isGettingLocation = false;
  bool _isAddressLoading = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _selectPoint(LatLng point) async {
    setState(() {
      _selectedPoint = point;
      _address = 'Getting address...';
      _isAddressLoading = true;
    });

    await _getAddress(point);
  }

  Future<void> _getAddress(LatLng point) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': point.latitude.toString(),
          'lon': point.longitude.toString(),
          'zoom': '18',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: const {'Accept-Language': 'en'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Address service returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final addressData =
          data['address'] as Map<String, dynamic>? ?? {};

      final street = [
        addressData['road'],
        addressData['pedestrian'],
        addressData['residential'],
      ].whereType<String>().firstWhere(
            (value) => value.trim().isNotEmpty,
            orElse: () => '',
          );

      final area = [
        addressData['suburb'],
        addressData['neighbourhood'],
        addressData['quarter'],
      ].whereType<String>().firstWhere(
            (value) => value.trim().isNotEmpty,
            orElse: () => '',
          );

      final city = [
        addressData['city'],
        addressData['town'],
        addressData['village'],
        addressData['municipality'],
      ].whereType<String>().firstWhere(
            (value) => value.trim().isNotEmpty,
            orElse: () => 'Karachi',
          );

      final displayAddress =
          (data['display_name'] as String?)?.trim();

      if (!mounted) return;

      setState(() {
        _street = street;
        _area = area;
        _city = city;
        _address = displayAddress != null &&
                displayAddress.isNotEmpty
            ? displayAddress
            : '${point.latitude.toStringAsFixed(6)}, '
                '${point.longitude.toStringAsFixed(6)}';
        _isAddressLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _street = '';
        _area = '';
        _city = '';
        _address =
            '${point.latitude.toStringAsFixed(6)}, '
            '${point.longitude.toStringAsFixed(6)}';
        _isAddressLoading = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage(
            'Location permission denied. Select a point on the map instead.',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final point = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() => _selectedPoint = point);

      _mapController.move(point, 16);
      await _getAddress(point);
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Could not get your current location. '
          'Tap the map to choose manually.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _confirmLocation() {
    context.pop({
      'latitude': _selectedPoint.latitude,
      'longitude': _selectedPoint.longitude,
      'street': _street,
      'area': _area,
      'city': _city,
      'address': _address,
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Location',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF292630),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      color: _purple,
                      size: 23,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select complaint location',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap anywhere on the map to place a pin.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _useCurrentLocation,
                      tooltip: 'Use current location',
                      icon: _isGettingLocation
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _purple,
                              ),
                            )
                          : const Icon(
                              LucideIcons.crosshair,
                              color: _purple,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Interactive OpenStreetMap map — no Google Maps key.
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 13,
                  minZoom: 3,
                  maxZoom: 19,
                  onTap: (tapPosition, point) {
                    _selectPoint(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.urbaneye_mobile',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 54,
                        height: 62,
                        child: const Column(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              color: _purple,
                              size: 42,
                            ),
                            SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        '© OpenStreetMap contributors',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selected address and confirmation.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: const BoxDecoration(
                color: _background,
                border: Border(
                  top: BorderSide(color: Color(0xFF292630)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECTED LOCATION',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: _purple,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAddressLoading
                                  ? 'Finding address...'
                                  : _address,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${_selectedPoint.latitude.toStringAsFixed(6)}, '
                              '${_selectedPoint.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
