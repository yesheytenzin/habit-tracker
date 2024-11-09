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
    
    // Check for empty fields
    if (_authController.text.isEmpty || _confirmController.text.isEmpty) {
      _showError('All fields must be filled');
      return false;
    }

    // PIN Validation
    if (_selectedMethod == 'PIN') {
      if (_authController.text.length != 6) {
        _showError('PIN must be exactly 6 digits');
        return false;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(_authController.text)) {
        _showError('PIN can only contain numbers');
        return false;
      }
    } 
    // Password Validation
    else {
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

    // Confirm matching entries
    if (_authController.text != _confirmController.text) {
      _showError('Entries do not match');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Authentication'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedMethod == null) ...[
              const Text(
                'Choose your authentication method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _handleMethodSelection('PIN'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text('Setup 6-digit PIN'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _handleMethodSelection('PASSWORD'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text('Setup Password'),
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
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Requirements Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedMethod == 'PIN' 
                                  ? 'PIN Requirements:'
                                  : 'Password Requirements:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedMethod == 'PIN') ...[
                              const Text('• Must be exactly 6 digits'),
                              const Text('• Can only contain numbers (0-9)'),
                            ] else ...[
                              const Text('• Minimum 6 characters'),
                              const Text('• Must contain both letters and numbers'),
                              const Text('• No special characters required'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First Input Field
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
                        prefixIcon: Icon(_selectedMethod == 'PIN' 
                            ? Icons.pin : Icons.lock),
                        border: const OutlineInputBorder(),
                        hintText: '',
                        counterText: '',
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                      onTap: () {
                        setState(() {
                          _authController.clear();
                          _errorMessage = null;
                        });
                      },
                      initialValue: null,
                      enableInteractiveSelection: true,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Input Field
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
                        prefixIcon: Icon(_selectedMethod == 'PIN' 
                            ? Icons.pin : Icons.lock),
                        border: const OutlineInputBorder(),
                      ),
                      onTap: () {
                        _confirmController.clear();
                        _errorMessage = null;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 24),

                    // Continue Button
                    ElevatedButton(
                      onPressed: _saveAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: 12),

                    // Back Button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMethod = null;
                          _clearFields();
                        });
                      },
                      child: const Text('Choose Different Method'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveAuth() async {
    if (!_validateInputs()) {
      _showError('Too many failed attempts. Please try again later.');
      // Reset fields after delay for both PIN and Password
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
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication setup successful!'),
          backgroundColor: Colors.green,
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