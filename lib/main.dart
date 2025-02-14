import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/user/screen/login_screen.dart';
import 'package:lifecare/user/screen/root_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest_all.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialize the database

  // Check if user exists in the database
  bool userExists = await DatabaseHelper.instance.isUserExist();

   tz.initializeTimeZones();
  await initializeNotifications();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerPeriodicTask(
    "1",
    "waterReminder",
    frequency: Duration(hours: 1), // Runs every hour
  );


  runApp(MyApp(userExists: userExists));
}





Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    scheduleNotification("Water Reminder", "Drink a glass of water!");
    
    return Future.value(true);
  });
}

Future<void> scheduleNotification(String title, String body) async {
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails('reminder_channel', 'Reminders',
          importance: Importance.high, priority: Priority.high),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool userExists;

  const MyApp({Key? key, required this.userExists}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'roboto'
      ),
      home: userExists ? RootScreen() : LoginScreen(),
    );
  }
}
