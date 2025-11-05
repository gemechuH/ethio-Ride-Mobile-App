import 'package:flutter/material.dart';
import 'package:journeysync/models/location.dart';
import 'package:journeysync/services/ride_service.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/passenger/active_ride_screen.dart';

class RideRequestScreen extends StatefulWidget {
  final String userId;
  final Location currentLocation;

  const RideRequestScreen({super.key, required this.userId, required this.currentLocation});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  Location? _pickupLocation;
  Location? _destinationLocation;
  double? _estimatedFare;
  bool _isLoading = false;

  final List<Location> _popularLocations = [
    Location(latitude: 9.0320, longitude: 38.7469, address: 'Bole, Addis Ababa'),
    Location(latitude: 9.0048, longitude: 38.7636, address: 'Piassa, Addis Ababa'),
    Location(latitude: 9.0145, longitude: 38.7597, address: 'Merkato, Addis Ababa'),
    Location(latitude: 9.0412, longitude: 38.7525, address: 'CMC, Addis Ababa'),
    Location(latitude: 9.0295, longitude: 38.7468, address: 'Megenagna, Addis Ababa'),
    Location(latitude: 9.0250, longitude: 38.7489, address: 'Hayahulet, Addis Ababa'),
    Location(latitude: 9.0188, longitude: 38.7501, address: 'Arat Kilo, Addis Ababa'),
    Location(latitude: 9.0103, longitude: 38.7614, address: 'Lideta, Addis Ababa'),
  ];

  @override
  void initState() {
    super.initState();
    _pickupLocation = widget.currentLocation;
  }

  void _calculateFare() {
    if (_pickupLocation != null && _destinationLocation != null) {
      final rideService = RideService();
      setState(() {
        _estimatedFare = rideService.calculateFareEstimate(_pickupLocation!, _destinationLocation!);
      });
    }
  }

  Future<void> _requestRide() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final rideService = RideService();
    final rideId = await rideService.createRide(widget.userId, _pickupLocation!, _destinationLocation!);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ActiveRideScreen(rideId: rideId)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Ride'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 60, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text('Select your route', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationCard(
                    theme,
                    'Pickup Location',
                    _pickupLocation?.address ?? 'Select pickup',
                    Icons.my_location,
                    theme.colorScheme.primary,
                    () => _showLocationPicker(true),
                  ),
                  const SizedBox(height: 16),
                  _buildLocationCard(
                    theme,
                    'Destination',
                    _destinationLocation?.address ?? 'Select destination',
                    Icons.location_on,
                    theme.colorScheme.tertiary,
                    () => _showLocationPicker(false),
                  ),
                  const SizedBox(height: 24),
                  if (_estimatedFare != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.5), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estimated Fare', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('${_estimatedFare!.toStringAsFixed(0)} ETB', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer)),
                            ],
                          ),
                          Icon(Icons.local_taxi, size: 40, color: theme.colorScheme.secondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  CustomButton(
                    text: 'Request Ride',
                    onPressed: _requestRide,
                    isLoading: _isLoading,
                    icon: Icons.directions_car,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme, String label, String address, IconData icon, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(address, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(bool isPickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                isPickup ? 'Select Pickup Location' : 'Select Destination',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _popularLocations.length,
                itemBuilder: (context, index) {
                  final location = _popularLocations[index];
                  return ListTile(
                    leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                    title: Text(location.address),
                    onTap: () {
                      setState(() {
                        if (isPickup) {
                          _pickupLocation = location;
                        } else {
                          _destinationLocation = location;
                        }
                        _calculateFare();
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
