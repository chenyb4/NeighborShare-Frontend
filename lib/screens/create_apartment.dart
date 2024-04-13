import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aad_hybrid/configs/backend_address.dart';
import 'package:aad_hybrid/screens/home.dart';
import '../components/apartment_form.dart';
import '../components/create_ apartment_button.dart';


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

    final String? token = await _getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to create an apartment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl + '/apartments'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'PIN': pin}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apartment created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _nameController.clear();
      _pinController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
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
            ApartmentForm(
              nameController: _nameController,
              pinController: _pinController,
            ),
            SizedBox(height: 20.0),
            CreateApartmentButton(
              onPressed: () {
                _createApartment(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
