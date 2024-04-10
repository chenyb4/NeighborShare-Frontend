
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/Item.dart';
import '../configs/colors.dart';

class ItemDetails extends StatelessWidget {
  final Item item;

  ItemDetails({required this.item});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes = item.imageData != null
        ? Uint8List.fromList(item.imageData!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null)
              Container(
                width: double.infinity,
                height: 200,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            _buildDetailRow('Description', item.description),
            SizedBox(height: 20),
            _buildDetailRow('Owner Email', item.ownerEmail),
            SizedBox(height: 20),
            _buildDetailRow('Apartment Number', item.apartmentNumber),
            SizedBox(height: 20),
            _buildDetailRow(
              'Availability',
              item.isAvailable ? 'Available' : 'Unavailable',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: isLast ? themeColor : Colors.black,
          ),
        ),
        if (!isLast) SizedBox(height: 10),
        if (!isLast)
          Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
      ],
    );
  }
}
