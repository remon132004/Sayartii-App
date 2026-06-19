import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Place Model ──────────────────────────────────────────────────────────────
enum PlaceType { mechanic, partsStore }

class NearbyPlace {
  final String name;
  final double lat;
  final double lon;
  final PlaceType type;
  final String? phone;
  final String? openingHours;
  final bool isMock;

  const NearbyPlace({
    required this.name,
    required this.lat,
    required this.lon,
    required this.type,
    this.phone,
    this.openingHours,
    this.isMock = false,
  });
}

// ─── Geoapify Places Service ───────────────────────────────────────────────────
class OverpassService {
  static const _apiKey = 'e9cd40f1332d4951acbfdb356681310e';
  static const _baseUrl = 'https://api.geoapify.com/v2/places';

  // ── Instant mock data — always available, no internet needed ─────────────
  static List<NearbyPlace> mockMechanics(double lat, double lon) => [
        NearbyPlace(
          name: 'Auto Pro Service Center',
          lat: lat + 0.0030, lon: lon + 0.0020,
          type: PlaceType.mechanic,
          phone: '+20 123 456 7890',
          openingHours: '09:00 AM – 10:00 PM',
          isMock: true,
        ),
        NearbyPlace(
          name: 'Speedy Tyres & Parts',
          lat: lat - 0.0020, lon: lon + 0.0040,
          type: PlaceType.partsStore,
          phone: '+20 111 222 3333',
          openingHours: '08:00 AM – 11:00 PM',
          isMock: true,
        ),
        NearbyPlace(
          name: 'Expert Car Repair',
          lat: lat - 0.0040, lon: lon - 0.0030,
          type: PlaceType.mechanic,
          openingHours: 'Open 24 Hours',
          isMock: true,
        ),
        NearbyPlace(
          name: 'Genuine Auto Parts',
          lat: lat + 0.0010, lon: lon - 0.0050,
          type: PlaceType.partsStore,
          isMock: true,
        ),
        NearbyPlace(
          name: 'Quick Fix Workshop',
          lat: lat + 0.0060, lon: lon - 0.0010,
          type: PlaceType.mechanic,
          phone: '+20 100 999 8888',
          openingHours: '10:00 AM – 08:00 PM',
          isMock: true,
        ),
      ];

  // ── Try to fetch REAL places from Geoapify ────────────────────────────────
  static Future<List<NearbyPlace>?> tryFetchReal({
    required double lat,
    required double lon,
    int radius = 5000,
  }) async {
    // Geoapify categories: car_repair + car_parts + tyres
    const categories =
        'service.vehicle.car_repair,service.vehicle.car_parts,service.vehicle.tyres';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'categories': categories,
      'filter': 'circle:$lon,$lat,$radius', // NOTE: lon comes first for Geoapify
      'limit': '20',
      'apiKey': _apiKey,
    });

    try {
      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (json['features'] as List?) ?? [];

      final places = <NearbyPlace>[];

      for (final feature in features) {
        final props = (feature['properties'] as Map<String, dynamic>?) ?? {};
        final geometry = (feature['geometry'] as Map<String, dynamic>?) ?? {};

        // Coordinates — GeoJSON order is [lon, lat]
        final coords = (geometry['coordinates'] as List?) ?? [];
        if (coords.length < 2) continue;

        final eLon = (coords[0] as num?)?.toDouble();
        final eLat = (coords[1] as num?)?.toDouble();
        if (eLat == null || eLon == null || !eLat.isFinite || !eLon.isFinite) {
          continue;
        }

        // Name
        final name = props['name'] as String? ??
            props['address_line1'] as String? ??
            'Car Service';

        // Classify type from categories list
        final cats = (props['categories'] as List?)
                ?.map((c) => c.toString())
                .toList() ??
            [];
        final isPartsOrTyres = cats
            .any((c) => c.contains('car_parts') || c.contains('tyres'));
        final type = isPartsOrTyres ? PlaceType.partsStore : PlaceType.mechanic;

        // Contact info
        final contact = props['contact'] as Map<String, dynamic>?;
        final phone = contact?['phone'] as String? ??
            props['phone'] as String?;
        final openingHours = props['opening_hours'] as String?;

        places.add(NearbyPlace(
          name: name,
          lat: eLat,
          lon: eLon,
          type: type,
          phone: phone,
          openingHours: openingHours,
        ));
      }

      return places; // may be empty list — caller decides what to do
    } catch (_) {
      return null; // silently fall back to mock
    }
  }
}
