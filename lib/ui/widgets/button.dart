import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_flow/utils/theme.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Function()?
      onTap; // you are not sure whether get this function or not, if doesn't get just keep it null
  const MyButton({Key? key, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: primaryClr,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
