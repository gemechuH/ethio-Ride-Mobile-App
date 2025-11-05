import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/location.dart';

class RideService {
  static const String _ridesKey = 'rides';

  Future<void> _initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final existingRides = prefs.getString(_ridesKey);
    if (existingRides != null) return;

    final now = DateTime.now();
    final sampleRides = [
      Ride(id: 'ride1', passengerId: 'pass1', driverId: 'drv1', pickupLocation: Location(latitude: 9.0320, longitude: 38.7469, address: 'Bole, Addis Ababa'), destinationLocation: Location(latitude: 9.0048, longitude: 38.7636, address: 'Piassa, Addis Ababa'), status: 'completed', fare: 145.0, paymentMethod: 'cash', isPaid: true, distance: 4.2, acceptedAt: now.subtract(const Duration(hours: 2)), startedAt: now.subtract(const Duration(hours: 2, minutes: 5)), completedAt: now.subtract(const Duration(hours: 1, minutes: 45)), createdAt: now.subtract(const Duration(hours: 2)), updatedAt: now.subtract(const Duration(hours: 1, minutes: 45))),
      Ride(id: 'ride2', passengerId: 'pass2', driverId: 'drv2', pickupLocation: Location(latitude: 9.0295, longitude: 38.7468, address: 'Megenagna, Addis Ababa'), destinationLocation: Location(latitude: 9.0145, longitude: 38.7597, address: 'Merkato, Addis Ababa'), status: 'completed', fare: 98.0, paymentMethod: 'mobile_money', isPaid: true, distance: 2.8, acceptedAt: now.subtract(const Duration(hours: 5)), startedAt: now.subtract(const Duration(hours: 5, minutes: 3)), completedAt: now.subtract(const Duration(hours: 4, minutes: 50)), createdAt: now.subtract(const Duration(hours: 5)), updatedAt: now.subtract(const Duration(hours: 4, minutes: 50))),
      Ride(id: 'ride3', passengerId: 'pass3', driverId: 'drv4', pickupLocation: Location(latitude: 9.0412, longitude: 38.7525, address: 'CMC, Addis Ababa'), destinationLocation: Location(latitude: 9.0250, longitude: 38.7489, address: 'Hayahulet, Addis Ababa'), status: 'completed', fare: 85.0, paymentMethod: 'cash', isPaid: true, distance: 2.3, acceptedAt: now.subtract(const Duration(days: 1)), startedAt: now.subtract(const Duration(days: 1, minutes: 4)), completedAt: now.subtract(const Duration(days: 1, minutes: -15)), createdAt: now.subtract(const Duration(days: 1)), updatedAt: now.subtract(const Duration(days: 1, minutes: -15))),
      Ride(id: 'ride4', passengerId: 'pass4', driverId: 'drv5', pickupLocation: Location(latitude: 9.0188, longitude: 38.7501, address: 'Arat Kilo, Addis Ababa'), destinationLocation: Location(latitude: 9.0320, longitude: 38.7469, address: 'Bole, Addis Ababa'), status: 'completed', fare: 112.0, paymentMethod: 'mobile_money', isPaid: true, distance: 3.1, acceptedAt: now.subtract(const Duration(days: 2)), startedAt: now.subtract(const Duration(days: 2, minutes: 2)), completedAt: now.subtract(const Duration(days: 2, minutes: -18)), createdAt: now.subtract(const Duration(days: 2)), updatedAt: now.subtract(const Duration(days: 2, minutes: -18))),
      Ride(id: 'ride5', passengerId: 'pass5', driverId: 'drv6', pickupLocation: Location(latitude: 9.0336, longitude: 38.7403, address: '22 Mazoria, Addis Ababa'), destinationLocation: Location(latitude: 9.0103, longitude: 38.7614, address: 'Lideta, Addis Ababa'), status: 'completed', fare: 128.0, paymentMethod: 'cash', isPaid: true, distance: 3.6, acceptedAt: now.subtract(const Duration(days: 3)), startedAt: now.subtract(const Duration(days: 3, minutes: 5)), completedAt: now.subtract(const Duration(days: 3, minutes: -22)), createdAt: now.subtract(const Duration(days: 3)), updatedAt: now.subtract(const Duration(days: 3, minutes: -22))),
    ];

    final ridesJson = jsonEncode(sampleRides.map((r) => r.toJson()).toList());
    await prefs.setString(_ridesKey, ridesJson);
  }

  Future<List<Ride>> getAllRides() async {
    await _initializeSampleData();
    final prefs = await SharedPreferences.getInstance();
    final ridesJson = prefs.getString(_ridesKey);
    if (ridesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(ridesJson);
      return decoded.map((json) => Ride.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Ride?> getRideById(String id) async {
    final rides = await getAllRides();
    try {
      return rides.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Ride>> getRidesByPassengerId(String passengerId) async {
    final rides = await getAllRides();
    return rides.where((r) => r.passengerId == passengerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Ride>> getRidesByDriverId(String driverId) async {
    final rides = await getAllRides();
    return rides.where((r) => r.driverId == driverId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Ride>> getActiveRides() async {
    final rides = await getAllRides();
    return rides.where((r) => r.status == 'pending' || r.status == 'accepted' || r.status == 'in_progress').toList();
  }

  Future<Ride?> getActiveRideForPassenger(String passengerId) async {
    final rides = await getAllRides();
    try {
      return rides.firstWhere((r) => r.passengerId == passengerId && (r.status == 'pending' || r.status == 'accepted' || r.status == 'in_progress'));
    } catch (e) {
      return null;
    }
  }

  Future<Ride?> getActiveRideForDriver(String driverId) async {
    final rides = await getAllRides();
    try {
      return rides.firstWhere((r) => r.driverId == driverId && (r.status == 'accepted' || r.status == 'in_progress'));
    } catch (e) {
      return null;
    }
  }

  Future<String> createRide(String passengerId, Location pickup, Location destination) async {
    final rides = await getAllRides();
    final rideId = 'ride${DateTime.now().millisecondsSinceEpoch}';
    final distance = _calculateDistance(pickup.latitude, pickup.longitude, destination.latitude, destination.longitude);
    final fare = _calculateFare(distance);
    
    final newRide = Ride(
      id: rideId,
      passengerId: passengerId,
      pickupLocation: pickup,
      destinationLocation: destination,
      status: 'pending',
      fare: fare,
      distance: distance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    rides.add(newRide);
    final prefs = await SharedPreferences.getInstance();
    final ridesJson = jsonEncode(rides.map((r) => r.toJson()).toList());
    await prefs.setString(_ridesKey, ridesJson);
    return rideId;
  }

  Future<void> updateRide(Ride ride) async {
    final rides = await getAllRides();
    final index = rides.indexWhere((r) => r.id == ride.id);
    if (index != -1) {
      rides[index] = ride.copyWith(updatedAt: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final ridesJson = jsonEncode(rides.map((r) => r.toJson()).toList());
      await prefs.setString(_ridesKey, ridesJson);
    }
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    final ride = await getRideById(rideId);
    if (ride != null) {
      await updateRide(ride.copyWith(
        driverId: driverId,
        status: 'accepted',
        acceptedAt: DateTime.now(),
      ));
    }
  }

  Future<void> startRide(String rideId) async {
    final ride = await getRideById(rideId);
    if (ride != null) {
      await updateRide(ride.copyWith(
        status: 'in_progress',
        startedAt: DateTime.now(),
      ));
    }
  }

  Future<void> completeRide(String rideId) async {
    final ride = await getRideById(rideId);
    if (ride != null) {
      await updateRide(ride.copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
        isPaid: true,
      ));
    }
  }

  Future<void> cancelRide(String rideId) async {
    final ride = await getRideById(rideId);
    if (ride != null) {
      await updateRide(ride.copyWith(status: 'cancelled'));
    }
  }

  double calculateFareEstimate(Location pickup, Location destination) {
    final distance = _calculateDistance(pickup.latitude, pickup.longitude, destination.latitude, destination.longitude);
    return _calculateFare(distance);
  }

  double _calculateFare(double distanceKm) {
    const double basefare = 50.0;
    const double perKmRate = 25.0;
    return basefare + (distanceKm * perKmRate);
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180.0;
}
