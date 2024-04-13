import 'package:flutter/material.dart';

class CreateApartmentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateApartmentButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Create Apartment'),
    );
  }
}
