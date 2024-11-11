import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Dark icons on light background
      ));
    });
    _checkSetupStatus();
  }

  Future<void> _checkSetupStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasAuth = prefs.getString('auth_method') != null;
    final hasUserDetails = prefs.getString('username') != null;

    if (!hasAuth) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth_choice');
      }
    } else if (!hasUserDetails) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/user_details');
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
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
