import 'dart:convert';
import 'package:aad_hybrid/utils/backend_address.dart';
import 'package:aad_hybrid/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  late TextEditingController _partyNameController;
  late TextEditingController _descriptionController;

  late TextEditingController _apartmentNumberController;

  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _partyNameController = TextEditingController();
    _descriptionController = TextEditingController();

    _apartmentNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _descriptionController.dispose();

    _apartmentNumberController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final Map<String, dynamic> itemData = {
      'name': _partyNameController.text,
      'description': _descriptionController.text,
      'apartmentNumber': _apartmentNumberController.text,
      'isAvailable': _isAvailable,
      'ownerEmail':'chenyb4work@outlook.com'
    };

    final response = await http.post(
      Uri.parse(baseUrl+'/items/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(itemData),
    );

    if (response.statusCode == 200) {
      // Item added successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Clear text fields after adding the item
      _partyNameController.clear();
      _descriptionController.clear();

      _apartmentNumberController.clear();
      setState(() {
        _isAvailable = true;
      });

      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.pop(context);
      });

    } else {
      // Item addition failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add an Item"),
        centerTitle: true,
        backgroundColor: themeColorShade1,
      ),
      body: Center(
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              children: [
                TextField(
                  controller: _partyNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item Name',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _apartmentNumberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Apartment Number',
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Available'),
                    Checkbox(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addItem,
                  child: Text(
                    "Add Item",
                    style: TextStyle(color: themeColorShade1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
