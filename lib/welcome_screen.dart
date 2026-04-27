import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1214), // Dark charcoal background
      body: Stack(
        children: [
          // Background Molecular Pattern
          const Positioned.fill(
            child: MolecularBackground(),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Illustration
                  Hero(
                    tag: 'alchemist_hero',
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/alchemist_hero.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Heading
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit', // Or default if not available
                      ),
                      children: [
                        TextSpan(text: 'We are '),
                        TextSpan(
                          text: 'what',
                          style: TextStyle(color: Color(0xFF00E5FF)), // Cyan
                        ),
                        TextSpan(text: '\nwe '),
                        TextSpan(
                          text: 'do',
                          style: TextStyle(color: Color(0xFFCCFF00)), // Lime
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Subheading
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Thousands of people are using Alchemist for study. Master the elements of your future.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Sign Up Button
                  const GradientButton(
                    text: 'Sign Up',
                    icon: Icons.arrow_forward_rounded,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Log In Text
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF00B0CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF0B1214),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: const Color(0xFF0B1214)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MolecularBackground extends StatelessWidget {
  const MolecularBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NodePainter(),
    );
  }
}

class NodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    final nodePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Drawing some nodes and lines to simulate the molecular pattern from the mockup
    final nodes = [
      const Offset(50, 450),
      const Offset(80, 480),
      const Offset(30, 500),
      Offset(size.width - 50, 500),
      Offset(size.width - 20, 540),
      Offset(size.width - 80, 560),
    ];

    for (var i = 0; i < nodes.length; i++) {
      canvas.drawCircle(nodes[i], 6, nodePaint);
      if (i < nodes.length - 1 && i != 2) {
        canvas.drawLine(nodes[i], nodes[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
