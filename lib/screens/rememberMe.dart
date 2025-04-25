import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RememberMe extends StatefulWidget {
  final bool initialValue; // Initial value for the checkbox
  final ValueChanged<bool> onChanged; // Callback to notify parent of changes

  const RememberMe({
    Key? key,
    this.initialValue = false,
    required this.onChanged,
  }) : super(key: key);

  @override
  _RememberMeState createState() => _RememberMeState();
}

class _RememberMeState extends State<RememberMe> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  void _toggleCheckbox(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });
    widget.onChanged(_isChecked); // Notify parent of change
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: _toggleCheckbox,
        ),
        Text('Remember Me'),
      ],
    );
  }
}