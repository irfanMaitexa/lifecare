import 'package:flutter/material.dart';
import 'package:lifecare/constants.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/user/screen/login_screen.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For logout functionality
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For encoding/decoding JSON

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isLoading = true;
  int? _userId; // To store the user ID

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final db = await DatabaseHelper.instance.database;
    final result = await db.query('user_table', limit: 1);
    if (result.isNotEmpty) {
      final user = result.first;
      setState(() {
        _userId = user['id'] as int?; // Store the user ID
        _nameController.text = user['name'].toString();
        _emailController.text = user['email'].toString();
        _phoneController.text = user['phone'].toString();
        _heightController.text = user['height']?.toString() ?? '';
        _weightController.text = user['weight']?.toString() ?? '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove the login state

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false,);
  }

  // Function to update profile
  Future<void> _updateProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/profile/edit'); // Replace with your API URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'id': _userId,
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'weight': _weightController.text.isEmpty ? null : double.parse(_weightController.text),
      'height': _heightController.text.isEmpty ? null : double.parse(_heightController.text),
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Profile updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        // Handle errors
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Widget buildLabelAndCustomField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        CustomTextField(
          label: label,
          hintText: 'Enter your $label',
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Call the logout function
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildLabelAndCustomField('Name', _nameController),
                    buildLabelAndCustomField('Email', _emailController),
                    buildLabelAndCustomField('Phone', _phoneController, isNumber: true),
                    buildLabelAndCustomField('Height', _heightController, isNumber: true),
                    buildLabelAndCustomField('Weight', _weightController, isNumber: true),
                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: _updateProfile, // Call the update profile function
                      text: 'Save',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}