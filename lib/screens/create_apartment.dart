import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:aad_hybrid/configs/backend_address.dart'; // Import backend address
import 'package:aad_hybrid/screens/home.dart'; // Import home screen

class CreateApartment extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _createApartment(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String pin = _pinController.text.trim();

    final String? token = await _getToken(); // Retrieve token from SharedPreferences

    if (token == null) {
      // Handle case where token is null (not logged in)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to create an apartment'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit function early
    }

    final response = await http.post(
      Uri.parse(baseUrl + '/apartments'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Add authorization header with token
      },
      body: jsonEncode({'name': name, 'PIN': pin}),
    );

    if (response.statusCode == 200) {
      // Apartment created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apartment created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Clear text fields after creating the apartment
      _nameController.clear();
      _pinController.clear();

      // Redirect to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      // Failed to create apartment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create apartment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Apartment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Apartment Name',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'PIN Code',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6, // Limit input to 6 characters
            ),
            SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () {
                _createApartment(context); // Call create apartment function
              },
              child: Text('Create Apartment'),
            ),
          ],
        ),
      ),
    );
  }
}
