import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lifecare/constants.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/user/screen/root_screen.dart';
import 'package:lifecare/user/screen/signup_screen.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // Track the loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: BottomSheetContainer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopImage(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Log In',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
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
                  const SizedBox(height: 10),
                  
                  const SizedBox(height: 20),
                  _isLoading  // Show loading indicator when _isLoading is true
                      ? Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Log In',
                          onPressed: () => _validateInputs(context),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateInputs(BuildContext context) {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!_isValidEmail(email)) {
      _showErrorDialog(context, 'Invalid Email', 'Please enter a valid email address.');
    } else if (password.isEmpty) {
      _showErrorDialog(context, 'Invalid Password', 'Please enter a password.');
    } else if (password.length < 6) {
      _showErrorDialog(context, 'Invalid Password', 'Password must be at least 6 characters.');
    } else {
      _loginUser(email, password, context); // Call login API
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
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


  Future<void> _loginUser(String email, String password, BuildContext context) async {
  final url = Uri.parse('$baseUrl/login');  // Replace with your Flask API URL

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);  // For debugging

      // Prepare user data in a Map
      Map<String, dynamic> user = {
        'id': data['user']['id'],
        'email': data['user']['email'],
        'name': data['user']['name'],
        'phone': data['user']['phone'],
        'height': data['user']['height'],
        'weight': data['user']['weight'],
        'otherProblems': data['user']['other_problems'],
      };

      // Store the user data in the database
      await DatabaseHelper.instance.insertUser(user);

      // Navigate to another screen on successful login
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RootScreen(),),(route) => false,);
    } else {
      final data = json.decode(response.body);
      _showErrorDialog(context, 'Login Failed', data['error'] ?? 'An error occurred');
    }
  } catch (e) {
    _showErrorDialog(context, 'Error', 'Unable to connect to the server');
  }
}





}

// Custom Widgets

class TopImage extends StatelessWidget {
  const TopImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('asset/images/logo.png'), // Replace with your image
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
      ),
    );
  }
}

class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 40,
      padding: EdgeInsets.only(bottom: 10, top: 0),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: 'Create Account',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen(),),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
