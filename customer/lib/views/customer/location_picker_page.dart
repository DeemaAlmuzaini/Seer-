
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
const LocationPickerPage({
  super.key,
  required this.title,
  this.initialSelectedLocation,
});

  final String title;
  final LatLng? initialSelectedLocation;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const String _apiKey = String.fromEnvironment('STADIA_API_KEY');

  // Riyadh is the initial location, but the map supports all of Saudi Arabia.
  static const LatLng _initialLocation = LatLng(24.7136, 46.6753);

  LatLng? _selectedLocation;

  final MapController _mapController = MapController();

LatLng? _currentLocation;
bool _isFetchingLocation = true;
bool _gpsFailed = false;

@override
void initState() {
  super.initState();
    _selectedLocation = widget.initialSelectedLocation;
  _fetchCurrentLocation();
}

Future<void> _fetchCurrentLocation() async {
  setState(() {
    _isFetchingLocation = true;
    _gpsFailed = false;
  });

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 8),
      ),
    );

    if (!mounted) return;

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isFetchingLocation = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isFetchingLocation = false;
      _gpsFailed = true;
    });

    debugPrint('GPS error: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
                mapController: _mapController,
            options: MapOptions(
initialCenter: widget.initialSelectedLocation ?? _initialLocation,              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}.png?api_key=$_apiKey',
                userAgentPackageName: 'com.example.seer',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© Stadia Maps, © OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),
                    Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
            child: TextButton.icon(
  onPressed: _isFetchingLocation
      ? null
      : _gpsFailed
          ? _fetchCurrentLocation
          : () {
              if (_currentLocation == null) return;

              setState(() {
                _selectedLocation = _currentLocation;
              });

              _mapController.move(_currentLocation!, 16);
            },
  icon: _isFetchingLocation
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.grey,
          ),
        )
      : Icon(
          _gpsFailed
              ? Icons.location_disabled
              : Icons.my_location,
          color: _gpsFailed
              ? Colors.grey
              : const Color(0xFF2E7D32),
        ),
  label: Text(
    _isFetchingLocation
        ? 'جارٍ تحديد الموقع...'
        : _gpsFailed
            ? 'إعادة المحاولة'
            : 'موقعي الحالي',
  ),
  style: TextButton.styleFrom(
    foregroundColor: const Color(0xFF2E7D32),
    disabledForegroundColor: Colors.grey,
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
  ),
),
              ),
            ),
          ),

          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SafeArea(
              child: ElevatedButton(
  onPressed: _selectedLocation == null
      ? null
      : () => Navigator.pop(context, _selectedLocation),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2E7D32),
    foregroundColor: Colors.white,
    disabledBackgroundColor: Colors.grey.shade300,
    disabledForegroundColor: Colors.grey.shade600,
    minimumSize: const Size(double.infinity, 54),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  child: const Text(
    'تأكيد الموقع',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
),
            ),
          ),
        ],
      ),
    );
  }
}
