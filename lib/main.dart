import 'package:flutter/material.dart';
import 'package:lifecare/db/db_serviece.dart';
import 'package:lifecare/user/screen/login_screen.dart';
import 'package:lifecare/user/screen/root_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialize the database

  // Check if user exists in the database
  bool userExists = await DatabaseHelper.instance.isUserExist();

  runApp(MyApp(userExists: userExists));
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
