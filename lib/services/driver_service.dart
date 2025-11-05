import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/models/location.dart';

class DriverService {
  static const String _driversKey = 'drivers';

  Future<void> _initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final existingDrivers = prefs.getString(_driversKey);
    if (existingDrivers != null) return;

    final now = DateTime.now();
    final sampleDrivers = [
      Driver(id: 'drvr1', userId: 'drv1', vehicleModel: 'Toyota Corolla', vehiclePlate: 'AA-3-12345', vehicleColor: 'White', vehicleType: 'Sedan', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0320, longitude: 38.7469, address: 'Bole, Addis Ababa'), totalEarnings: 12450.0, totalRides: 234, createdAt: now, updatedAt: now),
      Driver(id: 'drvr2', userId: 'drv2', vehicleModel: 'Hyundai Elantra', vehiclePlate: 'AA-3-23456', vehicleColor: 'Silver', vehicleType: 'Sedan', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0295, longitude: 38.7468, address: 'Megenagna, Addis Ababa'), totalEarnings: 18320.0, totalRides: 312, createdAt: now, updatedAt: now),
      Driver(id: 'drvr3', userId: 'drv3', vehicleModel: 'Suzuki Swift', vehiclePlate: 'AA-3-34567', vehicleColor: 'Red', vehicleType: 'Compact', isOnline: false, isVerified: true, currentLocation: Location(latitude: 9.0048, longitude: 38.7636, address: 'Piassa, Addis Ababa'), totalEarnings: 9870.0, totalRides: 178, createdAt: now, updatedAt: now),
      Driver(id: 'drvr4', userId: 'drv4', vehicleModel: 'Toyota Vitz', vehiclePlate: 'AA-3-45678', vehicleColor: 'Blue', vehicleType: 'Compact', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0145, longitude: 38.7597, address: 'Merkato, Addis Ababa'), totalEarnings: 21540.0, totalRides: 389, createdAt: now, updatedAt: now),
      Driver(id: 'drvr5', userId: 'drv5', vehicleModel: 'Nissan Sunny', vehiclePlate: 'AA-3-56789', vehicleColor: 'Black', vehicleType: 'Sedan', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0412, longitude: 38.7525, address: 'CMC, Addis Ababa'), totalEarnings: 15230.0, totalRides: 267, createdAt: now, updatedAt: now),
      Driver(id: 'drvr6', userId: 'drv6', vehicleModel: 'Honda Civic', vehiclePlate: 'AA-3-67890', vehicleColor: 'White', vehicleType: 'Sedan', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0250, longitude: 38.7489, address: 'Hayahulet, Addis Ababa'), totalEarnings: 19650.0, totalRides: 341, createdAt: now, updatedAt: now),
      Driver(id: 'drvr7', userId: 'drv7', vehicleModel: 'Mazda Demio', vehiclePlate: 'AA-3-78901', vehicleColor: 'Silver', vehicleType: 'Compact', isOnline: false, isVerified: true, currentLocation: Location(latitude: 9.0336, longitude: 38.7403, address: '22 Mazoria, Addis Ababa'), totalEarnings: 11780.0, totalRides: 198, createdAt: now, updatedAt: now),
      Driver(id: 'drvr8', userId: 'drv8', vehicleModel: 'Kia Rio', vehiclePlate: 'AA-3-89012', vehicleColor: 'Gray', vehicleType: 'Sedan', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0188, longitude: 38.7501, address: 'Arat Kilo, Addis Ababa'), totalEarnings: 16920.0, totalRides: 289, createdAt: now, updatedAt: now),
      Driver(id: 'drvr9', userId: 'drv9', vehicleModel: 'Toyota Yaris', vehiclePlate: 'AA-3-90123', vehicleColor: 'White', vehicleType: 'Compact', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0343, longitude: 38.7612, address: 'Sarbet, Addis Ababa'), totalEarnings: 14560.0, totalRides: 251, createdAt: now, updatedAt: now),
      Driver(id: 'drvr10', userId: 'drv10', vehicleModel: 'Volkswagen Polo', vehiclePlate: 'AA-3-01234', vehicleColor: 'Blue', vehicleType: 'Compact', isOnline: true, isVerified: true, currentLocation: Location(latitude: 9.0103, longitude: 38.7614, address: 'Lideta, Addis Ababa'), totalEarnings: 22340.0, totalRides: 412, createdAt: now, updatedAt: now),
    ];

    final driversJson = jsonEncode(sampleDrivers.map((d) => d.toJson()).toList());
    await prefs.setString(_driversKey, driversJson);
  }

  Future<List<Driver>> getAllDrivers() async {
    await _initializeSampleData();
    final prefs = await SharedPreferences.getInstance();
    final driversJson = prefs.getString(_driversKey);
    if (driversJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(driversJson);
      return decoded.map((json) => Driver.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Driver?> getDriverById(String id) async {
    final drivers = await getAllDrivers();
    try {
      return drivers.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Driver?> getDriverByUserId(String userId) async {
    final drivers = await getAllDrivers();
    try {
      return drivers.firstWhere((d) => d.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Driver>> getOnlineDrivers() async {
    final drivers = await getAllDrivers();
    return drivers.where((d) => d.isOnline && d.isVerified).toList();
  }

  Future<List<Driver>> getNearbyDrivers(Location userLocation, {double radiusKm = 5.0}) async {
    final onlineDrivers = await getOnlineDrivers();
    return onlineDrivers.where((d) {
      if (d.currentLocation == null) return false;
      final distance = _calculateDistance(
        userLocation.latitude, userLocation.longitude,
        d.currentLocation!.latitude, d.currentLocation!.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  Future<void> updateDriver(Driver driver) async {
    final drivers = await getAllDrivers();
    final index = drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      drivers[index] = driver.copyWith(updatedAt: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final driversJson = jsonEncode(drivers.map((d) => d.toJson()).toList());
      await prefs.setString(_driversKey, driversJson);
    }
  }

  Future<void> toggleOnlineStatus(String driverId) async {
    final driver = await getDriverById(driverId);
    if (driver != null) {
      await updateDriver(driver.copyWith(isOnline: !driver.isOnline));
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = 0.5 - (dLat / 2).abs() + (lat1 * lat2).abs() * (1 - (dLon / 2).abs());
    return earthRadius * 2 * a;
  }

  double _degreesToRadians(double degrees) => degrees * 3.14159265359 / 180.0;
}
