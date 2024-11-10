import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';  // Import the lottie package
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
            const SizedBox(height: 24),
            Lottie.asset('assets/loading.json', width: 400, height: 400),  // Use your Lottie animation
            const SizedBox(height: 24),
            
          ],
        ),
      ),
    );
  }
}
