import 'package:flutter/material.dart';

class QuizLoadingScreen extends StatefulWidget {
  final VoidCallback onLoadingComplete;
  
  const QuizLoadingScreen({super.key, required this.onLoadingComplete});

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onLoadingComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const darkBg = Color(0xFF050F10);

    return Scaffold(
      backgroundColor: darkBg,
      body: Center(
        child: Text(
          'LOADING...',
          style: TextStyle(
            color: primaryCyan,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 6.0,
          ),
        ),
      ),
    );
  }
}
