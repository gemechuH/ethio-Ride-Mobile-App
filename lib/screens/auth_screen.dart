import 'package:flutter/material.dart';
import 'package:journeysync/widgets/custom_button.dart';
import 'package:journeysync/widgets/custom_text_field.dart';
import 'package:journeysync/services/user_service.dart';
import 'package:journeysync/screens/passenger/passenger_home_screen.dart';
import 'package:journeysync/screens/driver/driver_home_screen.dart';
import 'package:journeysync/screens/admin/admin_home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'passenger';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userService = UserService();
    final user = await userService.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    if (user != null && user.role == _selectedRole) {
      Widget homeScreen;
      switch (user.role) {
        case 'passenger':
          homeScreen = PassengerHomeScreen(userId: user.id);
          break;
        case 'driver':
          homeScreen = DriverHomeScreen(userId: user.id);
          break;
        case 'admin':
          homeScreen = const AdminHomeScreen();
          break;
        default:
          setState(() => _isLoading = false);
          return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials or role mismatch')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_taxi, size: 40, color: Colors.white),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF25A556), shape: BoxShape.circle)),
                          const SizedBox(width: 3),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFCD116), shape: BoxShape.circle)),
                          const SizedBox(width: 3),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFEF2B2D), shape: BoxShape.circle)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Welcome to EthioRide', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Sign in to continue', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                const SizedBox(height: 40),
                Text('Select Role', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text('Passenger'),
                      ),
                      selected: _selectedRole == 'passenger',
                      onSelected: (selected) => setState(() => _selectedRole = 'passenger'),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(color: _selectedRole == 'passenger' ? Colors.white : theme.colorScheme.onSurface),
                    ),
                    ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text('Driver'),
                      ),
                      selected: _selectedRole == 'driver',
                      onSelected: (selected) => setState(() => _selectedRole = 'driver'),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(color: _selectedRole == 'driver' ? Colors.white : theme.colorScheme.onSurface),
                    ),
                    ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text('Admin'),
                      ),
                      selected: _selectedRole == 'admin',
                      onSelected: (selected) => setState(() => _selectedRole = 'admin'),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(color: _selectedRole == 'admin' ? Colors.white : theme.colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),
                const SizedBox(height: 16),
                Text(
                  'Demo: Any email works with any password',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
