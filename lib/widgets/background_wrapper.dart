import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool removeSafeAreaPadding;

  const BackgroundWrapper({
    super.key, 
    required this.child,
    this.removeSafeAreaPadding = false,
    this.showGrid = false,
  });

  final bool showGrid;

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      backgroundColor: const Color(0xFF0B1214), // Dark charcoal background
      body: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          // Large main glow in the top-left/center
          Positioned(
            top: -150,
            left: -100,
            child: _buildCircle(
              opacity: 0.1, 
              size: 500, 
              color: const Color(0xFF00E5FF),
            ),
          ),
          
          // Secondary glow in the bottom-right
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildCircle(
              opacity: 0.08, 
              size: 400, 
              color: const Color(0xFF00B0CC),
            ),
          ),

          // Central subtle glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -50,
            child: _buildCircle(
              opacity: 0.05, 
              size: 300, 
              color: const Color(0xFFCCFF00), // Lime subtle glow
            ),
          ),

          // Background decorations (simulated molecular patterns)
          Positioned(
            top: 40,
            right: 20,
            child: _buildNodesPattern(opacity: 0.05, scale: 0.8),
          ),
          Positioned(
            bottom: 80,
            left: -20,
            child: _buildNodesPattern(opacity: 0.04, scale: 1.2),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: -20,
            child: _buildNodesPattern(opacity: 0.04, scale: 0.6),
          ),
          
          // Main content
          SafeArea(
            child: removeSafeAreaPadding 
              ? child 
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: child,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle({required double opacity, required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildNodesPattern({required double opacity, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: NodesPainter(color: const Color(0xFF00E5FF).withValues(alpha: opacity)),
          ),
        ),
      ),
    );
  }
}

class NodesPainter extends CustomPainter {
  final Color color;

  NodesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final p1 = const Offset(20, 20);
    final p2 = const Offset(80, 40);
    final p3 = const Offset(50, 80);
    final p4 = const Offset(90, 90);

    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p2, p3, paint);
    canvas.drawLine(p3, p4, paint);

    canvas.drawCircle(p1, 8, fillPaint);
    canvas.drawCircle(p2, 5, fillPaint);
    canvas.drawCircle(p3, 6, fillPaint);
    
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawCircle(p4, 10, borderPaint);
    canvas.drawCircle(p4, 6, fillPaint..color = Colors.transparent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const double step = 30.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
