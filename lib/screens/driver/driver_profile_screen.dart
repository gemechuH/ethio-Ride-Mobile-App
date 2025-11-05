import 'package:flutter/material.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/models/driver.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/services/driver_service.dart';
import 'package:journeysync/widgets/user_avatar.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/auth_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  final String userId;

  const DriverProfileScreen({super.key, required this.userId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  User? _user;
  Driver? _driver;
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

    _user = await userService.getUserById(widget.userId);
    _driver = await driverService.getDriverByUserId(widget.userId);

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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            UserAvatar(name: _user?.name ?? 'Driver', size: 96),
            const SizedBox(height: 16),
            Text(_user?.name ?? 'Driver', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 20, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text('${_user?.rating.toStringAsFixed(1) ?? '5.0'}', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _driver?.isVerified == true ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_driver?.isVerified == true ? 'Verified Driver' : 'Pending Verification', style: theme.textTheme.bodySmall?.copyWith(color: _driver?.isVerified == true ? theme.colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(theme, 'Email', _user?.email ?? '', Icons.email),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Phone', _user?.phone ?? '', Icons.phone),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Vehicle', '${_driver?.vehicleModel ?? ''} • ${_driver?.vehicleColor ?? ''}', Icons.directions_car),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Plate Number', _driver?.vehiclePlate ?? '', Icons.pin),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Logout',
              onPressed: _logout,
              isPrimary: false,
              isOutlined: true,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String label, String value, IconData icon) {
    return Container(
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
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
