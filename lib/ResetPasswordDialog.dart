import 'package:flutter/material.dart';

class ResetPasswordDialog extends StatefulWidget {
  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
            ),
          ),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform the password reset logic here
            // You can access the password and confirm values using:
            // _passwordController.text and _confirmController.text
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Reset Password'),
        ),
      ],
    );
  }
}