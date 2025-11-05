import 'package:flutter/material.dart';
import 'package:journeysync/models/user.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/widgets/user_avatar.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/screens/auth_screen.dart';

class PassengerProfileScreen extends StatefulWidget {
  final String userId;

  const PassengerProfileScreen({super.key, required this.userId});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final userService = UserService();
    _user = await userService.getUserById(widget.userId);
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
            UserAvatar(name: _user?.name ?? 'User', size: 96),
            const SizedBox(height: 16),
            Text(_user?.name ?? 'User', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 20, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text('${_user?.rating.toStringAsFixed(1) ?? '5.0'}', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoCard(theme, 'Email', _user?.email ?? '', Icons.email),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Phone', _user?.phone ?? '', Icons.phone),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Role', 'Passenger', Icons.person),
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
