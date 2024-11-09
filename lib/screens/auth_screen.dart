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
  String? _errorMessage; // To hold error message

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
      setState(() {
        _errorMessage = _authMethod == 'PIN' 
            ? 'Incorrect PIN' 
            : 'Incorrect Password'; // Set error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Set a color of your choice
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Please Enter Your Credentials', // Text at the top
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20), // Add space between the text and the form

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
                  labelStyle: const TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: _authMethod == 'PIN'
                      ? 'Enter your 6-digit PIN'
                      : 'Enter a secure password',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueGrey,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
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

              // Display error message below TextFormField if exists
              if (_errorMessage != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              Image.asset(
                'assets/password.png', // Replace with the correct image path
                height: 300,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87, 
                  backgroundColor: const Color(0xffeebbc3),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5.0,
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _authenticate();
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
