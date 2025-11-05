import 'package:flutter/material.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/passenger/payment_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveRideScreen extends StatefulWidget {
  final String rideId;

  const ActiveRideScreen({super.key, required this.rideId});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  Ride? _ride;
  User? _driver;
  Driver? _driverDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRideData();
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _loadRideData();
        if (_ride?.status == 'pending' || _ride?.status == 'accepted' || _ride?.status == 'in_progress') {
          _startPolling();
        }
      }
    });
  }

  Future<void> _loadRideData() async {
    final rideService = RideService();
    final userService = UserService();
    final driverService = DriverService();

    _ride = await rideService.getRideById(widget.rideId);
    
    if (_ride?.driverId != null) {
      _driver = await userService.getUserById(_ride!.driverId!);
      _driverDetails = await driverService.getDriverByUserId(_ride!.driverId!);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (_ride?.status == 'completed') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PaymentScreen(ride: _ride!)));
      }
    }
  }

  Future<void> _cancelRide() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      final rideService = RideService();
      await rideService.cancelRide(widget.rideId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _makeCall() async {
    final phoneNumber = _driver?.phone ?? '+251911000000';
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
        appBar: AppBar(title: const Text('Active Ride')),
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    if (_ride == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Ride')),
        body: const Center(child: Text('Ride not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Ride'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
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
                        Text('Tracking...', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                  if (_ride!.status != 'pending')
                    Positioned(
                      top: 120,
                      left: MediaQuery.of(context).size.width / 2 - 20,
                      child: Icon(Icons.local_taxi, size: 40, color: theme.colorScheme.primary),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(theme),
                  const SizedBox(height: 20),
                  _buildRouteCard(theme),
                  const SizedBox(height: 20),
                  if (_driver != null) _buildDriverCard(theme),
                  const SizedBox(height: 20),
                  if (_ride!.status == 'pending')
                    CustomButton(
                      text: 'Cancel Ride',
                      onPressed: _cancelRide,
                      isPrimary: false,
                      isOutlined: true,
                      icon: Icons.cancel,
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
    IconData statusIcon = Icons.hourglass_empty;

    switch (_ride!.status) {
      case 'pending':
        statusText = 'Finding a driver...';
        statusIcon = Icons.search;
        break;
      case 'accepted':
        statusText = 'Driver is on the way';
        statusIcon = Icons.directions_car;
        break;
      case 'in_progress':
        statusText = 'Trip in progress';
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.navigation;
        break;
      case 'completed':
        statusText = 'Trip completed';
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
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
          Icon(statusIcon, size: 32, color: statusColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(statusText, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
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
              Expanded(
                child: Text(_ride!.pickupLocation.address, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
              ),
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
              Expanded(
                child: Text(_ride!.destinationLocation.address, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
              ),
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
                  Text('Fare', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Text('${_ride!.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme) {
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
          Text('Driver Details', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                    Text(_driver!.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_driverDetails?.vehicleModel ?? 'Vehicle'} • ${_driverDetails?.vehicleColor ?? ''}', style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text('${_driver!.rating.toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
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
}
