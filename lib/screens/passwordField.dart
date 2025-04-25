import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({Key? key, required this.controller}) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscured = true; // Initial state for password visibility

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _isObscured, // Dynamically toggle visibility
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.password),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured; // Toggle visibility state
            });
          },
        ),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.black), // Black border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.black), // Black border when focused
        ),
      ),
    );
  }

}