import 'package:journeysync/models/location.dart';

class Driver {
  final String id;
  final String userId;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleColor;
  final String vehicleType;
  final bool isOnline;
  final bool isVerified;
  final Location? currentLocation;
  final double totalEarnings;
  final int totalRides;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.userId,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleColor,
    required this.vehicleType,
    this.isOnline = false,
    this.isVerified = false,
    this.currentLocation,
    this.totalEarnings = 0.0,
    this.totalRides = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'vehicleModel': vehicleModel,
    'vehiclePlate': vehiclePlate,
    'vehicleColor': vehicleColor,
    'vehicleType': vehicleType,
    'isOnline': isOnline,
    'isVerified': isVerified,
    'currentLocation': currentLocation?.toJson(),
    'totalEarnings': totalEarnings,
    'totalRides': totalRides,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json['id'] as String,
    userId: json['userId'] as String,
    vehicleModel: json['vehicleModel'] as String,
    vehiclePlate: json['vehiclePlate'] as String,
    vehicleColor: json['vehicleColor'] as String,
    vehicleType: json['vehicleType'] as String,
    isOnline: json['isOnline'] as bool? ?? false,
    isVerified: json['isVerified'] as bool? ?? false,
    currentLocation: json['currentLocation'] != null 
        ? Location.fromJson(json['currentLocation'] as Map<String, dynamic>)
        : null,
    totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
    totalRides: json['totalRides'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Driver copyWith({
    String? id,
    String? userId,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    String? vehicleType,
    bool? isOnline,
    bool? isVerified,
    Location? currentLocation,
    double? totalEarnings,
    int? totalRides,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Driver(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    vehicleModel: vehicleModel ?? this.vehicleModel,
    vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    vehicleColor: vehicleColor ?? this.vehicleColor,
    vehicleType: vehicleType ?? this.vehicleType,
    isOnline: isOnline ?? this.isOnline,
    isVerified: isVerified ?? this.isVerified,
    currentLocation: currentLocation ?? this.currentLocation,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalRides: totalRides ?? this.totalRides,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
