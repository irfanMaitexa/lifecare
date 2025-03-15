import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lifecare/user/video_screen.dart';
import 'package:lifecare/widgets/custom_button_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // Add this package

class EachExerciseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> exerciseDetails;
  bool isToday;

  EachExerciseDetailsScreen({
    super.key,
    required this.exerciseDetails,
    this.isToday = false,
  });

  @override
  State<EachExerciseDetailsScreen> createState() =>
      _EachExerciseDetailsScreenState();
}

class _EachExerciseDetailsScreenState extends State<EachExerciseDetailsScreen> {
  Timer? _timer;
  int _remainingTime = 0; // in seconds
  bool _isTimerRunning = false;
  bool _isExerciseCompleted = false;
  int _yogaPoseCount = 0; // Counter for yoga pose
  late YoutubePlayerController _youtubeController; // YouTube video controller

  @override
  void initState() {
    super.initState();
    _checkExerciseCompletion();
    _initializeYoutubePlayer(); // Initialize YouTube player
  }

  void _initializeYoutubePlayer() {
    final videoURL = widget.exerciseDetails['videoURL'] ?? '';
    final videoId = YoutubePlayer.convertUrlToId(videoURL) ?? '';
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
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
      _remainingTime = (widget.exerciseDetails['time'] ?? 0) * 60;
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

  void _incrementYogaPoseCount() {
    setState(() {
      _yogaPoseCount++;
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
    _youtubeController.dispose(); // Dispose YouTube controller
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
        child: ListView(
          children: [
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
                      SizedBox(width: 10),
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
                            SizedBox(height: 10),
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

            // Yoga Pose Counter
            if (widget.exerciseDetails['yogaPose'] != null)
              Card(
                margin: EdgeInsets.symmetric(vertical: 20),
                color: Colors.orange.shade100,
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        widget.exerciseDetails['yogaPose'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.exerciseDetails['postureTip'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.repeat, size: 30, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            'Count: $_yogaPoseCount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _incrementYogaPoseCount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: Text(
                          'Increment Count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Poster URL and Count
            if (widget.exerciseDetails['posterURL'] != null)
              Card(
                margin: EdgeInsets.symmetric(vertical: 20),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poster',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Image.network(
                        widget.exerciseDetails['posterURL'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Count: ${widget.exerciseDetails['count']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // YouTube Video Player
            if (widget.exerciseDetails['videoURL'] != null)
              Card(
                margin: EdgeInsets.symmetric(vertical: 20),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Tutorial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      SizedBox(height: 10),

                      VideoCard(videoUrl: widget.exerciseDetails['videoURL'],)
                    
                    ],
                  ),
                ),
              ),

            // Food Section
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      height: 20,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Breakfast: ${widget.exerciseDetails['food']['morning']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Lunch: ${widget.exerciseDetails['food']['lunch']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dinner: ${widget.exerciseDetails['food']['dinner']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    if (widget.isToday)
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
    );
  }
}