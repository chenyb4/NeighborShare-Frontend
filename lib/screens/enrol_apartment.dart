import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:aad_hybrid/configs/backend_address.dart'; // Import backend address
import 'package:aad_hybrid/utils/helperFunctions.dart';

import 'home.dart';



class EnrolApartment extends StatefulWidget {
  @override
  _EnrolApartmentState createState() => _EnrolApartmentState();
}

class _EnrolApartmentState extends State<EnrolApartment> {
  late List<Map<String, dynamic>> _apartments = []; // List to store apartments
  late String _selectedApartment = ''; // Currently selected apartment
  late String _pinCode = ''; // User-entered PIN code


  @override
  void initState() {
    super.initState();
    _fetchApartments(); // Fetch apartments when widget initializes
  }

  // Function to fetch apartments
  Future<void> _fetchApartments() async {
    final response = await http.get(
      Uri.parse(baseUrl + '/apartments'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _apartments = jsonDecode(response.body).cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to fetch apartments');
    }
  }


  // Function to retrieve token from SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Function to handle enrolment
  Future<void> _enrolUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userEmail = prefs.getString('email');

    // Check if user email is available
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User email not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find the selected apartment
    final selectedApartment = _apartments.firstWhere(
          (apartment) => apartment['name'] == _selectedApartment,
      orElse: () => {'id': '', 'PIN': ''}, // Default empty apartment
    );

    // Check if selected apartment is found and PIN matches
    if (selectedApartment['id'] != '' && selectedApartment['PIN'] == _pinCode) {
      final String? token = await _getToken(); // Retrieve token from SharedPreferences

      if (token == null) {
        // Handle case where token is null (user not logged in)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to enrol in an apartment'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + '/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add authorization header with token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        // Retrieve user from the list based on email
        final user = users.firstWhere(
              (user) => user['email'] == userEmail,
          orElse: () => null,
        );

        if (user != null) {
          final userId = user['_id'];
          final response = await http.put(
            Uri.parse(baseUrl + '/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // Add authorization header with token
            },
            body: jsonEncode({'apartment_id': selectedApartment['_id']}),
          );

          if (response.statusCode == 200) {
            // User enrolled successfully
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Enrolled successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to Home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else {
            // Failed to enrol user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to enrol'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // User not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Failed to fetch users
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch users'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Handle case where selected apartment is not found or PIN doesn't match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid apartment or PIN code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrol Apartment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedApartment.isNotEmpty ? _selectedApartment : null, // Set initial value to null if _selectedApartment is empty
              onChanged: (newValue) {
                setState(() {
                  _selectedApartment = newValue!;
                });
              },
              items: _apartments
                  .map<DropdownMenuItem<String>>((apartment) => DropdownMenuItem<String>(
                value: apartment['name'],
                child: Text(apartment['name']),
              ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Select Apartment',
              ),
            ),

            SizedBox(height: 16),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _pinCode = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter PIN Code',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _enrolUser,
              child: Text('Enrol'),
            ),
          ],
        ),
      ),
    );
  }
}
