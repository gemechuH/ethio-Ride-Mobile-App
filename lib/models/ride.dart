import 'package:journeysync/models/location.dart';

class Ride {
  final String id;
  final String passengerId;
  final String? driverId;
  final Location pickupLocation;
  final Location destinationLocation;
  final String status;
  final double fare;
  final String paymentMethod;
  final bool isPaid;
  final double distance;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ride({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    required this.fare,
    this.paymentMethod = 'cash',
    this.isPaid = false,
    required this.distance,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'passengerId': passengerId,
    'driverId': driverId,
    'pickupLocation': pickupLocation.toJson(),
    'destinationLocation': destinationLocation.toJson(),
    'status': status,
    'fare': fare,
    'paymentMethod': paymentMethod,
    'isPaid': isPaid,
    'distance': distance,
    'acceptedAt': acceptedAt?.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
    id: json['id'] as String,
    passengerId: json['passengerId'] as String,
    driverId: json['driverId'] as String?,
    pickupLocation: Location.fromJson(json['pickupLocation'] as Map<String, dynamic>),
    destinationLocation: Location.fromJson(json['destinationLocation'] as Map<String, dynamic>),
    status: json['status'] as String,
    fare: (json['fare'] as num).toDouble(),
    paymentMethod: json['paymentMethod'] as String? ?? 'cash',
    isPaid: json['isPaid'] as bool? ?? false,
    distance: (json['distance'] as num).toDouble(),
    acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Ride copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    Location? pickupLocation,
    Location? destinationLocation,
    String? status,
    double? fare,
    String? paymentMethod,
    bool? isPaid,
    double? distance,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Ride(
    id: id ?? this.id,
    passengerId: passengerId ?? this.passengerId,
    driverId: driverId ?? this.driverId,
    pickupLocation: pickupLocation ?? this.pickupLocation,
    destinationLocation: destinationLocation ?? this.destinationLocation,
    status: status ?? this.status,
    fare: fare ?? this.fare,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isPaid: isPaid ?? this.isPaid,
    distance: distance ?? this.distance,
    acceptedAt: acceptedAt ?? this.acceptedAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
