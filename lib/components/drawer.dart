import 'package:flutter/material.dart';

import 'package:aad_hybrid/configs/colors.dart';
import 'package:aad_hybrid/screens/my_items.dart';


class CustomDrawer extends StatelessWidget {
  final VoidCallback logoutCallback;

  CustomDrawer({required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: themeColor, // Assuming themeColor is defined in colors.dart
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('My Items'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyItems(), // Assuming MyItems widget is defined in my_items.dart
                ),
              );
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: logoutCallback,
          ),
        ],
      ),
    );
  }
}
