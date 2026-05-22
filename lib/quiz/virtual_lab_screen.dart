import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VirtualLabScreen extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final Function(int index) onOptionSelected;
  final Function(bool isCorrectMix) onMixChanged;

  const VirtualLabScreen({
    super.key,
    required this.questionData,
    required this.onOptionSelected,
    required this.onMixChanged,
  });

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen> {
  String? _selectedA;
  String? _selectedB;
  bool _isMixed = false;
  int? _selectedOptionIndex;
  String _activeBeaker = 'A';

  // ── Normalization & Comparison Logic ──

  String _normalize(String str) {
    return str
        .toLowerCase()
        .replaceAll('₀', '0')
        .replaceAll('₁', '1')
        .replaceAll('₂', '2')
        .replaceAll('₃', '3')
        .replaceAll('₄', '4')
        .replaceAll('₅', '5')
        .replaceAll('₆', '6')
        .replaceAll('₇', '7')
        .replaceAll('₈', '8')
        .replaceAll('₉', '9')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  bool _compareChemical(String? currentId, String? expectedFullString) {
    if (currentId == null || expectedFullString == null) return false;
    final current = _normalize(currentId);
    final expected = _normalize(expectedFullString);
    if (current == expected) return true;
    if (expected.contains(current) || current.contains(expected)) return true;
    return false;
  }

  bool _isCorrectMix() {
    final config = widget.questionData['lab_practice_config'];
    if (config == null) return false;
    final expectedA = config['beaker_a_chemical']?.toString();
    final expectedB = config['beaker_b_chemical']?.toString();
    return (_compareChemical(_selectedA, expectedA) && _compareChemical(_selectedB, expectedB)) ||
           (_compareChemical(_selectedA, expectedB) && _compareChemical(_selectedB, expectedA));
  }

  // ── Chemical Reagents Database (with type labels) ──

  final Map<String, dynamic> _chemicals = {
    'hcl': {'name': 'HCl', 'fullName': 'Asam Klorida', 'type': 'Acid', 'color': const Color(0xFF9B6B6B), 'shadow': const Color(0xFF6D4A4A)},
    'naoh': {'name': 'NaOH', 'fullName': 'Natrium Hidroksida', 'type': 'Basa', 'color': const Color(0xFF1E88E5), 'shadow': const Color(0xFF1565C0)},
    'agno3': {'name': 'AgNO₃', 'fullName': 'Perak Nitrat', 'type': 'Salt', 'color': const Color(0xFF9E9E9E), 'shadow': const Color(0xFF757575)},
    'nacl': {'name': 'NaCl', 'fullName': 'Natrium Klorida', 'type': 'Salt', 'color': const Color(0xFF8A8A8A), 'shadow': const Color(0xFF636363)},
    'zn': {'name': 'Zn', 'fullName': 'Seng', 'type': 'Metal', 'color': const Color(0xFF9E9E9E), 'shadow': const Color(0xFF757575)},
    'h2so4': {'name': 'H₂SO₄', 'fullName': 'Asam Sulfat', 'type': 'Acid', 'color': const Color(0xFFF59E0B), 'shadow': const Color(0xFFB97008)},
    'cuso4': {'name': 'CuSO₄', 'fullName': 'Tembaga Sulfat', 'type': 'Salt', 'color': const Color(0xFF2E7D32), 'shadow': const Color(0xFF1B5E20)},
  };

  // ── Liquid colors for beaker display ──
  final Map<String, Color> _liquidColors = {
    'hcl': const Color(0xFFEF5350),
    'naoh': const Color(0xFF42A5F5),
    'agno3': const Color(0xFFB0BEC5),
    'nacl': const Color(0xFF78909C),
    'zn': const Color(0xFF90A4AE),
    'h2so4': const Color(0xFFFF7043),
    'cuso4': const Color(0xFF66BB6A),
  };

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabWorkbench(),
          const SizedBox(height: 24),
          _buildInventory(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          if (_isMixed) ...[
            const SizedBox(height: 24),
            _buildOptionsList(),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Lab Workbench with Colorful Beakers ──

  Widget _buildLabWorkbench() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Beaker A
          _buildBeaker('BEAKER A', _selectedA, _activeBeaker == 'A',
            () => setState(() => _activeBeaker = 'A')),
          const SizedBox(width: 16),
          // Plus operator
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text('+',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF00FBFF), fontSize: 28, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Beaker B
          _buildBeaker('BEAKER B', _selectedB, _activeBeaker == 'B',
            () => setState(() => _activeBeaker = 'B')),
          const SizedBox(width: 16),
          // Equals operator
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text('=',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF00FBFF), fontSize: 28, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Beaker C (Result)
          _buildBeaker('BEAKER C', _isMixed ? 'result' : null, false,
            () {}, isResult: true),
        ],
      ),
    );
  }

  // ── Individual Beaker (CustomPainter U-shape Design) ──

  Widget _buildBeaker(String label, String? chemId, bool isActive, VoidCallback onTap, {bool isResult = false}) {
    Color? liquidColor;
    String chemName = '';

    if (chemId == 'result') {
      liquidColor = const Color(0xFF00BCD4);
      chemName = 'RESULT';
    } else if (chemId != null && _liquidColors.containsKey(chemId)) {
      liquidColor = _liquidColors[chemId]!;
      chemName = (_chemicals[chemId]?['name'] as String? ?? '').toUpperCase()
          .replaceAll('₂', '2').replaceAll('₃', '3').replaceAll('₄', '4');
    }

    // Build label text
    String labelText = chemName.isNotEmpty ? '$label ($chemName)' : label;

    // Border color
    Color borderColor;
    if (isActive) {
      borderColor = const Color(0xFF00FBFF);
    } else if (isResult && liquidColor != null) {
      borderColor = const Color(0xFF00BCD4).withOpacity(0.6);
    } else {
      borderColor = Colors.white.withOpacity(0.35);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Beaker using CustomPainter
          SizedBox(
            width: 90,
            height: 115,
            child: CustomPaint(
              painter: _BeakerPainter(
                liquidColor: liquidColor,
                fillLevel: liquidColor != null ? 0.6 : 0.0,
                borderColor: borderColor,
                borderWidth: 3.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Label text
          Text(
            labelText,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: liquidColor != null ? Colors.white54 : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Chemical Reagents (Colorful Chips with Type Labels) ──

  Widget _buildInventory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _chemicals.entries.map((e) {
            bool isSelected = _selectedA == e.key || _selectedB == e.key;
            Color chipColor = e.value['color'] as Color;
            Color shadowColor = e.value['shadow'] as Color;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_activeBeaker == 'A') _selectedA = e.key;
                  else _selectedB = e.key;
                  _isMixed = false;
                  widget.onMixChanged(false);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 78,
                height: 54,
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 50,
                  transform: Matrix4.translationValues(0, isSelected ? 0 : -4, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (e.value['name'] as String).toUpperCase()
                            .replaceAll('₂', '2').replaceAll('₃', '3').replaceAll('₄', '4'),
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.value['type'] as String,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Action Buttons (MIX & REACT + RESET) ──

  Widget _buildActionButtons() {
    bool canMix = _selectedA != null && _selectedB != null;

    return Row(
      children: [
        // MIX & REACT button (3D style)
        GestureDetector(
          onTap: canMix ? () {
            setState(() => _isMixed = true);
            widget.onMixChanged(_isCorrectMix());
          } : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: canMix ? const Color(0xFF006064) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 44,
              transform: Matrix4.translationValues(0, -4, 0),
              decoration: BoxDecoration(
                color: canMix ? const Color(0xFF00BCD4) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.science, color: canMix ? Colors.white : Colors.white30, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'MIX & REACT',
                    style: GoogleFonts.spaceGrotesk(
                      color: canMix ? Colors.white : Colors.white30,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // RESET button (3D style, red)
        GestureDetector(
          onTap: () => setState(() {
            _selectedA = null;
            _selectedB = null;
            _isMixed = false;
            _selectedOptionIndex = null;
            _activeBeaker = 'A';
            widget.onMixChanged(false);
          }),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF7A1C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 44,
              transform: Matrix4.translationValues(0, -4, 0),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'RESET',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Multiple Choice Options (Duolingo 3D Buttons) ──

  Widget _buildOptionsList() {
    final options = widget.questionData['multiple_choice_options'] as List? ?? [];
    return Column(
      children: List.generate(options.length, (index) {
        final opt = options[index];
        bool isSelected = _selectedOptionIndex == index;

        // Duolingo-style colors
        Color baseColor = isSelected ? const Color(0xFFCCFF00) : const Color(0xFF00838F);
        Color shadowColor = isSelected ? const Color(0xFF8AAF00) : const Color(0xFF004D40);
        Color textColor = isSelected ? Colors.black : Colors.white;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedOptionIndex = index);
            widget.onOptionSelected(index);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: shadowColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              height: 52,
              transform: Matrix4.translationValues(0, -4, 0),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Letter label with divider
                  Container(
                    width: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.black.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      opt['option_label'] ?? String.fromCharCode(65 + index),
                      style: GoogleFonts.spaceGrotesk(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  // Option text
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        (opt['option_text'] ?? '').toString().toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BeakerPainter extends CustomPainter {
  final Color? liquidColor;
  final double fillLevel; // 0.0 to 1.0 (1.0 is full)
  final Color borderColor;
  final double borderWidth;

  _BeakerPainter({
    this.liquidColor,
    this.fillLevel = 0.0,
    required this.borderColor,
    this.borderWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = 20.0; // Curve radius for the bottom corners

    // 1. Draw Liquid Fill (if present)
    if (liquidColor != null && fillLevel > 0) {
      final fillHeight = size.height * fillLevel;
      final fillRect = Rect.fromLTRB(
        borderWidth / 2, // Start slightly inside the border
        size.height - fillHeight,
        size.width - (borderWidth / 2),
        size.height,
      );

      // Create a path for the fill to respect the bottom border curves
      final fillPath = Path()
        ..moveTo(fillRect.left, fillRect.top)
        ..lineTo(fillRect.right, fillRect.top)
        ..lineTo(fillRect.right, fillRect.bottom - radius)
        ..arcToPoint(
          Offset(fillRect.right - radius, fillRect.bottom - (borderWidth / 2)),
          radius: Radius.circular(radius),
          clockwise: true,
        )
        ..lineTo(fillRect.left + radius, fillRect.bottom - (borderWidth / 2))
        ..arcToPoint(
          Offset(fillRect.left, fillRect.bottom - radius),
          radius: Radius.circular(radius),
          clockwise: true,
        )
        ..close();

      final fillPaint = Paint()
        ..color = liquidColor!
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // 2. Draw Beaker Border (U-Shape)
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square; // Flat top edges

    final borderPath = Path()
      ..moveTo(0, 0) // Top left
      ..lineTo(0, size.height - radius) // Down left side
      ..arcToPoint(
        Offset(radius, size.height), // Bottom left curve
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width - radius, size.height) // Bottom flat
      ..arcToPoint(
        Offset(size.width, size.height - radius), // Bottom right curve
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, 0); // Up right side

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BeakerPainter oldDelegate) {
    return oldDelegate.liquidColor != liquidColor ||
           oldDelegate.fillLevel != fillLevel ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth;
  }
}
