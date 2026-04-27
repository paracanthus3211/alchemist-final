import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
import 'widgets/custom_back_button.dart';
import 'widgets/protocol_section_header.dart';
import 'widgets/coordinate_input.dart';
import 'widgets/polarity_card.dart';
import 'topic_selection_screen.dart';

class BirthGenderScreen extends StatefulWidget {
  const BirthGenderScreen({super.key});

  @override
  State<BirthGenderScreen> createState() => _BirthGenderScreenState();
}

class _BirthGenderScreenState extends State<BirthGenderScreen> {
  int _selectedGender = -1; // -1 for none, 0 for female, 1 for male
  
  // Controllers for date input
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const CustomBackButton(),
            const SizedBox(height: 32),
            
            // Section 1: TEMPORAL COORDINATE
            const ProtocolSectionHeader(
              title: 'TEMPORAL COORDINATE',
              iconData: Icons.calendar_today_outlined,
              color: Color(0xFF00E5FF),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CoordinateInput(
                    label: 'DAY',
                    placeholder: 'DD',
                    controller: _dayController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CoordinateInput(
                    label: 'MONTH',
                    placeholder: 'MM',
                    controller: _monthController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CoordinateInput(
                    label: 'YEAR',
                    placeholder: 'YYYY',
                    controller: _yearController,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Section 2: BIOLOGICAL POLARITY
            const ProtocolSectionHeader(
              title: 'BIOLOGICAL POLARITY',
              iconData: Icons.biotech_outlined,
              color: Color(0xFFCCFF00), // Lime
            ),
            const SizedBox(height: 24),
            PolarityCard(
              title: 'MALE',
              subtitle: 'TYPE-ALPHA STRUCTURE',
              iconData: Icons.male,
              isSelected: _selectedGender == 1,
              onTap: () => setState(() => _selectedGender = 1),
            ),
            PolarityCard(
              title: 'FEMALE',
              subtitle: 'TYPE-BETA STRUCTURE',
              iconData: Icons.female,
              isSelected: _selectedGender == 0,
              onTap: () => setState(() => _selectedGender = 0),
            ),
            
            const SizedBox(height: 32),
            
            // Continue Button
            Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF00B0CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TopicSelectionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Color(0xFF0B1214),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward, color: Color(0xFF0B1214), size: 24),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer: PROTOCOL PHASE
            const Center(
              child: Text(
                'PROTOCOL PHASE 01 / 03',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );

  }
}
