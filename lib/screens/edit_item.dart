import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/Item.dart';
import '../configs/backend_address.dart';
import '../configs/colors.dart';
import 'package:http/http.dart' as http;

class EditItem extends StatefulWidget {
  final Item item;

  EditItem({required this.item});

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _apartmentNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _apartmentNumberController = TextEditingController(text: widget.item.apartmentNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
        backgroundColor: themeColorShade1,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _apartmentNumberController,
              decoration: InputDecoration(labelText: 'Apartment Number'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Update item and navigate back
                Item updatedItem = Item(
                  id: widget.item.id,
                  name: _nameController.text,
                  description: _descriptionController.text,
                  ownerEmail: widget.item.ownerEmail,
                  apartmentNumber: _apartmentNumberController.text,
                  isAvailable: widget.item.isAvailable,
                );
                // Call function to update item
                _updateItem(updatedItem);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateItem(Item item) async {
    // Send request to update item
    final response = await http.put(
      Uri.parse(baseUrl+'/items/${item.id}'),
      body: jsonEncode(item.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      // Item updated successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate back to home screen
      Navigator.pop(context);
    } else {
      // Failed to update item
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _apartmentNumberController.dispose();
    super.dispose();
  }
}
