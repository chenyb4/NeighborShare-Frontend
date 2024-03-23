import 'package:flutter/material.dart';
import 'package:aad_hybrid/screens/enrol_apartment.dart';
import 'package:aad_hybrid/screens/create_apartment.dart';

class EnrolOrCreate extends StatelessWidget {
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
          ],
        ),
      ),
    );
  }
}
