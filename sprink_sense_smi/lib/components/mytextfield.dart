import 'package:flutter/material.dart';
import 'package:sprink_sense_smi/components/constant.dart';


class MyTextfield extends StatefulWidget {
  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.isPassword = false, // New flag for password fields
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool isPassword;

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  bool isObscure = true; // Default: Hide password

  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? isObscure : widget.obscureText,
        style: TextStyle(fontSize: 16, color: KTetxt),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: KTetxt),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: KSecondary),
            borderRadius: BorderRadius.circular(0),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: KInactiveText, fontSize: 14),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: KInactiveText,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure; // Toggle visibility
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
