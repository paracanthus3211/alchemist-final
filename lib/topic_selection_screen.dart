import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
import 'main_scaffold.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  final Set<int> _selectedIndices = {};

  final List<Map<String, dynamic>> _topics = [
    {'icon': Icons.school_rounded, 'title': 'FOR STUDY &\nLEARNING'},
    {'icon': Icons.sentiment_very_satisfied_rounded, 'title': 'FOR FUN'},
    {'icon': Icons.work_rounded, 'title': 'FOR WORK &\nCAREER'},
    {'icon': Icons.edit_note_rounded, 'title': 'FOR SELF\nDEVELOPMENT'},
    {'icon': Icons.emoji_events_rounded, 'title': 'FOR EXAM AND\nASSESSMENT'},
    {'icon': Icons.biotech_rounded, 'title': 'FOR RESEARCH &\nEXPLORATION'},
  ];

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const cardBgColor = Color(0xFF111718);

    return BackgroundWrapper(
      showGrid: true,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- TITLE AREA ---
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'What Brings you\nto ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'Alchemist?',
                                  style: TextStyle(color: primaryCyan),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'choose a topic:',
                            style: TextStyle(
                              color: primaryCyan,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2,
                            ),
                          ),
                          
                          const SizedBox(height: 48),

                          // --- GRID AREA ---
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _topics.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedIndices.contains(index);
                              return GestureDetector(
                                onTap: () => _toggleSelection(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: isSelected ? primaryCyan : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      if (isSelected) 
                                        BoxShadow(
                                          color: primaryCyan.withValues(alpha: 0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _topics[index]['icon'] as IconData,
                                        color: primaryCyan,
                                        size: 72,
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                        child: Text(
                                          _topics[index]['title'] as String,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: primaryCyan,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- BUTTON AREA ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: _selectedIndices.isNotEmpty
                          ? () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainScaffold()),
                                (route) => false,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: primaryCyan.withValues(alpha: 0.3),
                        shape: const StadiumBorder(),
                        elevation: 10,
                        shadowColor: primaryCyan.withValues(alpha: 0.5),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
