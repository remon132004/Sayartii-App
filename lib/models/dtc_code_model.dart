import 'dart:convert';

DtcCodeModel dtcCodeModelFromJson(String str) =>
    DtcCodeModel.fromJson(json.decode(str));

/// Bilingual DTC code model.
/// The Flask backend now returns _ar / _en variants for every text field.
/// We pick the correct variant based on device locale at parse time.
class DtcCodeModel {
  String? criticalLevel;
  String? description;
  String? dtcCode;
  String? longDescription;
  String? drivingAdvice;
  List<String>? reasonList;
  List<String>? repairList;

  DtcCodeModel({
    this.criticalLevel,
    this.description,
    this.dtcCode,
    this.longDescription,
    this.drivingAdvice,
    this.reasonList,
    this.repairList,
  });

  /// [isAr] — pass `true` for Arabic, `false` for English.
  factory DtcCodeModel.fromJson(Map<String, dynamic> json,
      {bool isAr = false}) {
    // ── Bilingual helper ────────────────────────────────────────────────────
    String pickText(String key) {
      final arKey = '${key}_ar';
      final enKey = '${key}_en';
      if (json.containsKey(arKey) || json.containsKey(enKey)) {
        return isAr
            ? (json[arKey]?.toString() ?? json[enKey]?.toString() ?? '')
            : (json[enKey]?.toString() ?? json[arKey]?.toString() ?? '');
      }
      // Legacy single-language fallback
      return json[key]?.toString() ?? '';
    }

    List<String> pickList(String key) {
      final arKey = '${key}_ar';
      final enKey = '${key}_en';
      if (json.containsKey(arKey) || json.containsKey(enKey)) {
        final chosen = isAr ? json[arKey] : json[enKey];
        if (chosen is List) return List<String>.from(chosen.map((x) => x.toString()));
        final other = isAr ? json[enKey] : json[arKey];
        if (other is List) return List<String>.from(other.map((x) => x.toString()));
        return [];
      }
      // Legacy
      if (json[key] is List) {
        return List<String>.from((json[key] as List).map((x) => x.toString()));
      }
      return [];
    }

    return DtcCodeModel(
      criticalLevel:   json['critical_level']?.toString(),
      dtcCode:         json['dtc_code']?.toString(),
      description:     pickText('description'),
      longDescription: pickText('long_description'),
      drivingAdvice:   pickText('driving_advice'),
      reasonList:      pickList('reason'),
      repairList:      pickList('repair'),
    );
  }

  /// Convenience: comma-joined reasons for legacy widgets
  String get reason => reasonList?.join('، ') ?? '';

  /// Convenience: comma-joined repairs for legacy widgets
  String get repair => repairList?.join('، ') ?? '';
}
