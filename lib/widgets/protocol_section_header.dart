import 'package:flutter/material.dart';

class ProtocolSectionHeader extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color color;

  const ProtocolSectionHeader({
    super.key,
    required this.title,
    required this.iconData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
