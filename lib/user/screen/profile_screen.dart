import 'package:flutter/material.dart';
import 'package:lifecare/constants.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/user/screen/login_screen.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_text_field.dart';
 // Import your CustomTextField

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
                    CustomButton(
                      onPressed: () {
                        // Save data to database
                      },
                      text:  'Save',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}