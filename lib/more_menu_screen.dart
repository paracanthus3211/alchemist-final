import 'dart:ui';
import 'package:flutter/material.dart';
import 'articles_screen.dart';
import 'add_friends_screen.dart';
import 'virtual_lab_screen.dart';
import 'bookmark_screen.dart';

class MoreMenuPopup extends StatelessWidget {
  const MoreMenuPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF00B0CC).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Menu Lainnya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih fitur tambahan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),
                _buildMenuItem(
                  context,
                  title: 'Neon Library',
                  icon: Icons.library_books_rounded,
                  color: const Color(0xFFFF8C00),
                  onTap: () {
                    Navigator.pop(context); // Close popup
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ArticlesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: 'Virtual Lab',
                  icon: Icons.science_rounded,
                  color: const Color(0xFF2E8B57),
                  onTap: () {
                    Navigator.pop(context); // Close popup
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VirtualLabScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: 'Tambah Teman',
                  icon: Icons.person_add_rounded,
                  color: const Color(0xFF0A6DF4),
                  onTap: () {
                    Navigator.pop(context); // Close popup
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddFriendsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: 'Bookmarks',
                  icon: Icons.bookmark_rounded,
                  color: const Color(0xFFCCFF00),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarkScreen()));
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
