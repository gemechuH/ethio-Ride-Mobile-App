import 'package:flutter/material.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/driver/ride_requests_screen.dart';
import 'package:journeysync/screens/driver/active_trip_screen.dart';
import 'package:journeysync/screens/driver/earnings_screen.dart';
import 'package:journeysync/screens/driver/driver_profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final String userId;

  const DriverHomeScreen({super.key, required this.userId});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  User? _currentUser;
  Driver? _driverDetails;
  List<Ride> _pendingRides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userService = UserService();
    final driverService = DriverService();
    final rideService = RideService();

    _currentUser = await userService.getUserById(widget.userId);
    _driverDetails = await driverService.getDriverByUserId(widget.userId);

    final activeRide = await rideService.getActiveRideForDriver(widget.userId);
    if (activeRide != null && mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ActiveTripScreen(rideId: activeRide.id)));
    }

    final allRides = await rideService.getActiveRides();
    _pendingRides = allRides.where((r) => r.status == 'pending').toList();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleOnlineStatus() async {
    if (_driverDetails == null) return;

    final driverService = DriverService();
    await driverService.toggleOnlineStatus(_driverDetails!.id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('EthioRide Driver',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EarningsScreen(userId: widget.userId))),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DriverProfileScreen(userId: widget.userId))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${_currentUser?.name ?? 'Driver'}!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              '${_driverDetails?.vehicleModel ?? 'Vehicle'} • ${_driverDetails?.vehiclePlate ?? ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9)),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.local_taxi,
                            size: 32, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          theme,
                          'Total Rides',
                          '${_driverDetails?.totalRides ?? 0}',
                          Icons.directions_car),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.3)),
                      _buildStatItem(
                          theme,
                          'Rating',
                          '${_currentUser?.rating.toStringAsFixed(1) ?? '5.0'}',
                          Icons.star),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.3)),
                      _buildStatItem(
                          theme,
                          'Earnings',
                          '${_driverDetails?.totalEarnings.toStringAsFixed(0) ?? '0'} ETB',
                          Icons.account_balance_wallet),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _driverDetails?.isOnline == true
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _driverDetails?.isOnline == true
                            ? theme.colorScheme.primary
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _driverDetails?.isOnline == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _driverDetails?.isOnline == true
                              ? theme.colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _driverDetails?.isOnline == true
                                ? 'You are Online'
                                : 'You are Offline',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _toggleOnlineStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _driverDetails?.isOnline == true
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                      _driverDetails?.isOnline == true
                          ? 'Go Offline'
                          : 'Go Online',
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_driverDetails?.isOnline == true) ...[
              CustomButton(
                text: 'View Ride Requests (${_pendingRides.length})',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RideRequestsScreen(userId: widget.userId))),
                icon: Icons.notifications_active,
              ),
              const SizedBox(height: 16),
            ],
            Text('Quick Actions',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildActionCard(
                        theme,
                        'Earnings',
                        Icons.account_balance_wallet,
                        theme.colorScheme.primary,
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                EarningsScreen(userId: widget.userId))))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildActionCard(
                        theme,
                        'Profile',
                        Icons.person,
                        theme.colorScheme.secondary,
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                DriverProfileScreen(userId: widget.userId))))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildActionCard(ThemeData theme, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
