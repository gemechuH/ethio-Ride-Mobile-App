import 'package:flutter/material.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveTripScreen extends StatefulWidget {
  final String rideId;

  const ActiveTripScreen({super.key, required this.rideId});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  Ride? _ride;
  User? _passenger;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRideData();
  }

  Future<void> _loadRideData() async {
    setState(() => _isLoading = true);
    final rideService = RideService();
    final userService = UserService();

    _ride = await rideService.getRideById(widget.rideId);
    if (_ride != null) {
      _passenger = await userService.getUserById(_ride!.passengerId);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _startTrip() async {
    final rideService = RideService();
    await rideService.startRide(widget.rideId);
    await _loadRideData();
  }

  Future<void> _completeTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Trip'),
        content: const Text('Are you sure you want to complete this trip?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      final rideService = RideService();
      final driverService = DriverService();
      
      await rideService.completeRide(widget.rideId);
      
      final driver = await driverService.getDriverByUserId(_ride!.driverId!);
      if (driver != null) {
        await driverService.updateDriver(driver.copyWith(
          totalEarnings: driver.totalEarnings + _ride!.fare,
          totalRides: driver.totalRides + 1,
        ));
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip completed successfully!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _makeCall() async {
    final phoneNumber = _passenger?.phone ?? '+251911000000';
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Trip')),
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    if (_ride == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Trip')),
        body: const Center(child: Text('Trip not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Trip'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.navigation, size: 80, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Navigate to ${_ride!.status == 'accepted' ? 'Pickup' : 'Destination'}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(theme),
                  const SizedBox(height: 20),
                  if (_passenger != null) _buildPassengerCard(theme),
                  const SizedBox(height: 20),
                  _buildRouteCard(theme),
                  const SizedBox(height: 20),
                  if (_ride!.status == 'accepted')
                    CustomButton(
                      text: 'Start Trip',
                      onPressed: _startTrip,
                      icon: Icons.play_arrow,
                    )
                  else if (_ride!.status == 'in_progress')
                    CustomButton(
                      text: 'Complete Trip',
                      onPressed: _completeTrip,
                      icon: Icons.check_circle,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    String statusText = '';
    Color statusColor = theme.colorScheme.primary;

    if (_ride!.status == 'accepted') {
      statusText = 'Heading to pickup';
    } else if (_ride!.status == 'in_progress') {
      statusText = 'Trip in progress';
      statusColor = theme.colorScheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car, size: 32, color: statusColor),
          const SizedBox(width: 16),
          Text(statusText, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Passenger', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 32, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_passenger!.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text('${_passenger!.rating.toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.phone, color: theme.colorScheme.primary),
                onPressed: _makeCall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(_ride!.pickupLocation.address, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Column(
              children: List.generate(3, (_) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: 2,
                height: 4,
                color: Colors.grey.withValues(alpha: 0.4),
              )),
            ),
          ),
          Row(
            children: [
              Icon(Icons.location_on, color: theme.colorScheme.tertiary, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(_ride!.destinationLocation.address, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distance', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Text('${_ride!.distance.toStringAsFixed(1)} km', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Earning', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Text('${_ride!.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
