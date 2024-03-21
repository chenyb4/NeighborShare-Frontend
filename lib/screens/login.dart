import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aad_hybrid/screens/register.dart';
import 'package:aad_hybrid/configs/colors.dart';

import '../configs/backend_address.dart';
import 'home.dart';

class Login extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String credentialsUrl = baseUrl + '/credentials';
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    final response = await http.post(
      Uri.parse(credentialsUrl),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    
    log(response.statusCode);



    if (response.statusCode == 202) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String? token = responseData['token'];
      if (token != null) {
        // Store token using SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Navigate to Home screen or any other screen
        // You can replace Home() with the appropriate screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        // Token not found in response, handle error
        // For now, just display a generic error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid response format from server'),
        ));
      }
    } else {
      // HTTP request failed, handle error
      // For now, just display a generic error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to login. Please try again later.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NeighborShare"),
        backgroundColor: themeColorShade1,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColorShade1,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
