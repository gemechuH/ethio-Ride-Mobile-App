import 'package:flutter/material.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/screens/admin/manage_users_screen.dart';
import 'package:journeysync/screens/admin/manage_rides_screen.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/auth_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _totalPassengers = 0;
  int _totalDrivers = 0;
  int _totalRides = 0;
  int _activeRides = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final userService = UserService();
    final rideService = RideService();

    final passengers = await userService.getUsersByRole('passenger');
    final drivers = await userService.getUsersByRole('driver');
    final allRides = await rideService.getAllRides();
    final activeRidesList = await rideService.getActiveRides();

    _totalPassengers = passengers.length;
    _totalDrivers = drivers.length;
    _totalRides = allRides.length;
    _activeRides = activeRidesList.length;
    _totalRevenue = allRides
        .where((r) => r.status == 'completed')
        .fold(0.0, (sum, r) => sum + r.fare);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final userService = UserService();
    await userService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                          theme,
                          'Total Passengers',
                          '$_totalPassengers',
                          Icons.people,
                          theme.colorScheme.primary),
                      _buildStatCard(theme, 'Total Drivers', '$_totalDrivers',
                          Icons.local_taxi, theme.colorScheme.secondary),
                      _buildStatCard(theme, 'Total Rides', '$_totalRides',
                          Icons.directions_car, theme.colorScheme.tertiary),
                      _buildStatCard(theme, 'Active Rides', '$_activeRides',
                          Icons.navigation, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Revenue',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.9))),
                            const SizedBox(height: 8),
                            Text('${_totalRevenue.toStringAsFixed(2)} ETB',
                                style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Icon(Icons.account_balance_wallet,
                            size: 59,
                            color: Colors.white.withValues(alpha: 0.3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Management',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildManagementCard(theme, 'Manage Users',
                      'View and manage passengers & drivers', Icons.people, () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildManagementCard(theme, 'Manage Rides',
                      'View all rides and live tracking', Icons.map, () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ManageRidesScreen()));
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
      ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildManagementCard(ThemeData theme, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: theme.colorScheme.onPrimaryContainer, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
