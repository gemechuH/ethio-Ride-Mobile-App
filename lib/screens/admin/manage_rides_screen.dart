import 'package:flutter/material.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:intl/intl.dart';

class ManageRidesScreen extends StatefulWidget {
  const ManageRidesScreen({super.key});

  @override
  State<ManageRidesScreen> createState() => _ManageRidesScreenState();
}

class _ManageRidesScreenState extends State<ManageRidesScreen> {
  List<Ride> _allRides = [];
  List<Ride> _filteredRides = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    final rideService = RideService();
    _allRides = await rideService.getAllRides();
    _allRides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _filterRides();
    if (mounted) setState(() => _isLoading = false);
  }

  void _filterRides() {
    if (_filterStatus == 'all') {
      _filteredRides = _allRides;
    } else {
      _filteredRides = _allRides.where((r) => r.status == _filterStatus).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rides'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(theme, 'All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(theme, 'Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip(theme, 'Active', 'accepted'),
                  const SizedBox(width: 8),
                  _buildFilterChip(theme, 'In Progress', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip(theme, 'Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip(theme, 'Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : _filteredRides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No rides found', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRides.length,
                        itemBuilder: (context, index) => _buildRideCard(_filteredRides[index], theme),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
          _filterRides();
        });
      },
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurface),
    );
  }

  Widget _buildRideCard(Ride ride, ThemeData theme) {
    return FutureBuilder<List<User?>>(
      future: Future.wait([
        UserService().getUserById(ride.passengerId),
        ride.driverId != null ? UserService().getUserById(ride.driverId!) : Future.value(null),
      ]),
      builder: (context, snapshot) {
        final passenger = snapshot.data?[0];
        final driver = snapshot.data?[1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  Icon(Icons.my_location, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ride.pickupLocation.address, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ride.destinationLocation.address, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Passenger', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text(passenger?.name ?? 'Unknown', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Driver', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text(driver?.name ?? 'Not assigned', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Fare', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text('${ride.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                ],
              ),
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
      case 'accepted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
