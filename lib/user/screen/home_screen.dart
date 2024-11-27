import 'package:flutter/material.dart';
import 'package:lifecare/constants.dart';
import 'package:lifecare/user/screen/each_ex_screen.dart';
import 'package:lifecare/user/screen/health_check_screen.dart';
import 'package:lifecare/widgets/custom_card.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String? disease;
  Map<String, dynamic>? advice;
  bool ? isExCompleted;

  @override
  void initState() {
    super.initState();
    _loadHealthAdvice();
  }

  Future<void> _loadHealthAdvice() async {
    setState(() {
      isLoading =  true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    disease = prefs.getString('health_prediction');

    if (disease != null) {
      try {

        isExCompleted = prefs.getString('exerciseCompletedDate') == null ?  false : true;


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

          Navigator.push(context, MaterialPageRoute(builder: (context) => HealthDataFormScreen(),)).then((value) {
            _loadHealthAdvice();
          },);
        
      },
      child: Icon(Icons.health_and_safety,color: Colors.white,),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "$disease",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.teal),
        ),
      ),
      body:disease == null?  Center(
        child: Lottie.asset('asset/images/homeani.json'),
      ) : isLoading
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
                        //Text('Goal',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        _buildRecoveryGoalsCard(advice!['recoveryGoals']),
                        SizedBox(
                          height: 20,
                        ),
                        ..._buildExercisePlan(today),
                        if (advice!['error'] != null)
                          Text(
                            advice!['error'],
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          )
                        else
                          ...[],
                        RecentActivityWidget()
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

    // Group exercises by weekday (as strings)
    for (var exercise in exercises) {
      String weekDay = exercise['weekDay']; // Example: "Monday", "Tuesday"
      groupedExercises.putIfAbsent(weekDay, () => []).add(exercise);
    }

    List<Widget> widgets = [];

    // Add today's exercises first, if available
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
                
                Expanded(child: Divider(
                  color: Colors.grey.shade200,
                  height: 2,
                  indent: 13,
                ))
              ],
            ),
            SizedBox(height: 8),
            ...groupedExercises[today]!.map(
              (exercise) => Card(
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
                        percent: isExCompleted == true ?  1.0 : 0.0,
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

                      SizedBox(
                        width: 10,
                      ),

                      // Title with white text
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
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EachExerciseDetailsScreen(exerciseDetails: exercise,isToday: true,),),);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 0),
                              ),
                              child: Text(
                                 isExCompleted == true ? "Completed" :  "Start",
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
                      // Button
                    ],
                  ),
                ),
              ),
            
            
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Exercise Plan:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                 Expanded(child: Divider(
                  color: Colors.grey.shade200,
                  height: 2,
                  indent: 13,
                ))
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      );

      // Remove today's exercises from the grouped map to avoid duplication
      groupedExercises.remove(today);
    }

    // Add the rest of the exercises grouped by other weekdays
    // groupedExercises.forEach((weekDay, exerciseList) {
    //   widgets.add(
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [

    //         Text(
    //           weekDay,
    //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //         ),
    //         SizedBox(height: 8),
    //         ...exerciseList.map(
    //           (exercise) => Card(
    //             child: ListTile(
    //               leading: Icon(Icons.fitness_center, color: Colors.green),
    //               title: Text(exercise['exerciseTitle']),
    //               subtitle: Text("Time: ${exercise['time']} mins"),
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 16),
    //       ],
    //     ),
    //   );
    // });

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
    return weekDays[DateTime.now().weekday - 1];
  }

  Widget _buildRecoveryGoalsCard(List<dynamic> recoveryGoals) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.teal, // Light green background
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            // Row(
            //   children: [
            //     Icon(Icons.healing, color: Colors.white, size: 32),
            //     SizedBox(width: 8),
            //     Text(
            //       "Recovery Goals",
            //       style: TextStyle(
            //         fontSize: 22,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ],
            // ),

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
