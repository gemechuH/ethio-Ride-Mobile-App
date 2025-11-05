import 'package:flutter/material.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/models/location.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/passenger/ride_request_screen.dart';
import 'package:journeysync/screens/passenger/active_ride_screen.dart';
import 'package:journeysync/screens/passenger/ride_history_screen.dart';
import 'package:journeysync/screens/passenger/passenger_profile_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  final String userId;

  const PassengerHomeScreen({super.key, required this.userId});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  User? _currentUser;
  List<Driver> _nearbyDrivers = [];
  bool _isLoading = true;
  final Location _currentLocation = Location(latitude: 9.0320, longitude: 38.7469, address: 'Bole, Addis Ababa');

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
    _nearbyDrivers = await driverService.getNearbyDrivers(_currentLocation, radiusKm: 10.0);
    
    final activeRide = await rideService.getActiveRideForPassenger(widget.userId);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (activeRide != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ActiveRideScreen(rideId: activeRide.id)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('EthioRide', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideHistoryScreen(userId: widget.userId))),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PassengerProfileScreen(userId: widget.userId))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 400,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('Bole, Addis Ababa', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                  ..._nearbyDrivers.take(5).map((driver) => Positioned(
                    top: 100 + (_nearbyDrivers.indexOf(driver) * 40.0),
                    left: 50 + (_nearbyDrivers.indexOf(driver) * 50.0),
                    child: Icon(Icons.local_taxi, size: 32, color: theme.colorScheme.primary),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${_currentUser?.name ?? 'User'}!', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${_nearbyDrivers.length} drivers available nearby', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Request a Ride',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideRequestScreen(userId: widget.userId, currentLocation: _currentLocation))),
                    icon: Icons.directions_car,
                  ),
                  const SizedBox(height: 24),
                  Text('Nearby Drivers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_nearbyDrivers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('No drivers available nearby', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._nearbyDrivers.take(5).map((driver) => _buildDriverCard(driver, theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(Driver driver, ThemeData theme) {
    return FutureBuilder<User?>(
      future: UserService().getUserById(driver.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
                child: Icon(Icons.person, size: 28, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Driver', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${driver.vehicleModel} • ${driver.vehicleColor}', style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text('${user?.rating.toStringAsFixed(1) ?? '5.0'}', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Online', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
