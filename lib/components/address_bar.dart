import 'package:flutter/material.dart';
import 'package:aad_hybrid/configs/colors.dart';

class AddressBar extends StatelessWidget {
  final Future<String> addressFuture;

  AddressBar({required this.addressFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: addressBarBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: FutureBuilder<String>(
        future: addressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: addressBarTextColor,
                ),
                SizedBox(width: 8.0),
                Text(
                  '${snapshot.data}',
                  style: TextStyle(
                    color: addressBarTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
