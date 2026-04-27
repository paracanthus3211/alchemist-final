import 'package:flutter/material.dart';

class CoordinateInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;

  const CoordinateInput({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F21),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: placeholder.toUpperCase(),
                hintStyle: const TextStyle(color: Colors.white24),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F21),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
