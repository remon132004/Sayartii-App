import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/services/overpass_service.dart';

class NearbyMechanicsView extends StatefulWidget {
  const NearbyMechanicsView({super.key});

  @override
  State<NearbyMechanicsView> createState() => _NearbyMechanicsViewState();
}

class _NearbyMechanicsViewState extends State<NearbyMechanicsView> {
  final _mapController = MapController();

  bool _locating = true;
  bool _refreshingReal = false;
  String? _locationError;

  Position? _position;
  List<NearbyPlace> _places = [];

  // Default center — Cairo
  LatLng _center = const LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });

    // ── Step 1: Get GPS location ──────────────────────────────────────────────
    Position? pos;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission denied.';
          _locating = false;
        });
        return;
      }

      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!pos.latitude.isFinite || !pos.longitude.isFinite) {
        throw Exception('Invalid GPS coordinates.');
      }
    } catch (e) {
      setState(() {
        _locationError = 'Could not get your location. Make sure GPS is on.';
        _locating = false;
      });
      return;
    }

    _position = pos;
    _center = LatLng(pos.latitude, pos.longitude);

    // ── Step 2: Show map INSTANTLY with mock data ─────────────────────────────
    setState(() {
      _places = OverpassService.mockMechanics(pos!.latitude, pos.longitude);
      _locating = false;
      _refreshingReal = true; // small spinner shows API is loading in background
    });

    // ── Step 3: Try real API silently in background ───────────────────────────
    final real = await OverpassService.tryFetchReal(
      lat: pos.latitude,
      lon: pos.longitude,
    );

    if (!mounted) return;
    setState(() {
      _refreshingReal = false;
      if (real != null && real.isNotEmpty) {
        _places = real; // upgrade to real OSM data if available
      }
      // if real == null or empty → keep the already-displayed mock data
    });
  }

  void _onMarkerTap(NearbyPlace place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlaceSheet(place: place, userPosition: _position),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mechanics   = _places.where((p) => p.type == PlaceType.mechanic).toList();
    final partsStores = _places.where((p) => p.type == PlaceType.partsStore).toList();

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kSurface,
        foregroundColor: kPrimaryDarkColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nearby Mechanics',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorderColor),
        ),
        actions: [
          if (!_locating)
            IconButton(
              icon: _refreshingReal
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: kAccentColor, strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded),
              onPressed: _refreshingReal ? null : _init,
              color: kAccentColor,
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map (always rendered) ──────────────────────────────────────────
          FlutterMap(
            key: ValueKey(_center.latitude),
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _locating ? 5 : 14,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sayartii.app',
                maxNativeZoom: 19,
              ),

              // Mechanic markers (green)
              MarkerLayer(
                markers: mechanics.map((p) => Marker(
                  point: LatLng(p.lat, p.lon),
                  width: 44, height: 44,
                  child: GestureDetector(
                    onTap: () => _onMarkerTap(p),
                    child: _PinIcon(
                      color: const Color(0xFF16A34A),
                      icon: Icons.build_rounded,
                    ),
                  ),
                )).toList(),
              ),

              // Parts store markers (blue)
              MarkerLayer(
                markers: partsStores.map((p) => Marker(
                  point: LatLng(p.lat, p.lon),
                  width: 44, height: 44,
                  child: GestureDetector(
                    onTap: () => _onMarkerTap(p),
                    child: _PinIcon(
                      color: const Color(0xFF2563EB),
                      icon: Icons.store_rounded,
                    ),
                  ),
                )).toList(),
              ),

              // User location dot
              if (_position != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(_position!.latitude, _position!.longitude),
                    width: 24, height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: kAccentColor.withValues(alpha: 0.4),
                            blurRadius: 8, spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
            ],
          ),

          // ── Info badge ─────────────────────────────────────────────────────
          if (!_locating && _locationError == null)
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: kSurface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: kBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: kAccentColor, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${_places.length} locations nearby',
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: kPrimaryDarkColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Legend ─────────────────────────────────────────────────────────
          if (!_locating && _locationError == null)
            Positioned(
              bottom: 16, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kSurface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendRow(color: kAccentColor,            label: 'Your Location'),
                    const SizedBox(height: 5),
                    _LegendRow(color: const Color(0xFF16A34A), label: 'Mechanic'),
                    const SizedBox(height: 5),
                    _LegendRow(color: const Color(0xFF2563EB), label: 'Parts Store'),
                  ],
                ),
              ),
            ),

          // ── Recenter button ─────────────────────────────────────────────────
          if (_position != null)
            Positioned(
              bottom: 16, right: 14,
              child: GestureDetector(
                onTap: () => _mapController.move(
                    LatLng(_position!.latitude, _position!.longitude), 14),
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: kAccentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kAccentColor.withValues(alpha: 0.35),
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

          // ── GPS loading overlay ─────────────────────────────────────────────
          if (_locating)
            Container(
              color: kSurface.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: kAccentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kAccentColor.withValues(alpha: 0.3),
                            blurRadius: 20, offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_searching_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text('Getting your location…',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: kPrimaryDarkColor,
                        )),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        color: kAccentColor,
                        backgroundColor: kAccentSoft,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Location error overlay ──────────────────────────────────────────
          if (_locationError != null)
            Container(
              color: kSurface.withValues(alpha: 0.9),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: kDangerColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_off_rounded,
                            color: kDangerColor, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(_locationError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14, color: kSecondaryTextColor, height: 1.5,
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _init,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Enums ────────────────────────────────────────────────────────────────────

// ─── Custom pin icon ──────────────────────────────────────────────────────────
class _PinIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _PinIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          child: Container(
            width: 10, height: 5,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Icon(Icons.location_on_rounded, color: color, size: 40),
        Positioned(
          top: 5,
          child: Icon(icon, color: Colors.white, size: 14),
        ),
      ],
    );
  }
}

// ─── Legend row ───────────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: kPrimaryDarkColor,
            )),
      ],
    );
  }
}

// ─── Place detail bottom sheet ────────────────────────────────────────────────
class _PlaceSheet extends StatelessWidget {
  final NearbyPlace place;
  final Position? userPosition;
  const _PlaceSheet({required this.place, required this.userPosition});

  String _distance() {
    if (userPosition == null) return '';
    final meters = Geolocator.distanceBetween(
      userPosition!.latitude, userPosition!.longitude,
      place.lat, place.lon,
    );
    if (meters < 1000) return '${meters.round()} m away';
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final isMechanic = place.type == PlaceType.mechanic;
    final color = isMechanic
        ? const Color(0xFF16A34A)
        : const Color(0xFF2563EB);
    final dist = _distance();

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.08),
            blurRadius: 32, offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: kBorderColor,
                borderRadius: BorderRadius.circular(100)),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  isMechanic ? Icons.build_rounded : Icons.store_rounded,
                  color: color, size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: kPrimaryDarkColor,
                        )),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        isMechanic ? 'Mechanic' : 'Parts Store',
                        style: TextStyle(
                          color: color, fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              if (dist.isNotEmpty) ...[
                _InfoChip(
                    icon: Icons.near_me_rounded,
                    label: dist,
                    color: kAccentColor),
                const SizedBox(width: 8),
              ],
              if (place.openingHours != null)
                Expanded(
                  child: _InfoChip(
                    icon: Icons.schedule_rounded,
                    label: place.openingHours!,
                    color: kSuccessColor,
                    maxLines: 1,
                  ),
                ),
            ],
          ),

          if (place.phone != null) ...[
            const SizedBox(height: 8),
            _InfoChip(
              icon: Icons.phone_rounded,
              label: place.phone!,
              color: kSecondaryTextColor,
              full: true,
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: Ink(
              decoration: BoxDecoration(
                gradient: kAccentGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: kAccentColor.withValues(alpha: 0.3),
                    blurRadius: 14, offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('View on Map',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool full;
  final int maxLines;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.full = false,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                style: TextStyle(
                  color: color, fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
