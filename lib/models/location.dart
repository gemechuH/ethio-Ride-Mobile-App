class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeId;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeId,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'placeId': placeId,
  };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    address: json['address'] as String,
    placeId: json['placeId'] as String?,
  );

  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeId,
  }) => Location(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    placeId: placeId ?? this.placeId,
  );
}
