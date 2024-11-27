import 'package:flutter/material.dart';

class ExercisePlanScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exercisePlans = [
    {
      "exercise": "Walk in a calm, quiet place to clear your mind and ease tension.",
      "exerciseTitle": "Walk in a Calm Environment",
      "food": "Breakfast: Oatmeal with berries and nuts",
      "howToDo": "Find a peaceful location. Walk slowly, focusing on your breath and surroundings.",
      "time": 10,
      "weekDay": "Monday"
    },
    {
      "exercise": "Practice controlled breathing to calm the nervous system.",
      "exerciseTitle": "Deep Breathing Exercises",
      "food": "Snack: Greek yogurt with honey and walnuts",
      "howToDo": "Sit in a comfortable position. Inhale slowly for 4 seconds, hold for 7 seconds, and exhale for 8 seconds.",
      "time": 5,
      "weekDay": "Tuesday"
    },
    {
      "exercise": "Gentle stretches or basic yoga poses can help relieve stress.",
      "exerciseTitle": "Light Stretching or Yoga",
      "food": "Lunch: Grilled chicken salad with mixed greens",
      "howToDo": "Perform basic yoga poses like Child's Pose, Downward Dog, and Cat-Cow to gently stretch your body.",
      "time": 10,
      "weekDay": "Wednesday"
    },
    {
      "exercise": "Take a walk outside to enjoy fresh air and boost mood.",
      "exerciseTitle": "Outdoor Walk",
      "food": "Dinner: Salmon with sweet potato and steamed vegetables",
      "howToDo": "Walk briskly in a park or neighborhood, focusing on your steps and breathing.",
      "time": 10,
      "weekDay": "Thursday"
    },
    {
      "exercise": "Meditation helps center your mind and reduce stress.",
      "exerciseTitle": "Meditation for Relaxation",
      "food": "Snack: Apple slices with peanut butter",
      "howToDo": "Sit quietly and focus on your breath or use a guided meditation app to help you stay present.",
      "time": 10,
      "weekDay": "Friday"
    },
    {
      "exercise": "Let loose and have fun by dancing to music you enjoy.",
      "exerciseTitle": "Dancing to Favorite Music",
      "food": "Lunch: Quinoa salad with vegetables and nuts",
      "howToDo": "Put on your favorite upbeat song and let your body move naturally. Dance freely!",
      "time": 10,
      "weekDay": "Saturday"
    },
    {
      "exercise": "Take a calming walk in nature or engage in a relaxing hobby.",
      "exerciseTitle": "Nature Walk or Relaxing Hobby",
      "food": "Dinner: Grilled fish with quinoa and steamed broccoli",
      "howToDo": "Walk in a park or forest, focusing on the sounds of nature, or spend time with a calming hobby like painting or knitting.",
      "time": 15,
      "weekDay": "Sunday"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weekly Exercise Plan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: exercisePlans.length,
        itemBuilder: (context, index) {
          var plan = exercisePlans[index];
          return GestureDetector(
            onTap: () {
              // Navigate to a detailed page for each day (optional)
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(plan["exerciseTitle"]),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Exercise: ${plan['exercise']}"),
                      SizedBox(height: 8),
                      Text("Food: ${plan['food']}"),
                      SizedBox(height: 8),
                      Text("How to Do: ${plan['howToDo']}"),
                      SizedBox(height: 8),
                      Text("Time: ${plan['time']} minutes"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal, // Card background color
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.teal[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['weekDay'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            plan['exerciseTitle'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Time: ${plan['time']} mins",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
