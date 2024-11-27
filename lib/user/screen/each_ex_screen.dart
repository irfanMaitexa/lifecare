import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EachExerciseDetailsScreen extends StatefulWidget {
  
  final Map<String, dynamic>  exerciseDetails;
  bool  isToday;

   EachExerciseDetailsScreen({super.key,required  this.exerciseDetails,this.isToday = false});

  @override
  State<EachExerciseDetailsScreen> createState() => _EachExerciseDetailsScreenState();
}

class _EachExerciseDetailsScreenState extends State<EachExerciseDetailsScreen> {



   Timer? _timer;
  int _remainingTime = 0; // in seconds
  bool _isTimerRunning = false;
  bool _isExerciseCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkExerciseCompletion();
  }

  void _checkExerciseCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first; // Current date
    final completedDate = prefs.getString('exerciseCompletedDate');

    setState(() {
      _isExerciseCompleted = (completedDate == today);
    });
  }

  void _markExerciseAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString('exerciseCompletedDate', today);

    setState(() {
      _isExerciseCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exercise completed for today!')),
    );
  }

  void _startTimer() {
    if (_isTimerRunning || _isExerciseCompleted) return;

    setState(() {
      _remainingTime = (1 ?? 0) * 60;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
        _markExerciseAsCompleted();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }




     
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseDetails['weekDay'] ?? 'Exercise Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [



          if (widget.isToday)
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
                        percent: _remainingTime > 0
                            ? 1 - (_remainingTime /
                                (widget.exerciseDetails['time'] ?? 0) /
                                60)
                            : 0.0,
                        backgroundColor: Colors.teal.shade600,
                        center: Text(
                          _remainingTime >= 0
                              ? _formatTime(_remainingTime)
                              : _isExerciseCompleted
                                  ? "Completed"
                                  : "Ready",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.exerciseDetails['exerciseTitle'] ?? '',
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
                              onPressed:
                                  _isExerciseCompleted ? null : _startTimer,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 0),
                              ),
                              child: Text(
                                _isExerciseCompleted
                                    ? "Completed"
                                    : _isTimerRunning
                                        ? "Running"
                                        : "Start",
                                style: TextStyle(
                                  color: _isExerciseCompleted
                                      ? Colors.grey
                                      : Colors.teal,
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
            margin: EdgeInsets.symmetric(vertical: 20),
            color: const Color.fromARGB(255, 228, 178, 29),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center,size: 30,),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(widget.exerciseDetails['exercise'])),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: const Color.fromARGB(255, 71, 71, 71),
                   
                  ),
                  Row(
                    children: [
                      Icon(Icons.sports_gymnastics,size: 30,),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(widget.exerciseDetails['howToDo'])),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: const Color.fromARGB(255, 71, 71, 71),
                    
                  ),
                   Row(
                    children: [
                      Icon(Icons.lock_clock,size: 30,),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(widget.exerciseDetails['time'].toString()+ ' min')),
                    ],
                  ),
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
                  Text('Food',style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
              
                  ),
                  Divider(
                    thickness: 1,
                    height: 20,
                  ),
              
                  SizedBox(height: 30,),
              
                  Text(widget.exerciseDetails['food'],style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 30,),
              
                  if(widget.isToday)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(text: 'Consume', onPressed: () {
                          
                        },),
                      ),
                    ],
                  )
              
              
                ],
              ),
            ),

          ),
      
        
        ]),
      ),
    );
  }

  // Helper function to format keys into a more readable form
  String _formatKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .toUpperCase();
  }
}
