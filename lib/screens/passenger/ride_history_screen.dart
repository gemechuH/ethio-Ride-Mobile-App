import 'package:flutter/material.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:intl/intl.dart';

class RideHistoryScreen extends StatefulWidget {
  final String userId;

  const RideHistoryScreen({super.key, required this.userId});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<Ride> _rides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    final rideService = RideService();
    _rides = await rideService.getRidesByPassengerId(widget.userId);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : _rides.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('No rides yet', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rides.length,
                  itemBuilder: (context, index) => _buildRideCard(_rides[index], theme),
                ),
    );
  }

  Widget _buildRideCard(Ride ride, ThemeData theme) {
    return FutureBuilder<User?>(
      future: ride.driverId != null ? UserService().getUserById(ride.driverId!) : null,
      builder: (context, snapshot) {
        final driver = snapshot.data;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM dd, yyyy • hh:mm a').format(ride.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ride.status, theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(ride.status.toUpperCase(), style: theme.textTheme.bodySmall?.copyWith(color: _getStatusColor(ride.status, theme), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              if (driver != null) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(driver.name, style: theme.textTheme.bodySmall),
                      ],
                    ),
                    Text('${ride.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'completed':
        return theme.colorScheme.primary;
      case 'cancelled':
        return theme.colorScheme.error;
      case 'in_progress':
        return theme.colorScheme.secondary;
      default:
        return Colors.grey;
    }
  }
}
