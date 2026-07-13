import 'dart:convert';

class Report {
  final String id;
  final String incidentId;
  final String incidentType;
  final DateTime date;
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
  final String startTime;
  final String onSceneTime;
  final String endTime;
  final String startKm;
  final String endKm;
  final String address;
  final String additionalResponders;
  final bool hasVictims;
  final String victimCount;
  final int triageP1;
  final int triageP2;
  final int triageP3;
  final int triageP4;
  final String description;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  Report({
    required this.id,
    required this.incidentId,
    this.incidentType = '',
    required this.date,
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
    this.startTime = '',
    this.onSceneTime = '',
    this.endTime = '',
    this.startKm = '',
    this.endKm = '',
    this.address = '',
    this.additionalResponders = '',
    this.hasVictims = false,
    this.victimCount = '',
    this.triageP1 = 0,
    this.triageP2 = 0,
    this.triageP3 = 0,
    this.triageP4 = 0,
    this.description = '',
    this.imagePaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Report copyWith({
    String? id,
    String? incidentId,
    String? incidentType,
    DateTime? date,
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
    String? startTime,
    String? onSceneTime,
    String? endTime,
    String? startKm,
    String? endKm,
    String? address,
    String? additionalResponders,
    bool? hasVictims,
    String? victimCount,
    int? triageP1,
    int? triageP2,
    int? triageP3,
    int? triageP4,
    String? description,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Report(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      incidentType: incidentType ?? this.incidentType,
      date: date ?? this.date,
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
      startTime: startTime ?? this.startTime,
      onSceneTime: onSceneTime ?? this.onSceneTime,
      endTime: endTime ?? this.endTime,
      startKm: startKm ?? this.startKm,
      endKm: endKm ?? this.endKm,
      address: address ?? this.address,
      additionalResponders: additionalResponders ?? this.additionalResponders,
      hasVictims: hasVictims ?? this.hasVictims,
      victimCount: victimCount ?? this.victimCount,
      triageP1: triageP1 ?? this.triageP1,
      triageP2: triageP2 ?? this.triageP2,
      triageP3: triageP3 ?? this.triageP3,
      triageP4: triageP4 ?? this.triageP4,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'incidentId': incidentId,
    'incidentType': incidentType,
    'date': date.toIso8601String(),
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
    'startTime': startTime,
    'onSceneTime': onSceneTime,
    'endTime': endTime,
    'startKm': startKm,
    'endKm': endKm,
    'address': address,
    'additionalResponders': additionalResponders,
    'hasVictims': hasVictims,
    'victimCount': victimCount,
    'triageP1': triageP1,
    'triageP2': triageP2,
    'triageP3': triageP3,
    'triageP4': triageP4,
    'description': description,
    'imagePaths': imagePaths,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'synced': synced,
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'] as String,
    incidentId: json['incidentId'] as String,
    incidentType: json['incidentType'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
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
    startTime: json['startTime'] as String? ?? '',
    onSceneTime: json['onSceneTime'] as String? ?? '',
    endTime: json['endTime'] as String? ?? '',
    startKm: json['startKm'] as String? ?? '',
    endKm: json['endKm'] as String? ?? '',
    address: json['address'] as String? ?? '',
    additionalResponders: json['additionalResponders'] as String? ?? '',
    hasVictims: json['hasVictims'] as bool? ?? false,
    victimCount: json['victimCount'] as String? ?? '',
    triageP1: json['triageP1'] as int? ?? 0,
    triageP2: json['triageP2'] as int? ?? 0,
    triageP3: json['triageP3'] as int? ?? 0,
    triageP4: json['triageP4'] as int? ?? 0,
    description: json['description'] as String? ?? '',
    imagePaths: (json['imagePaths'] as List<dynamic>?)?.cast<String>() ?? [],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    synced: json['synced'] as bool? ?? false,
  );

  String toJsonString() => jsonEncode(toJson());
  factory Report.fromJsonString(String s) => Report.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
