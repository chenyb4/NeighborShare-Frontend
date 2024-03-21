import 'package:aad_hybrid/screens/add_item.dart';
import 'package:aad_hybrid/screens/home.dart';
import 'package:aad_hybrid/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MaterialApp(
    home: token != null ? Home() : Login(),
    routes: {
      '/addItem': (context) => AddItem(),
    },
  ));
}
