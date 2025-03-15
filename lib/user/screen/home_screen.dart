import 'package:flutter/material.dart';
import 'package:lifecare/constants.dart';
import 'package:lifecare/user/screen/each_ex_screen.dart';
import 'package:lifecare/user/screen/health_check_screen.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:lifecare/widgets/custom_card.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // For random number generation

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String? disease;
  Map<String, dynamic>? advice;
  bool? isExCompleted;
  String? motivationalQuote; // Store the random motivational quote

  // List of motivational health quotes
  final List<String> healthQuotes = [
    "Take care of your body. It's the only place you have to live.",
    "Health is not about the weight you lose, but the life you gain.",
    "Your health is an investment, not an expense.",
    "Small steps every day lead to big results over time.",
    "A healthy outside starts from the inside.",
    "The greatest wealth is health.",
    "Don't wait for the perfect moment. Take the moment and make it perfect.",
    "Healthy habits are learned in the same way as unhealthy ones – through practice.",
    "Strive for progress, not perfection.",
    "Your body is your most priceless possession. Take care of it.",
  ];

  @override
  void initState() {
    super.initState();
    _loadHealthAdvice();
    _generateRandomMotivationalQuote(); // Generate a random quote on app restart
    _showMotivationalQuotePopup(); // Show the motivational quote as a popup
  }

  // Generate a random motivational quote
  void _generateRandomMotivationalQuote() {
    final random = Random();
    motivationalQuote = healthQuotes[random.nextInt(healthQuotes.length)];
  }

  // Show the motivational quote as a popup
  void _showMotivationalQuotePopup() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (motivationalQuote != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 10,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade300, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                 
                  SizedBox(height: 20),
                  // Motivational Quote Text
                  Text(
                    "🌟 Motivational Quote 🌟",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(
                    color: Colors.white.withOpacity(0.5),
                    thickness: 1,
                  ),
                  SizedBox(height: 20),
                  Text(
                    motivationalQuote!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Close Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      "Got it!",
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  });
}

  Future<void> _loadHealthAdvice() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    disease = prefs.getString('health_prediction');

    print(disease);

    if (disease != null) {
      try {
        isExCompleted = prefs.getString('exerciseCompletedDate') == null ? false : true;

        print(isExCompleted);

        final response = await http.post(
          Uri.parse('$baseUrl/health_advice'), // Replace with your API endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'disease': disease}),
        );

        if (response.statusCode == 200) {
          setState(() {
            advice = jsonDecode(response.body)['advice'];
            isLoading = false;
          });
        } else {
          setState(() {
            advice = {'error': 'Failed to fetch advice. Try again later.'};
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          advice = {'error': 'An error occurred: $e'};
          isLoading = false;
        });
      }
    } else {
      setState(() {
        advice = {'error': 'No disease prediction found in preferences.'};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _getCurrentWeekday();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HealthDataFormScreen())).then((value) {
            _loadHealthAdvice();
          });
        },
        child: Icon(Icons.health_and_safety, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          disease ?? "Home",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ),
      body: disease == null
          ? Center(
              child: Lottie.asset('asset/images/homeani.json'),
            )
          : isLoading
              ? Center(child: CircularProgressIndicator())
              : advice == null
                  ? Center(
                      child: Text(
                        "No advice available.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the motivational quote
                            if (motivationalQuote != null)
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.teal.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    motivationalQuote!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.teal.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            SizedBox(height: 20),
                            _buildRecoveryGoalsCard(advice!['recoveryGoals'] ?? []),
                            SizedBox(height: 20),
                            ..._buildExercisePlan(today),
                            if (advice!['error'] != null)
                              Text(
                                advice!['error'],
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            RecentActivityWidget(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildTodayCard(String today) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.green.shade800,
              size: 32,
            ),
            SizedBox(width: 16),
            Text(
              "Today is $today",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExercisePlan(String today) {
    final exercises = advice!['exercisePlan'] ?? [];
    Map<String, List<Map<String, dynamic>>> groupedExercises = {};

    for (var exercise in exercises) {
      String weekDay = exercise['weekDay'];
      groupedExercises.putIfAbsent(weekDay, () => []).add(exercise);
    }

    List<Widget> widgets = [];

    if (groupedExercises.containsKey(today)) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "$today (Today) :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey.shade200,
                    height: 2,
                    indent: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...groupedExercises[today]!.map(
              (exercise) => Column(
                children: [
                  Card(
                    elevation: 6,
                    color: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 8.0,
                            percent: isExCompleted == true ? 1.0 : 0.0,
                            backgroundColor: Colors.teal.shade600,
                            center: Text(
                              isExCompleted == true ? "100%" : "0%",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            ),
                            progressColor: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  exercise['exerciseTitle'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EachExerciseDetailsScreen(
                                          exerciseDetails: exercise,
                                          isToday: true,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 0),
                                  ),
                                  child: Text(
                                    isExCompleted == true ? "Completed" : "Start",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 6,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Food',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          ),
                          Divider(
                            thickness: 1,
                            height: 20,
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Break fast :   ${exercise['food']['morning']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Lunch :   ${exercise['food']['lunch']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Dinner :   ${exercise['food']['dinner']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Consume',
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Exercise Plan:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey.shade200,
                    height: 2,
                    indent: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      );

      groupedExercises.remove(today);
    }

    return widgets;
  }

  String _getCurrentWeekday() {
    const weekDays = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];
    return weekDays[DateTime.now().weekday];
  }

  Widget _buildRecoveryGoalsCard(List<dynamic> recoveryGoals) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...recoveryGoals.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 17),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
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
}