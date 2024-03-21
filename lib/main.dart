import 'package:aad_hybrid/screens/add_item.dart';
import 'package:aad_hybrid/screens/home.dart';
import 'package:aad_hybrid/screens/login.dart';
import 'package:aad_hybrid/screens/my_items.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: token != null ? Home() : Login(),
      routes: {
        '/addItem': (context) => AddItem(),
        '/login': (context) => Login(),
        '/myItems':(context)=> MyItems(),// Define the login route
      },
    );
  }
}
