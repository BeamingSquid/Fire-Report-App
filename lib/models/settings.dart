class AppSettings {
  final String vehicleReg;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleColor;
  final String r1Name;
  final String r1Surname;
  final String r1CallSign;
  final String r1Quals;
  final String r2Name;
  final String r2Surname;
  final String r2CallSign;

  const AppSettings({
    this.vehicleReg = 'DCH 562 FS',
    this.vehicleMake = 'Nissan',
    this.vehicleModel = 'X-Trail',
    this.vehicleColor = 'Silver',
    this.r1Name = 'Kevin',
    this.r1Surname = 'Oosthuizen',
    this.r1CallSign = 'KO',
    this.r1Quals = 'Fire Fighter 1, Fire Fighter 2, HazMat Awareness, HazMat Operations',
    this.r2Name = 'Lea',
    this.r2Surname = 'Olivier',
    this.r2CallSign = 'LO',
  });

  Map<String, dynamic> toJson() => {
    'vehicleReg': vehicleReg,
    'vehicleMake': vehicleMake,
    'vehicleModel': vehicleModel,
    'vehicleColor': vehicleColor,
    'r1Name': r1Name,
    'r1Surname': r1Surname,
    'r1CallSign': r1CallSign,
    'r1Quals': r1Quals,
    'r2Name': r2Name,
    'r2Surname': r2Surname,
    'r2CallSign': r2CallSign,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    vehicleReg: json['vehicleReg'] as String? ?? 'DCH 562 FS',
    vehicleMake: json['vehicleMake'] as String? ?? 'Nissan',
    vehicleModel: json['vehicleModel'] as String? ?? 'X-Trail',
    vehicleColor: json['vehicleColor'] as String? ?? 'Silver',
    r1Name: json['r1Name'] as String? ?? 'Kevin',
    r1Surname: json['r1Surname'] as String? ?? 'Oosthuizen',
    r1CallSign: json['r1CallSign'] as String? ?? 'KO',
    r1Quals: json['r1Quals'] as String? ?? 'Fire Fighter 1, Fire Fighter 2, HazMat Awareness, HazMat Operations',
    r2Name: json['r2Name'] as String? ?? 'Lea',
    r2Surname: json['r2Surname'] as String? ?? 'Olivier',
    r2CallSign: json['r2CallSign'] as String? ?? 'LO',
  );

  AppSettings copyWith({
    String? vehicleReg,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleColor,
    String? r1Name,
    String? r1Surname,
    String? r1CallSign,
    String? r1Quals,
    String? r2Name,
    String? r2Surname,
    String? r2CallSign,
  }) {
    return AppSettings(
      vehicleReg: vehicleReg ?? this.vehicleReg,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      r1Name: r1Name ?? this.r1Name,
      r1Surname: r1Surname ?? this.r1Surname,
      r1CallSign: r1CallSign ?? this.r1CallSign,
      r1Quals: r1Quals ?? this.r1Quals,
      r2Name: r2Name ?? this.r2Name,
      r2Surname: r2Surname ?? this.r2Surname,
      r2CallSign: r2CallSign ?? this.r2CallSign,
    );
  }
}
