import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lifecare/constants.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthDataFormScreen extends StatefulWidget {
  @override
  _HealthDataFormScreenState createState() => _HealthDataFormScreenState();
}

class _HealthDataFormScreenState extends State<HealthDataFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final ageController = TextEditingController();
  final bmiController = TextEditingController();

  // Dropdown values
  String? gender;
  String? drinking;
  String? exercise;
  String? junk;
  String? sleep;
  String? smoking;

  bool _isLoading = false; // Loading indicator state

  // Load user data from SQLite
  Future<void> _loadUserData() async {
    _isLoading = true;
    setState(() {});

    final dbHelper = DatabaseHelper.instance;
    final userExists = await dbHelper.isUserExist();

    if (userExists) {
      // Assuming you're fetching the first user as an example
      final users = await dbHelper.getUsers();
      if (users.isNotEmpty) {
        final user = users.first;

        // Calculate BMI (weight in kg / height in m²)
        final heightInMeters = (user['height'] ?? 0) / 100.0; // Assuming height is in cm
        final weight = user['weight'] ?? 0.0;
        final bmi = (weight > 0 && heightInMeters > 0)
            ? (weight / (heightInMeters * heightInMeters)).toStringAsFixed(2)
            : '0.00';

        setState(() {
          // Set the calculated BMI as a hint or placeholder
          bmiController.text = bmi.toString(); // Clear the text to allow user input
          _isLoading = false;
        });
      }
    } else {
      print('No user data found in SQLite.');
    }
  }

  Future<void> submitHealthData() async {
    setState(() {
      _isLoading = true;
    });

    final features = [
      int.tryParse(ageController.text) ?? 0,
      double.tryParse(bmiController.text) ?? 0.0,
      int.parse(drinking ?? '0'),
      int.parse(exercise ?? '1'),
      int.parse(gender ?? '0'),
      int.parse(junk ?? '1'),
      int.parse(sleep ?? '1'),
      int.parse(smoking ?? '0'),
    ];

    final url = Uri.parse("$baseUrl/predict");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'features': features});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Parse the response
        final responseData = jsonDecode(response.body);

        if (responseData['prediction'] != null) {
          final prediction = responseData['prediction'];

          // Save the prediction to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('health_prediction', prediction);

          // Print to verify (optional)
          print('Prediction saved: $prediction');

          Navigator.pop(context);

          // Optionally, navigate to another screen or show a confirmation
        } else {
          print('Prediction key not found in response.');
        }
      } else {
        print('Failed to submit data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Health Data', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Age',
                  hintText: 'Enter your age',
                  controller: ageController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'BMI',
                  hintText: 'Enter your BMI',
                  controller: bmiController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                _buildDropdown(
                  label: 'Gender',
                  value: gender,
                  items: {'0': 'Female', '1': 'Male'},
                  onChanged: (val) => setState(() => gender = val),
                ),
                SizedBox(height: 16),
                _buildDropdown(
                  label: 'Drinking',
                  value: drinking,
                  items: {'0': 'No', '1': 'Yes'},
                  onChanged: (val) => setState(() => drinking = val),
                ),
                SizedBox(height: 16),
                _buildDropdown(
                  label: 'Exercise',
                  value: exercise,
                  items: {'1': 'Low', '2': 'Medium', '3': 'High'},
                  onChanged: (val) => setState(() => exercise = val),
                ),
                SizedBox(height: 16),
                _buildDropdown(
                  label: 'Junk Food Consumption',
                  value: junk,
                  items: {'1': 'Low', '2': 'Medium', '3': 'High'},
                  onChanged: (val) => setState(() => junk = val),
                ),
                SizedBox(height: 16),
                _buildDropdown(
                  label: 'Sleep Quality',
                  value: sleep,
                  items: {'1': 'Low', '2': 'Medium', '3': 'High'},
                  onChanged: (val) => setState(() => sleep = val),
                ),
                SizedBox(height: 16),
                _buildDropdown(
                  label: 'Smoking',
                  value: smoking,
                  items: {'0': 'No', '1': 'Yes'},
                  onChanged: (val) => setState(() => smoking = val),
                ),
                SizedBox(height: 24),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Submit',
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                submitHealthData();
                              }
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(13),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            icon: Icon(Icons.arrow_drop_down),
            decoration: InputDecoration(border: InputBorder.none),
            items: items.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: onChanged,
            validator: (val) => val == null ? 'Please select a $label' : null,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    bmiController.dispose();
    super.dispose();
  }
}