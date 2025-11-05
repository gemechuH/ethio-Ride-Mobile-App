class Payment {
  final String id;
  final String rideId;
  final String passengerId;
  final String driverId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'rideId': rideId,
    'passengerId': passengerId,
    'driverId': driverId,
    'amount': amount,
    'method': method,
    'status': status,
    'transactionId': transactionId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String,
    rideId: json['rideId'] as String,
    passengerId: json['passengerId'] as String,
    driverId: json['driverId'] as String,
    amount: (json['amount'] as num).toDouble(),
    method: json['method'] as String,
    status: json['status'] as String,
    transactionId: json['transactionId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Payment copyWith({
    String? id,
    String? rideId,
    String? passengerId,
    String? driverId,
    double? amount,
    String? method,
    String? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Payment(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    passengerId: passengerId ?? this.passengerId,
    driverId: driverId ?? this.driverId,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    status: status ?? this.status,
    transactionId: transactionId ?? this.transactionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
