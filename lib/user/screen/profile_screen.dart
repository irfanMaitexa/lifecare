import 'package:flutter/material.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_text_field.dart';

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
  bool _isUpdating = false; // Track update loading state
  int? userId; // Store the user ID for updates

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
        userId = int.parse(user['id'].toString());
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

  Future<void> updateProfile() async {
    if (userId == null) return; // Prevent updating if no user exists

    setState(() {
      _isUpdating = true; // Show loading indicator
    });

    final db = await DatabaseHelper.instance.database;

    await db.update(
      'user_table',
      {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
      },
      where: 'id = ?',
      whereArgs: [userId], // Update only the current user
    );

    setState(() {
      _isUpdating = false; // Hide loading indicator
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading while fetching data
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
                    _isUpdating
                        ? const Center(child: CircularProgressIndicator()) // Show loader while updating
                        : CustomButton(
                            onPressed: updateProfile, // Call update function
                            text: 'Save',
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
