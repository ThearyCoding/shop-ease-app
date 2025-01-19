import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final void Function()? onPressed;
  final Color? backgroundColor;
  final String textBtn;
  final double? radius;
  const CustomBtn(
      {super.key,
      required this.onPressed,
      required this.textBtn,
      this.backgroundColor,
      this.radius = 0});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: radius == 0
                    ? BorderRadius.zero
                    : BorderRadius.circular(radius!))),
        onPressed: onPressed,
        child: Text(textBtn));
  }
}
