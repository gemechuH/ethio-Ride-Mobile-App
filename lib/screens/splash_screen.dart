import 'package:flutter/material.dart';
import 'package:journeysync/screens/auth_screen.dart';
import 'package:journeysync/screens/passenger/passenger_home_screen.dart';
import 'package:journeysync/screens/driver/driver_home_screen.dart';
import 'package:journeysync/screens/admin/admin_home_screen.dart';
import 'package:journeysync/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    
    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final userService = UserService();
    final currentUser = await userService.getCurrentUser();

    if (!mounted) return;

    if (currentUser == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
    } else {
      Widget homeScreen;
      switch (currentUser.role) {
        case 'passenger':
          homeScreen = PassengerHomeScreen(userId: currentUser.id);
          break;
        case 'driver':
          homeScreen = DriverHomeScreen(userId: currentUser.id);
          break;
        case 'admin':
          homeScreen = const AdminHomeScreen();
          break;
        default:
          homeScreen = const AuthScreen();
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_taxi, size: 60, color: theme.colorScheme.primary),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF25A556), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFCD116), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF2B2D), shape: BoxShape.circle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('EthioRide', style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your Ride, Your Way', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
