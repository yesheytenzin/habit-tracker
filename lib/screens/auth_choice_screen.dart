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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 70), // Add spacing to replace the AppBar
              const Text(
                'welcome to habit sign up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'Roboto Mono',
                  fontWeight: FontWeight.normal,
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
    const SizedBox(height: 30),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff5f6c7b), // Primary button color
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30), // Adjusted padding for better tap area
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // More pronounced rounded corners for modern look
        ),
        elevation: 8, // Slightly higher elevation for a more prominent shadow
        shadowColor: const Color(0x55000000), // Softer shadow color
        textStyle: const TextStyle(
          fontSize: 18, // Larger text size for better readability
          fontWeight: FontWeight.bold, // Bold text for emphasis
        ),
      ),
      onPressed: () => setState(() => _selectedMethod = 'PIN'),
      child: const Text('Setup 6-digit PIN'),
    ),
    const SizedBox(height: 20),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xffeebbc3), // Secondary button color
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30), // Adjusted padding for consistency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners for uniformity
        ),
        elevation: 8, // Similar elevation for consistency
        shadowColor: const Color(0x55000000), // Soft shadow effect
        textStyle: const TextStyle(
          fontSize: 18, // Larger font size for readability
          fontWeight: FontWeight.bold, // Bold text for consistency
        ),
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
            labelStyle: const TextStyle(
              color: Colors.blueAccent, // Label color
              fontWeight: FontWeight.w600, // Slightly bolder label
            ),
            hintText: _selectedMethod == 'PIN' ? 'Enter a 6-digit PIN' : 'Enter your password',
            hintStyle: const TextStyle(
              color: Colors.grey, // Lighter text for hint
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Padding inside the field
            filled: true, // Background color
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2), // Focus border color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1), // Default border color
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5), // Error border color
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2), // Error focus border color
            ),
          ),
          validator: (value) => _validateInput(value),
        ),
      ),

      const SizedBox(height: 20),
      Column(
  children: [
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, 
        backgroundColor: const Color(0xff5f6c7b), // Text color
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24), // More padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        elevation: 6, // Slight shadow for raised effect
        textStyle: const TextStyle(
          fontSize: 18, // Larger text size
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
      onPressed: _saveAuth,
      child: const Text('Continue'),
    ),
    const SizedBox(height: 12),
    TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Padding for button
        backgroundColor: const Color(0xffeebbc3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        side: const BorderSide(color: Colors.black54, width: 1.5), // Border for a subtle outline
        textStyle: const TextStyle(
          fontSize: 16, // Text size
          fontWeight: FontWeight.w600, // Slightly bold for emphasis
        ),
      ),
      onPressed: _resetSelection,
      child: const Text('Choose Different Method'),
    ),
  ],
)

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
