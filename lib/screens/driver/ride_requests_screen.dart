import 'package:flutter/material.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/driver/active_trip_screen.dart';

class RideRequestsScreen extends StatefulWidget {
  final String userId;

  const RideRequestsScreen({super.key, required this.userId});

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> {
  List<Ride> _pendingRides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    final rideService = RideService();
    final allRides = await rideService.getActiveRides();
    _pendingRides = allRides.where((r) => r.status == 'pending').toList();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _acceptRide(String rideId) async {
    final rideService = RideService();
    await rideService.acceptRide(rideId, widget.userId);
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ActiveTripScreen(rideId: rideId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Requests'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : _pendingRides.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('No pending requests', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingRides.length,
                  itemBuilder: (context, index) => _buildRideRequestCard(_pendingRides[index], theme),
                ),
    );
  }

  Widget _buildRideRequestCard(Ride ride, ThemeData theme) {
    return FutureBuilder<User?>(
      future: UserService().getUserById(ride.passengerId),
      builder: (context, snapshot) {
        final passenger = snapshot.data;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(passenger?.name ?? 'Passenger', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: theme.colorScheme.secondary),
                            const SizedBox(width: 4),
                            Text('${passenger?.rating.toStringAsFixed(1) ?? '5.0'}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.my_location, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ride.pickupLocation.address, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ride.destinationLocation.address, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text('${ride.distance.toStringAsFixed(1)} km', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Fare', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text('${ride.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Accept Ride',
                onPressed: () => _acceptRide(ride.id),
                icon: Icons.check_circle,
              ),
            ],
          ),
        );
      },
    );
  }
}
