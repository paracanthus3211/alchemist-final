import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F21), // Dark matching CustomTextField
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new, // Sleeker arrow icon
          color: Color(0xFF00E5FF), // Neon Cyan
          size: 20,
        ),
      ),
    );
  }
}
