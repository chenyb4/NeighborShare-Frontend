import 'package:flutter/material.dart';

class ApartmentForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController pinController;

  const ApartmentForm({
    required this.nameController,
    required this.pinController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Apartment Name',
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: pinController,
          decoration: InputDecoration(
            labelText: 'PIN Code',
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        SizedBox(height: 50.0),
      ],
    );
  }
}
