import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback cancelCallback;
  final VoidCallback logoutCallback;

  LogoutDialog({required this.cancelCallback, required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: cancelCallback,
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: logoutCallback,
          child: Text('Logout'),
        ),
      ],
    );
  }
}
