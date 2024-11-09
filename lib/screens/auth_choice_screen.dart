import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _authController;
  late TextEditingController _confirmController;
  String? _selectedMethod;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authController = TextEditingController(text: '');
    _confirmController = TextEditingController(text: '');
    _clearFields();
  }

  void _clearFields() {
    _authController.clear();
    _confirmController.clear();
    _errorMessage = null;
  }

  void _handleMethodSelection(String method) {
    setState(() {
      _selectedMethod = method;
      _clearFields();
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  bool _validateInputs() {
    _clearError();
    
    if (_authController.text.isEmpty || _confirmController.text.isEmpty) {
      _showError('All fields must be filled');
      return false;
    }

    if (_selectedMethod == 'PIN') {
      if (_authController.text.length != 6) {
        _showError('PIN must be exactly 6 digits');
        return false;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(_authController.text)) {
        _showError('PIN can only contain numbers');
        return false;
      }
    } else {
      if (_authController.text.length < 6) {
        _showError('Password must be at least 6 characters long');
        return false;
      }
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
          .hasMatch(_authController.text)) {
        _showError('Password must contain both letters and numbers');
        return false;
      }
    }

    if (_authController.text != _confirmController.text) {
      _showError('Entries do not match');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(34.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              if (_selectedMethod == null) ...[
                const Text(
                  'Choose your authentication method',
                  style: TextStyle(
                    fontSize: 22, 
                    color: Color(0xff232946),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Image.asset(
                  'assets/signup.png',
                  height: 300,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _handleMethodSelection('PIN'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: const Color(0xffb8c1ec),
                    foregroundColor: const Color(0xff272343),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Adjust border radius as needed
                      side: const BorderSide(
                        color:  Color(0xff272343), // Border color
                        width: 2, // Border width
                      ),
                    ),
                  ),
                  child: const Text(
                    'Setup 6-digit PIN',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _handleMethodSelection('PASSWORD'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: const Color(0xffeebbc3),
                    foregroundColor: const Color(0xff5f6c7b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Adjust border radius as needed
                      side: const BorderSide(
                        color: Color(0xff5f6c7b), // Border color
                        width: 2, // Border width
                      ),
                    ),
                  ),
                  child: const Text(
                    'Setup Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),),
                ),

              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Setup ${_selectedMethod == 'PIN' ? 'PIN' : 'Password'}',
                        style: const TextStyle(
                          color: Color(0xff232946),
                          fontFamily: 'Poppins',
                          fontSize: 20, 
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/pass.png',
                        height: 300,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Set the border radius
                          side: const BorderSide(
                            color: Color(0xff232946), // Border color
                            width: 2, // Border width
                          ),
                        ),
                        elevation: 5, // Optional: Adds shadow to the card
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedMethod == 'PIN' 
                                    ? 'PIN Requirements:'
                                    : 'Password Requirements:',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              if (_selectedMethod == 'PIN') ...[
                                const Text(
                                  '• Must be exactly 6 digits',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),),
                                const Text('• Can only contain numbers (0-9)',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),),
                              ] else ...[
                                const Text('• Minimum 6 characters',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),),
                                const Text('• Must contain both letters and numbers',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _authController,
                        obscureText: true,
                        keyboardType: _selectedMethod == 'PIN' 
                            ? TextInputType.number 
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: _selectedMethod == 'PIN' 
                              ? 'Enter 6-digit PIN' 
                              : 'Enter Password',
                          errorText: _errorMessage,
                          border: const OutlineInputBorder(),
                          fillColor: const Color(0xffeebbc3),
                          filled: true,
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Color(0xff232946),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _authController.clear();
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        keyboardType: _selectedMethod == 'PIN' 
                            ? TextInputType.number 
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: _selectedMethod == 'PIN' 
                              ? 'Confirm PIN' 
                              : 'Confirm Password',
                          border: const OutlineInputBorder(),
                          fillColor: const Color(0xffb8c1ec),
                          filled: true,
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Color(0xff232946),
                          )
                        ),
                        onTap: () {
                          _confirmController.clear();
                          _errorMessage = null;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveAuth,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: const Color(0xff232946),
                        ),
                        child: const Text('Continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedMethod = null;
                            _clearFields();
                          });
                        },
                        child: const Text(
                          'Choose Different Method',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Color(0xff272343)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAuth() async {
    if (!_validateInputs()) {
      _showError('Too many failed attempts. Please try again later.');
      Future.delayed(const Duration(seconds: 30), () {
        setState(() {
          _authController.clear();
          _confirmController.clear();
        });
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_method', _selectedMethod!);
      await prefs.setString('auth_value', _authController.text);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication setup successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2)
        ),
      );

      Navigator.pushReplacementNamed(context, '/user_details');
    } catch (e) {
      _showError('Failed to save authentication. Please try again.');
    }
  }

  @override
  void dispose() {
    _authController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
