import 'dart:convert';
import 'package:aad_hybrid/screens/add_item.dart';
import 'package:aad_hybrid/screens/enrol_or_create.dart';
import 'package:aad_hybrid/screens/home.dart';
import 'package:aad_hybrid/screens/login.dart';
import 'package:aad_hybrid/screens/my_items.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'configs/backend_address.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: token != null ? FutureBuilder<bool>(
        future: _hasApartment(token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
          } else {
            final bool hasApartment = snapshot.data ?? false;
            return hasApartment ? Home() : EnrolOrCreate();
          }
        },
      ) : Login(),
      routes: {
        '/addItem': (context) => AddItem(),
        '/login': (context) => Login(),
        '/myItems': (context) => MyItems(),
      },
    );
  }

  Future<bool> _hasApartment(String token) async {
    try {
      final userDataResponse = await http.get(
        Uri.parse(baseUrl + '/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userDataResponse.statusCode == 200) {
        final userData = jsonDecode(userDataResponse.body);
        final user = userData.firstWhere(
              (user) => user['email'] == _parseJwt(token)['email'],
          orElse: () => null,
        );
        return user != null && user['apartment_id'] != null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }

    return false;
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid JWT token');
    }
    final payload = parts[1];
    return jsonDecode(utf8.decode(base64Url.decode(payload)));
  }
}
