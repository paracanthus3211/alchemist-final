import 'package:flutter/material.dart';

class PolarityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const PolarityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF142426) : const Color(0xFF161B1D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F21),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: const Color(0xFF00E5FF),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            // Custom Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
                  width: 2,
                ),
              ),
              child: isSelected ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E5FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ) : null,
            ),
          ],
        ),
      ),
    );
  }
}
