import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'driver/driver_home_screen.dart';
import 'passenger/passenger_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(seconds: 2));
    Widget next = const LoginScreen();
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        final role = await AuthService.currentRole();
        next = role == 'driver'
            ? const DriverHomeScreen()
            : const PassengerHomeScreen();
      } catch (_) {
        // if something fails, the user just sees the login screen
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => next),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_bus, size: 90, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'LouageGo',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Réservez votre place en un clic',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}