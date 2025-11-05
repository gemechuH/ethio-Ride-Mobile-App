import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journeysync/models/user.dart';

class UserService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';

  Future<void> _initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final existingUsers = prefs.getString(_usersKey);
    if (existingUsers != null) return;

    final now = DateTime.now();
    final sampleUsers = [
      User(id: 'admin1', name: 'Admin User', email: 'admin@ethioride.com', phone: '+251911123456', role: 'admin', rating: 5.0, createdAt: now, updatedAt: now),
      User(id: 'pass1', name: 'Abebe Kebede', email: 'abebe@example.com', phone: '+251911234567', role: 'passenger', rating: 4.8, createdAt: now, updatedAt: now),
      User(id: 'pass2', name: 'Tirunesh Dibaba', email: 'tirunesh@example.com', phone: '+251911345678', role: 'passenger', rating: 4.9, createdAt: now, updatedAt: now),
      User(id: 'pass3', name: 'Haile Gebrselassie', email: 'haile@example.com', phone: '+251911456789', role: 'passenger', rating: 5.0, createdAt: now, updatedAt: now),
      User(id: 'pass4', name: 'Almaz Ayana', email: 'almaz@example.com', phone: '+251911567890', role: 'passenger', rating: 4.7, createdAt: now, updatedAt: now),
      User(id: 'pass5', name: 'Kenenisa Bekele', email: 'kenenisa@example.com', phone: '+251911678901', role: 'passenger', rating: 4.8, createdAt: now, updatedAt: now),
      User(id: 'drv1', name: 'Dawit Teklu', email: 'dawit@example.com', phone: '+251922123456', role: 'driver', rating: 4.9, createdAt: now, updatedAt: now),
      User(id: 'drv2', name: 'Mulu Haile', email: 'mulu@example.com', phone: '+251922234567', role: 'driver', rating: 4.8, createdAt: now, updatedAt: now),
      User(id: 'drv3', name: 'Solomon Bekele', email: 'solomon@example.com', phone: '+251922345678', role: 'driver', rating: 4.7, createdAt: now, updatedAt: now),
      User(id: 'drv4', name: 'Kidist Alemayehu', email: 'kidist@example.com', phone: '+251922456789', role: 'driver', rating: 5.0, createdAt: now, updatedAt: now),
      User(id: 'drv5', name: 'Yohannes Berhanu', email: 'yohannes@example.com', phone: '+251922567890', role: 'driver', rating: 4.6, createdAt: now, updatedAt: now),
      User(id: 'drv6', name: 'Sara Gebre', email: 'sara@example.com', phone: '+251922678901', role: 'driver', rating: 4.9, createdAt: now, updatedAt: now),
      User(id: 'drv7', name: 'Getachew Tessema', email: 'getachew@example.com', phone: '+251922789012', role: 'driver', rating: 4.8, createdAt: now, updatedAt: now),
      User(id: 'drv8', name: 'Bethlehem Assefa', email: 'bethlehem@example.com', phone: '+251922890123', role: 'driver', rating: 4.7, createdAt: now, updatedAt: now),
      User(id: 'drv9', name: 'Tadesse Mekuria', email: 'tadesse@example.com', phone: '+251922901234', role: 'driver', rating: 4.9, createdAt: now, updatedAt: now),
      User(id: 'drv10', name: 'Hanna Girma', email: 'hanna@example.com', phone: '+251923012345', role: 'driver', rating: 5.0, createdAt: now, updatedAt: now),
    ];

    final usersJson = jsonEncode(sampleUsers.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  Future<User?> login(String email, String password) async {
    await _initializeSampleData();
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(usersJson);
      final users = decoded.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      final user = users.firstWhere((u) => u.email == email, orElse: () => users.first);
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<List<User>> getAllUsers() async {
    await _initializeSampleData();
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(usersJson);
      return decoded.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getUsersByRole(String role) async {
    final users = await getAllUsers();
    return users.where((u) => u.role == role).toList();
  }

  Future<void> updateUser(User user) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user.copyWith(updatedAt: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final usersJson = jsonEncode(users.map((u) => u.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
    }
  }

  Future<void> deleteUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.id == userId);
    final prefs = await SharedPreferences.getInstance();
    final usersJson = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }
}
