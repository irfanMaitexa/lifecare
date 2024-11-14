import 'dart:convert'; // For encoding JSON data
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP package for making API calls
import 'package:flutter/gestures.dart'; // For RichText clickable links
import 'package:lifecare/constants.dart';
import 'package:lifecare/widgets/custom_button_widget.dart'; // Custom button widget
import 'package:lifecare/widgets/custom_text_field.dart'; // Custom text field widget

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Register',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Name',
              hintText: 'Enter your name',
              controller: _nameController,
              isPassword: false,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
              isPassword: false,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Phone',
              hintText: 'Enter your phone number',
              controller: _phoneController,
              isPassword: false,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordController,
              isPassword: true,
              obscureText: _obscureText,
              onVisibilityToggle: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Weight (kg)',
              hintText: 'Enter your weight',
              controller: _weightController,
              isPassword: false,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Height (cm)',
              hintText: 'Enter your height',
              controller: _heightController,
              isPassword: false,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Diseases or Allergies',
              hintText: 'List any diseases or allergies',
              controller: _allergiesController,
              isPassword: false,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : CustomButton(
                    text: 'Register',
                    onPressed: () => _registerAccount(),
                  ),
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Log In',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.pop(context); // Navigate to login screen
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _registerAccount() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final weight = _weightController.text;
    final height = _heightController.text;
    final allergies = _allergiesController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || weight.isEmpty || height.isEmpty) {
      _showErrorDialog('Incomplete Information', 'Please fill in all the fields.');
    } else {
      setState(() {
        _isLoading = true; // Show the loading indicator
      });

      try {
        // Prepare data to send to the API
        final Map<String, dynamic> data = {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'weight': weight,
          'height': height,
          'otherproblems': allergies,
        };

        // API endpoint URL
        final String apiUrl = '$baseUrl/register';

        // Sending HTTP POST request to register the user
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json', // Set header for JSON content
          },
          body: json.encode(data), // Convert data to JSON
        );

        setState(() {
          _isLoading = false; // Hide the loading indicator after the request
        });

        if (response.statusCode == 200) {
          // Successful registration
          final responseData = json.decode(response.body);
          _showSuccessDialog('Success', responseData['message']);
        } else {
          // Handle error response
          final responseData = json.decode(response.body);
          _showErrorDialog('Error', responseData['error'] ?? 'Something went wrong');
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide the loading indicator on error
        });
        // Handle network error
        _showErrorDialog('Error', 'Failed to connect to the server. Please try again.');
      }
    }
  }

  // Show success dialog
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
