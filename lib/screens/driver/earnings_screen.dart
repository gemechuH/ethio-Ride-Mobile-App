import 'package:flutter/material.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends StatefulWidget {
  final String userId;

  const EarningsScreen({super.key, required this.userId});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  Driver? _driver;
  List<Ride> _completedRides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final driverService = DriverService();
    final rideService = RideService();

    _driver = await driverService.getDriverByUserId(widget.userId);
    final allRides = await rideService.getRidesByDriverId(widget.userId);
    _completedRides = allRides.where((r) => r.status == 'completed').toList();

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Earnings')),
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
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
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text('Total Earnings', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('${_driver?.totalEarnings.toStringAsFixed(2) ?? '0.00'} ETB', style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Rides', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                          const SizedBox(height: 4),
                          Text('${_driver?.totalRides ?? 0}', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Avg per Ride', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                          const SizedBox(height: 4),
                          Text('${(_driver?.totalRides ?? 0) > 0 ? ((_driver!.totalEarnings) / _driver!.totalRides).toStringAsFixed(0) : '0'} ETB', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Trips', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_completedRides.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No completed trips yet', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ),
              )
            else
              ..._completedRides.map((ride) => _buildRideCard(ride, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(Ride ride, ThemeData theme) {
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
              Text(DateFormat('MMM dd, yyyy').format(ride.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text('${ride.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
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
          const SizedBox(height: 8),
          Text('${ride.distance.toStringAsFixed(1)} km', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
