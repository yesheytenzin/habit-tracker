import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSetupStatus();
  }

  Future<void> _checkSetupStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasAuth = prefs.getString('auth_method') != null;
    final hasUserDetails = prefs.getString('username') != null;

    if (!hasAuth) {
      Navigator.pushReplacementNamed(context, '/auth_choice');
    } else if (!hasUserDetails) {
      Navigator.pushReplacementNamed(context, '/user_details');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/habits.png', // Make sure to add your logo to assets
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 