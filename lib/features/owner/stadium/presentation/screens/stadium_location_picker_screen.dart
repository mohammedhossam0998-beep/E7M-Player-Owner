
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class StadiumLocationPickerScreen extends StatefulWidget {
  final LatLng? initialPoint;

  const StadiumLocationPickerScreen({
    super.key,
    this.initialPoint,
  });

  @override
  State<StadiumLocationPickerScreen> createState() =>
      _StadiumLocationPickerScreenState();
}

class _StadiumLocationPickerScreenState
    extends State<StadiumLocationPickerScreen> {
  static const Color _green = Color(0xFF7CC000);
  static const Color _navy = Color(0xFF1E1446);

  // Default map center only, not a saved stadium location.
  static const LatLng _defaultCenter =
  LatLng(30.0444, 31.2357);

  final MapController _mapController = MapController();

  LatLng? _selectedPoint;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // ============================================================
  // MAP ZOOM
  // ============================================================

  void _zoom(double change) {
    final camera = _mapController.camera;

    final newZoom = (camera.zoom + change)
        .clamp(3.0, 19.0)
        .toDouble();

    _mapController.move(
      camera.center,
      newZoom,
    );
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void> _useMyLocation() async {
    if (_locating) return;

    setState(() {
      _locating = true;
    });

    try {
      final enabled =
      await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        _showMessage(
          'فعّل خدمات الموقع أولًا.',
        );
        return;
      }

      var permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        _showMessage(
          'اسمح للتطبيق بالوصول إلى موقعك من إعدادات الجهاز.',
        );
        return;
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final point = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedPoint = point;
      });

      _mapController.move(
        point,
        17,
      );

      _showMessage(
        'راجع العلامة وتأكد أنها على الملعب نفسه.',
      );
    } catch (error) {
      _showMessage(
        'تعذر تحديد موقعك: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
        });
      }
    }
  }

  // ============================================================
  // OPENSTREETMAP ATTRIBUTION
  // ============================================================

  Future<void> _openAttribution() async {
    final url = Uri.parse(
      'https://www.openstreetmap.org/copyright',
    );

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      _showMessage(
        'تعذر فتح معلومات OpenStreetMap.',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final selected = _selectedPoint;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text(
          'تحديد موقع الملعب',
        ),
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // ====================================================
          // INTERACTIVE MAP
          // ====================================================

          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter:
              selected ?? _defaultCenter,

              initialZoom:
              selected == null ? 10 : 16,

              onTap: (_, point) {
                setState(() {
                  _selectedPoint = point;
                });
              },
            ),

            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                'com.e7m.app',
              ),

              if (selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 58,
                      height: 62,

                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 54,

                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black38,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ====================================================
          // INSTRUCTIONS
          // ====================================================

          Positioned(
            left: 16,
            right: 16,
            top: 14,

            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.95,
                  ),

                  borderRadius:
                  BorderRadius.circular(14),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    ),
                  ],
                ),

                child: const Text(
                  'حرّك الخريطة وكبّرها ثم اضغط على موقع الملعب لتثبيت العلامة.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // MAP CONTROLS
          // ====================================================

          Positioned(
            right: 14,
            top: 92,

            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'owner_map_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: _navy,

                  onPressed: () {
                    _zoom(1);
                  },

                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 8),

                FloatingActionButton.small(
                  heroTag: 'owner_map_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: _navy,

                  onPressed: () {
                    _zoom(-1);
                  },

                  child: const Icon(Icons.remove),
                ),

                const SizedBox(height: 8),

                FloatingActionButton.small(
                  heroTag: 'owner_map_my_location',
                  backgroundColor: Colors.white,
                  foregroundColor: _navy,

                  onPressed:
                  _locating ? null : _useMyLocation,

                  child: _locating
                      ? const SizedBox(
                    width: 17,
                    height: 17,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.my_location_rounded,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // MAP CREDIT
          // ====================================================

          Positioned(
            left: 8,
            bottom: 4,

            child: TextButton(
              onPressed: _openAttribution,

              style: TextButton.styleFrom(
                backgroundColor:
                Colors.white.withValues(
                  alpha: 0.9,
                ),
                foregroundColor: _navy,
                visualDensity:
                VisualDensity.compact,
              ),

              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // CONFIRM SELECTED LOCATION
      // ========================================================

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              Text(
                selected == null
                    ? 'لم يتم تحديد موقع بعد'
                    : 'Latitude: ${selected.latitude.toStringAsFixed(6)}   '
                    'Longitude: ${selected.longitude.toStringAsFixed(6)}',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 50,

                child: FilledButton.icon(
                  onPressed: selected == null
                      ? null
                      : () {
                    Navigator.pop(
                      context,
                      selected,
                    );
                  },

                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor:
                    Colors.white,
                  ),

                  icon: const Icon(
                    Icons.check_circle_outline,
                  ),

                  label: const Text(
                    'تأكيد موقع الملعب',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}