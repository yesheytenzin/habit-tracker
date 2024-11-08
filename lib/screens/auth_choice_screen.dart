import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authController = TextEditingController();
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Automatically adjust layout for keyboard
      backgroundColor: Colors.white, // Set your desired background color here
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100), // Add spacing to replace the AppBar
              const Text(
                'welcome to habit sign up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 70),
              Image.asset(
                'assets/signup.png', // Add your image asset here
                height: 300,
              ),
              const SizedBox(height: 50),
              ...(_selectedMethod == null ? _buildMethodSelection() : _buildAuthForm()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMethodSelection() {
    return [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
        ),
        onPressed: () => setState(() => _selectedMethod = 'PIN'),
        child: const Text('Setup 6-digit PIN'),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
        ),
        onPressed: () => setState(() => _selectedMethod = 'PASSWORD'),
        child: const Text('Setup Password'),
      ),
    ];
  }

  List<Widget> _buildAuthForm() {
    return [
      Form(
        key: _formKey,
        child: TextFormField(
          controller: _authController,
          obscureText: true,
          keyboardType: _selectedMethod == 'PIN' ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: _selectedMethod == 'PIN' ? 'Enter 6-digit PIN' : 'Enter Password',
          ),
          validator: (value) => _validateInput(value),
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Text color
        ),
        onPressed: _saveAuth,
        child: const Text('Continue'),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: _resetSelection,
        child: const Text('Choose Different Method'),
      ),
    ];
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (_selectedMethod == 'PIN') {
      if (value.length != 6) return 'PIN must be exactly 6 digits';
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'PIN must contain only numbers';
    } else {
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$').hasMatch(value)) {
        return 'Password must contain both letters and numbers';
      }
    }
    return null;
  }

  Future<void> _saveAuth() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_method', _selectedMethod!);
      await prefs.setString('auth_value', _authController.text);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/user_details');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save authentication method. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedMethod = null;
      _authController.clear();
    });
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }
}
