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


  // ── Instant mock data — dynamic based on user location for demo purposes ──
  static List<NearbyPlace> mockMechanics(double lat, double lon) => [
        NearbyPlace(
          name: 'مركز المهندس لصيانة السيارات',
          lat: lat + 0.0030, lon: lon + 0.0020,
          type: PlaceType.mechanic,
          phone: '+20 100 123 4567',
          openingHours: '09:00 AM – 10:00 PM',
          isMock: true,
        ),
        NearbyPlace(
          name: 'Speedy Auto Parts',
          lat: lat - 0.0020, lon: lon + 0.0040,
          type: PlaceType.partsStore,
          phone: '+20 111 222 3333',
          openingHours: '08:00 AM – 11:00 PM',
          isMock: true,
        ),
        NearbyPlace(
          name: 'ورشة الأسطى حسن الميكانيكي',
          lat: lat - 0.0040, lon: lon - 0.0030,
          type: PlaceType.mechanic,
          openingHours: 'Open 24 Hours',
          isMock: true,
        ),
        NearbyPlace(
          name: 'الشركة الألمانية لقطع الغيار',
          lat: lat + 0.0010, lon: lon - 0.0050,
          type: PlaceType.partsStore,
          isMock: true,
        ),
        NearbyPlace(
          name: 'Quick Fix Workshop',
          lat: lat + 0.0060, lon: lon - 0.0010,
          type: PlaceType.mechanic,
          phone: '+20 122 999 8888',
          openingHours: '10:00 AM – 08:00 PM',
          isMock: true,
        ),
      ];

  // ── Try to fetch REAL places from Overpass API ────────────────────────────
  static Future<List<NearbyPlace>?> tryFetchReal({
    required double lat,
    required double lon,
    int radius = 10000, // Increased to 10km for better coverage
  }) async {
    final query = '''
[out:json][timeout:15];
(
  node["shop"="car_repair"](around:$radius,$lat,$lon);
  way["shop"="car_repair"](around:$radius,$lat,$lon);
  node["amenity"="car_repair"](around:$radius,$lat,$lon);
  way["amenity"="car_repair"](around:$radius,$lat,$lon);
  node["craft"="car_repair"](around:$radius,$lat,$lon);
  way["craft"="car_repair"](around:$radius,$lat,$lon);
  node["shop"="car_parts"](around:$radius,$lat,$lon);
  way["shop"="car_parts"](around:$radius,$lat,$lon);
  node["shop"="tyres"](around:$radius,$lat,$lon);
  way["shop"="tyres"](around:$radius,$lat,$lon);
  node["service"="car_repair"](around:$radius,$lat,$lon);
  way["service"="car_repair"](around:$radius,$lat,$lon);
);
out center;
''';

    final endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://lz4.overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://z.overpass-api.de/api/interpreter'
    ];

    Map<String, dynamic>? json;

    for (final url in endpoints) {
      try {
        final res = await http
            .post(Uri.parse(url), body: {'data': query})
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          json = jsonDecode(res.body) as Map<String, dynamic>;
          break; // Succeeded! Stop trying mirrors
        }
      } catch (_) {
        // Try next mirror
      }
    }

    if (json == null) return null;

    try {
      final elements = (json['elements'] as List?) ?? [];
      final places = <NearbyPlace>[];

      for (final element in elements) {
        final tags = (element['tags'] as Map<String, dynamic>?) ?? {};

        double? eLat;
        double? eLon;
        if (element['type'] == 'node') {
          eLat = (element['lat'] as num?)?.toDouble();
          eLon = (element['lon'] as num?)?.toDouble();
        } else if (element['type'] == 'way') {
          final center = element['center'] as Map<String, dynamic>?;
          eLat = (center?['lat'] as num?)?.toDouble();
          eLon = (center?['lon'] as num?)?.toDouble();
        }

        if (eLat == null || eLon == null || !eLat.isFinite || !eLon.isFinite) {
          continue;
        }

        final name = tags['name'] as String? ??
            tags['name:en'] as String? ??
            tags['name:ar'] as String? ??
            'مركز صيانة سيارات';

        final shop = tags['shop'] as String?;
        final isPartsOrTyres = shop == 'car_parts' || shop == 'tyres';
        final type = isPartsOrTyres ? PlaceType.partsStore : PlaceType.mechanic;

        final phone = tags['phone'] as String? ?? tags['contact:phone'] as String?;
        final openingHours = tags['opening_hours'] as String?;

        places.add(NearbyPlace(
          name: name,
          lat: eLat,
          lon: eLon,
          type: type,
          phone: phone,
          openingHours: openingHours,
          isMock: false,
        ));
      }

      // ── Graduation Project Fallback ──
      // If OpenStreetMap data is sparse in this specific area, we inject dynamic
      // mock data around the coordinates so the demo never looks empty.
      if (places.length < 3) {
        places.addAll(mockMechanics(lat, lon));
      }

      return places;
    } catch (_) {
      return null;
    }
  }
}
