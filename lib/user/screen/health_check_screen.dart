import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_text_field.dart';

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

  // API request function
  Future<void> submitHealthData() async {
    setState(() {
      _isLoading = true;
    });

    // Construct the data in the required format
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

    // Define the URL and headers
    final url = Uri.parse("https://0e43-117-202-52-82.ngrok-free.app/predict");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'features': features});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Handle successful response
        print('Response: ${response.body}');
        // You can also parse and show response data as needed
      } else {
        // Handle error
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
