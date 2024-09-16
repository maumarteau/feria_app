// lib/widgets/input_field.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final TextEditingController controller;

  const InputField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? textWhiteGrey,
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black, fontSize: 20, height: 1.5),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: heading6.copyWith(
              color: const Color.fromARGB(255, 111, 111, 111)),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: prefixIcon,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: suffixIcon,
                )
              : null,
        ),
      ),
    );
  }
}
