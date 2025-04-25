import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HorizontalLineWithText extends StatelessWidget {
  final String text;
  final double thickness;
  final Color lineColor;
  final TextStyle? textStyle;

  const HorizontalLineWithText({
    Key? key,
    this.text = "OR",
    this.thickness = 1.0,
    this.lineColor = Colors.grey,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: thickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: textStyle ?? TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}
