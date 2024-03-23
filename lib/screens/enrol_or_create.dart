import 'package:flutter/material.dart';
import 'package:aad_hybrid/screens/enrol_apartment.dart';
import 'package:aad_hybrid/screens/create_apartment.dart';
import 'package:aad_hybrid/screens/login.dart'; // Import login screen
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class EnrolOrCreate extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    // Clear token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrol or Create Apartment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnrolApartment()),
                );
              },
              child: Text('Enrol'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateApartment()),
                );
              },
              child: Text('Create'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _logout(context); // Call logout function when button is pressed
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
