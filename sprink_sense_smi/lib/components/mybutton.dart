import 'package:flutter/material.dart';
import 'package:sprink_sense_smi/components/constant.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.onTap, required this.text});

  final Function()? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18), // Adjusted padding
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: KPrimary, // Primary color
          borderRadius: BorderRadius.circular(12), // More rounded corners
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2), // Subtle shadow
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: KTetxt,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Slightly larger text
            ),
          ),
        ),
      ),
    );
  }
}
