import 'dart:convert';
import 'package:aad_hybrid/screens/enrol_or_create.dart';
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

    if (response.statusCode == 202) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String? token = responseData['token'];
      if (token != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final userDataResponse = await http.get(
          Uri.parse(baseUrl + '/users'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (userDataResponse.statusCode == 200) {
          final userData = jsonDecode(userDataResponse.body);
          final user = userData.firstWhere(
                (user) => user['email'] == email,
            orElse: () => null,
          );
          if (user != null && user['apartment_id'] != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EnrolOrCreate()));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to fetch user data'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid response format from server'),
        ));
      }
    } else {
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
