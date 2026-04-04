// To parse this JSON data, do
//
//     final dtcCodeModel = dtcCodeModelFromJson(jsonString);

import 'dart:convert';

DtcCodeModel dtcCodeModelFromJson(String str) => DtcCodeModel.fromJson(json.decode(str));

// String dtcCodeModelToJson(DtcCodeModel data) => json.encode(data.toJson());

class DtcCodeModel {
    String? criticalLevel;
    String? description;
    String? dtcCode;
    String? longDescription;
    String? reason;
    String? repair;

    DtcCodeModel({
        this.criticalLevel,
        this.description,
        this.dtcCode,
        this.longDescription,
        this.reason,
        this.repair,
    });

    factory DtcCodeModel.fromJson(Map<String, dynamic> json) => DtcCodeModel(
        criticalLevel: json["critical_level"],
        description: json["description"],
        dtcCode: json["dtc_code"],
        longDescription: json["long_description"],
        reason: json["reason"] == null ? '' : List<String>.from(json["reason"]!.map((x) => x)).join(', '),
        repair: json["repair"] == null ? '' : List<String>.from(json["repair"]!.map((x) => x)).join(', '),
     );

    // Map<String, dynamic> toJson() => {
    //     "critical_level": criticalLevel,
    //     "description": description,
    //     "dtc_code": dtcCode,
    //     "long_description": longDescription,
    //     "reason": reason == null ? [] : List<dynamic>.from(reason!.map((x) => x)),
    //     "repair": repair == null ? [] : List<dynamic>.from(repair!.map((x) => x)),
    // };
}
