import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authController = TextEditingController();
  String? _authMethod;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadAuthMethod();
  }

  Future<void> _loadAuthMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authMethod = prefs.getString('auth_method');
    });
  }

  Future<void> _authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAuth = prefs.getString('auth_value');
    
    if (savedAuth == _authController.text) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color for the screen
      backgroundColor: Colors.blueGrey[50],  // Set a color of your choice
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Add a text at the top
              const Text(
                'Please Enter Your Credentials',  // Text at the top
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),  // Add space between the text and the form

              TextFormField(
                controller: _authController,
                obscureText: true,
                keyboardType: _authMethod == 'PIN' 
                    ? TextInputType.number 
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: _authMethod == 'PIN' 
                      ? 'Enter 6-digit PIN' 
                      : 'Enter Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  if (_authMethod == 'PIN' && value.length != 6) {
                    return 'PIN must be 6 digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              Image.asset(
                'assets/password.png', // Replace with the correct image path
                height: 300,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,  // Set the background color here
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _authenticate();
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
