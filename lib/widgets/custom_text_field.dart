import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? suffixIconData;
  final IconData? prefixIconData;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconData,
    this.prefixIconData,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF232D30), // Dark semi-transparent background
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3), 
            fontSize: 14, 
            fontWeight: FontWeight.w400, 
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: InputBorder.none,
          prefixIcon: prefixIconData != null 
            ? Icon(prefixIconData, color: const Color(0xFF00E5FF).withValues(alpha: 0.7), size: 22) 
            : null,
          suffixIcon: suffixIcon ?? (suffixIconData != null 
            ? Icon(suffixIconData, color: const Color(0xFF00E5FF).withValues(alpha: 0.8), size: 20) 
            : null),
        ),
      ),
    );
  }
}
