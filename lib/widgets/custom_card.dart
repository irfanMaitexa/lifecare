import 'package:flutter/material.dart';
import 'package:lifecare/user/screen/daily_activity_screen.dart';

class RecentActivityWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Daily Activity Card
        _buildActivityCard(
          color: Colors.orange,
          icon: Icons.directions_walk,
          title: 'Daily Activity',
          onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (context) => ExercisePlanScreen(),) );
          },
        ),
        SizedBox(width: 16), // Space between cards
        // Workouts Card
        _buildActivityCard(
          color: Colors.purple,
          icon: Icons.fitness_center,
          title: 'Workouts',
          onPressed: () {
            
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Progress Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.7, // Example progress, replace with dynamic value
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4,
                  ),
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Title Text
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}