class CarDataModel {
  final int? id;
  final String? userId;
  final String? carYear;
  final double? enginePower;
  final double? engineCoolantTemp;
  final double? engineLoad;
  final double? engineRPM;
  final double? airIntakeTemp;
  final double? speed;
  final double? shortTermFuelBank1;
  final double? throttlePosition;
  final double? timingAdvance;
  final String? troubleCode;
  final String? description;
  final DateTime? date;

  CarDataModel({
    this.id,
    this.userId,
    this.carYear,
    this.enginePower,
    this.engineCoolantTemp,
    this.engineLoad,
    this.engineRPM,
    this.airIntakeTemp,
    this.speed,
    this.shortTermFuelBank1,
    this.throttlePosition,
    this.timingAdvance,
    this.troubleCode,
    this.description,
    this.date,
  });

  factory CarDataModel.fromJson(Map<String, dynamic> json) {
    return CarDataModel(
      id: json['id'],
      userId: json['user_id'],
      carYear: json['carYear']?.toString(),
      enginePower: (json['enginePower'] as num?)?.toDouble(),
      engineCoolantTemp: (json['engineCoolantTemp'] as num?)?.toDouble(),
      engineLoad: (json['engineLoad'] as num?)?.toDouble(),
      engineRPM: (json['engineRPM'] as num?)?.toDouble(),
      airIntakeTemp: (json['airIntakeTemp'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      shortTermFuelBank1: (json['shortTermFuelBank1'] as num?)?.toDouble(),
      throttlePosition: (json['throttlePosition'] as num?)?.toDouble(),
      timingAdvance: (json['timingAdvance'] as num?)?.toDouble(),
      troubleCode: json['troubleCode'],
      description: json['description'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carYear': carYear ?? "",
      'enginePower': enginePower ?? 0.0,
      'engineCoolantTemp': engineCoolantTemp ?? 0.0,
      'engineLoad': engineLoad ?? 0.0,
      'engineRPM': engineRPM ?? 0.0,
      'airIntakeTemp': airIntakeTemp ?? 0.0,
      'speed': speed ?? 0.0,
      'shortTermFuelBank1': shortTermFuelBank1 ?? 0.0,
      'throttlePosition': throttlePosition ?? 0.0,
      'timingAdvance': timingAdvance ?? 0.0,
      'troubleCode': troubleCode ?? "",
      'description': description ?? "",
      // User_id and Date will be set by the .NET backend using the JWT token and UtcNow respectively.
    };
  }
}
