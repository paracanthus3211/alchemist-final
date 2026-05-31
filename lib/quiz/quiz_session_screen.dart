import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../virtual_lab_screen.dart';
import '../services/api_service.dart';
import '../widgets/background_wrapper.dart';

class QuizSessionScreen extends StatefulWidget {
  final List<dynamic> questions;
  final int levelId;
  final String levelName;
  final int? timerLimit;

  const QuizSessionScreen({
    super.key, 
    required this.questions, 
    required this.levelId, 
    required this.levelName,
    this.timerLimit,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _currentIndex = 0;
  List<dynamic> _activeQuestions = [];
  List<dynamic> _retryQueue = [];
  int _totalXpEarned = 0;
  bool _showExplanation = false;
  bool _isLastResultCorrect = false;
  List<String> _userArrangement = [];
  final Set<int> _failedQuestions = {};
  final Set<int> _correctQuestions = {};
  bool _isCheckPressed = false;
  bool _isCorrectMix = false;
  bool _isReadMorePressed = false;

  // Timer & Scoring fields
  late Stopwatch _stopwatch;
  int _wrongAnswersCount = 0;
  int? _timerLimit; // in seconds

  @override
  void initState() {
    super.initState();
    _activeQuestions = List.from(widget.questions);
    _stopwatch = Stopwatch()..start();
    _timerLimit = widget.timerLimit;
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      _isLastResultCorrect = isCorrect;
      _showExplanation = true;
      final currentQ = _activeQuestions[_currentIndex];
      
      if (isCorrect) {
        if (!_failedQuestions.contains(currentQ['id']) && !_correctQuestions.contains(currentQ['id'])) {
          _totalXpEarned += (int.tryParse(currentQ['xp_reward']?.toString() ?? '') ?? 10);
          _correctQuestions.add(currentQ['id']);
        }
      } else {
        _wrongAnswersCount++;
        _failedQuestions.add(currentQ['id']);
        if (!_retryQueue.any((q) => q['id'] == currentQ['id'])) {
          _retryQueue.add(currentQ);
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _showExplanation = false;
      _userArrangement = [];
      if (_currentIndex < _activeQuestions.length - 1) {
        _currentIndex++;
      } else if (_retryQueue.isNotEmpty) {
        _activeQuestions = List.from(_retryQueue);
        _retryQueue = [];
        _currentIndex = 0;
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() async {
    _stopwatch.stop();
    int timeSpent = _stopwatch.elapsed.inSeconds;
    
    // Calculate Score
    int score = 100;
    
    // Penalty 1: Wrong answers (-10% each)
    score -= (_wrongAnswersCount * 10);
    
    // Penalty 2: Overtime (-1% per 5 seconds)
    if (_timerLimit != null && timeSpent > _timerLimit!) {
      int overtime = timeSpent - _timerLimit!;
      int penalty = (overtime / 5).floor();
      score -= penalty;
    }
    
    score = score.clamp(0, 100);

    // Save to backend
    if (_correctQuestions.isNotEmpty) {
      await ApiService().addUserXp(_correctQuestions.toList());
      await ApiService().saveLevelCompletion(widget.levelId, score, timeSpent, _wrongAnswersCount);
      await ApiService().getCurrentUser();
      // Add delay to ensure backend has processed the completion and data is ready
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    
    if (!mounted) return;

    String timeFormatted = '${(timeSpent / 60).floor()}:${(timeSpent % 60).toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1618),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: const Color(0xFF00FBFF).withOpacity(0.1)),
        ),
        title: Center(
          child: Text('LEVEL COMPLETE!', 
            style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FBFF), fontWeight: FontWeight.w900, letterSpacing: 2)
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Color(0xFFCCFF00), size: 64),
            ),
            const SizedBox(height: 24),
            _resultRow('FINAL SCORE', '$score%', const Color(0xFFCCFF00)),
            _resultRow('TOTAL XP', '+$_totalXpEarned XP', const Color(0xFF00FBFF)),
            _resultRow('DURATION', timeFormatted, Colors.white30),
            _resultRow('ERRORS', '$_wrongAnswersCount', Colors.redAccent.withOpacity(0.8)),
            if (_timerLimit != null && timeSpent > _timerLimit!)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Overtime penalty applied: -${(timeSpent - _timerLimit!) ~/ 5}%', 
                  style: GoogleFonts.spaceGrotesk(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to quiz map
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FBFF),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('BACK TO MAP', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          Text(value, style: GoogleFonts.spaceGrotesk(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_activeQuestions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQuestion = _activeQuestions[_currentIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFF050F10),
      body: BackgroundWrapper(
        showGrid: false,
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: _buildQuestionContent(currentQuestion),
            ),
            if (_showExplanation)
              _buildExplanationSection(currentQuestion)
            else
              _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final user = ApiService().currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'chapter ${widget.questions.isNotEmpty ? (widget.questions[0]['chapter_order'] ?? 1) : 1}: ${widget.levelName.toLowerCase()}',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF00FBFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1}/${_activeQuestions.length}',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ((_currentIndex + 1) / _activeQuestions.length).clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(dynamic question) {
    if (question is! Map) {
      return Center(
        child: Text(
          'Error: Invalid Question Data\n($question)',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (question['type'] == 'LAB_PRACTICE') {
      return VirtualLabScreen();
    }

    if (question['type'] == 'SENTENCE_ARRANGEMENT') {
      return _buildSentenceArrangement(question);
    }

    return _buildMultipleChoice(question);
  }

  int? _selectedOptionIndex;

  Widget _buildMultipleChoice(dynamic question) {
    final options = question['multiple_choice_options'] as List? ?? [];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              question['question_text'] ?? 'Partikel Atom Manakah\nYang Bermuatan Positif',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 48),
            ...List.generate(options.length, (index) {
              final opt = options[index];
              bool isSelected = _selectedOptionIndex == index;
              final Color baseColor = isSelected ? const Color(0xFF8AAF00) : const Color(0xFF006064);
              final Color shadowColor = isSelected ? const Color(0xFF5A7A00) : const Color(0xFF00383A);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedOptionIndex = index),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: shadowColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 52,
                      transform: Matrix4.translationValues(0, isSelected ? 0 : -5, 0),
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 72,
                            alignment: Alignment.center,
                            child: Text(
                              opt['option_label'] ?? String.fromCharCode(65 + index),
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 26,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                (opt['option_text'] ?? 'PROTON').toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceArrangement(dynamic question) {
    final List<dynamic> wordsData = question['sentence_arrangement_words'] as List? ?? [];
    final List<String> allWords = wordsData.map((e) => e['word_text'].toString()).toList();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question['question_text'] ?? 'Susun Definisi Proton Dengan Benar',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            // Result Box (Dashed)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 180),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00FBFF).withValues(alpha: 0.5), 
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: _userArrangement.isEmpty 
                ? const Center(child: Icon(Icons.apps, color: Colors.white10, size: 64))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _userArrangement.map((w) => _wordChip(w, true)).toList(),
                  ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: allWords.where((w) => !_userArrangement.contains(w)).map((w) => _wordChip(w, false)).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _wordChip(String word, bool isSelected) {
    final Color baseColor = isSelected ? const Color(0xFF8AAF00) : const Color(0xFF006064);
    final Color shadowColor = isSelected ? const Color(0xFF5A7A00) : const Color(0xFF00383A);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) _userArrangement.remove(word);
          else _userArrangement.add(word);
        });
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          transform: Matrix4.translationValues(0, isSelected ? 0 : -4, 0),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            word.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white, 
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isCheckPressed = true),
        onTapUp: (_) => setState(() => _isCheckPressed = false),
        onTapCancel: () => setState(() => _isCheckPressed = false),
        onTap: _handleCheckButton,
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF006064),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 50,
            transform: Matrix4.translationValues(0, _isCheckPressed ? 0 : -4, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              'CHECK',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCheckButton() {
    final currentQuestion = _activeQuestions[_currentIndex];
    if (currentQuestion['type'] == 'SENTENCE_ARRANGEMENT') {
      final List<dynamic> wordsData = List.from(currentQuestion['sentence_arrangement_words'] ?? []);
      wordsData.sort((a, b) => ApiService.toInt(a['correct_order_index']).compareTo(ApiService.toInt(b['correct_order_index'])));
      String correctAnswer = wordsData.map((e) => e['word_text'].toString()).join(' ');
      String finalResult = _userArrangement.join(' ');
      _handleAnswer(finalResult.trim() == correctAnswer.trim());
    } else if (currentQuestion['type'] == 'MULTIPLE_CHOICE' || currentQuestion['type'] == 'LAB_PRACTICE') {
      if (_selectedOptionIndex != null) {
        final options = currentQuestion['multiple_choice_options'] as List? ?? [];
        final isCorrectOption = options[_selectedOptionIndex!]['is_correct'] ?? false;
        bool correctOption = isCorrectOption is int ? isCorrectOption == 1 : isCorrectOption == true;
        bool finalResult = correctOption;
        if (currentQuestion['type'] == 'LAB_PRACTICE') {
          finalResult = correctOption && _isCorrectMix;
        }
        _handleAnswer(finalResult);
        _selectedOptionIndex = null;
        _isCorrectMix = false;
      }
    }
  }

  // Removed duplicate _wordChip and _buildActionButtons

  Widget _buildProgressHeader() {
    double progress = (_currentIndex + 1) / _activeQuestions.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Soal ${_currentIndex + 1} / ${_activeQuestions.length}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            Text('XP: $_totalXpEarned', style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation(Color(0xFF00FBFF)),
        ),
      ],
    );
  }

  Widget _buildExplanationSection(dynamic question) {
    bool isCorrect = _isLastResultCorrect;
    Color bgColor = isCorrect ? const Color(0xFF8AAF00) : const Color(0xFFC62828);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 200),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CORRECT / WRONG ANSWER header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCorrect ? 'CORRECT ANSWER' : 'WRONG ANSWER',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // EXPLANATION button (cyan)
              _build3DButton(
                text: 'EXPLANATION',
                baseColor: const Color(0xFF00BCD4),
                shadowColor: const Color(0xFF006064),
                onTap: () => _showExplanationDetail(question),
              ),
              const SizedBox(height: 10),
              // CONTINUE button (lime)
              _build3DButton(
                text: 'CONTINUE',
                baseColor: const Color(0xFFCCFF00),
                shadowColor: const Color(0xFF8AAF00),
                textColor: Colors.black,
                onTap: _nextQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DButton({
    required String text,
    required Color baseColor,
    required Color shadowColor,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          height: 50,
          transform: Matrix4.translationValues(0, -4, 0),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
  void _showExplanationDetail(dynamic question) {
    bool isCorrect = _isLastResultCorrect;
    Color cardColor = isCorrect ? const Color(0xFF8AAF00) : const Color(0xFFC62828);
    final String explanation = question['explanation'] ?? 'Penjelasan belum tersedia untuk soal ini.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A1618),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00BCD4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isCorrect ? 'CORRECT ANSWER' : 'WRONG ANSWER',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SizedBox(height: 28),
                          // Explanation label
                          Text(
                            'PENJELASAN',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Full explanation text
                          Text(
                            explanation,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF006064),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          height: 50,
                          transform: Matrix4.translationValues(0, -4, 0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'TUTUP',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
