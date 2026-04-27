import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/background_wrapper.dart';
import 'virtual_lab_screen.dart';

class QuizSessionScreen extends StatefulWidget {
  final List<dynamic> questions;
  final int levelId;
  final String levelName;

  const QuizSessionScreen({super.key, required this.questions, required this.levelId, required this.levelName});

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

  @override
  void initState() {
    super.initState();
    _activeQuestions = List.from(widget.questions);
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      _isLastResultCorrect = isCorrect;
      _showExplanation = true;
      final currentQ = _activeQuestions[_currentIndex];
      
      if (isCorrect) {
        // Only award XP if they never failed this question and haven't already received XP for it
        if (!_failedQuestions.contains(currentQ['id']) && !_correctQuestions.contains(currentQ['id'])) {
          _totalXpEarned += (int.tryParse(currentQ['xp_reward']?.toString() ?? '') ?? 10);
          _correctQuestions.add(currentQ['id']);
        }
      } else {
        _failedQuestions.add(currentQ['id']);
        // Add to retry queue if not already there
        if (!_retryQueue.any((q) => q['id'] == currentQ['id'])) {
          _retryQueue.add(currentQ);
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _showExplanation = false;
      if (_currentIndex < _activeQuestions.length - 1) {
        _currentIndex++;
      } else if (_retryQueue.isNotEmpty) {
        // Start retrying failed questions
        _activeQuestions = List.from(_retryQueue);
        _retryQueue = [];
        _currentIndex = 0;
      } else {
        // Quiz Finished!
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() async {
    if (_correctQuestions.isNotEmpty) {
      await ApiService().addUserXp(_correctQuestions.toList());
    }
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1C1E),
        title: const Text('KUIS SELESAI!', style: TextStyle(color: Color(0xFF00FBFF), fontWeight: FontWeight.bold)),
        content: Text('Selamat! Anda mendapatkan $_totalXpEarned XP.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to quiz map
            },
            child: const Text('KEMBALI KE MAP', style: TextStyle(color: Color(0xFF00FBFF))),
          ),
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
              child: Stack(
                children: [
                  _buildQuestionContent(currentQuestion),
                  if (_showExplanation) _buildExplanationOverlay(currentQuestion),
                ],
              ),
            ),
            _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.science_outlined, color: Color(0xFF00FBFF), size: 28),
                  SizedBox(width: 12),
                  Text('QUIZ', style: TextStyle(color: Color(0xFF00FBFF), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alchemist'), // Mock profile
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL ${widget.questions.isNotEmpty ? (widget.questions[0]['order_index'] ?? 1) : 1}: ${widget.levelName.toUpperCase()}',
                style: TextStyle(color: const Color(0xFF00FBFF).withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_currentIndex + 1} / ${_activeQuestions.length}',
                style: const TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _activeQuestions.length,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00FBFF)),
              minHeight: 6,
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
      return VirtualLabScreen(
        questionData: Map<String, dynamic>.from(question),
        onOptionSelected: (index) => setState(() => _selectedOptionIndex = index),
        onMixChanged: (correct) => setState(() => _isCorrectMix = correct),
      );
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SizedBox(height: 20),
          Text(
            question['question_text'] ?? 'Partikel atom manakah yang bermuatan positif?',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.3),
          ),
          const SizedBox(height: 40),
          ...List.generate(options.length, (index) {
            final opt = options[index];
            bool isSelected = _selectedOptionIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => setState(() => _selectedOptionIndex = index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151D1F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? const Color(0xFFCCFF00) : Colors.transparent, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt['option_label'] ?? 'A',
                          style: const TextStyle(color: Color(0xFF00FBFF), fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt['option_text'] ?? 'Elektron',
                              style: TextStyle(color: isSelected ? const Color(0xFFCCFF00) : Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            if (isSelected) const Text('SELECTED REACTION', style: TextStyle(color: Color(0xFFCCFF00), fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFCCFF00)),
                    ],
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
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.4),
                children: [
                  const TextSpan(text: 'Susun '),
                  TextSpan(text: (question['question_text'] ?? 'definisi proton ').toString(), style: const TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.w900)),
                  const TextSpan(text: 'dengan benar'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Result Box (Dashed)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 140),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10, style: BorderStyle.solid),
              ),
              child: _userArrangement.isEmpty 
                ? const Center(child: Icon(Icons.copy_all, color: Colors.white10, size: 64))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _userArrangement.map((w) => _wordChip(w, true)).toList(),
                  ),
            ),
            const SizedBox(height: 40),
            const Text('AVAILABLE ELEMENTS:', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: allWords.where((w) => !_userArrangement.contains(w)).map((w) => _wordChip(w, false)).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _wordChip(String word, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) _userArrangement.remove(word);
          else _userArrangement.add(word);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF151D1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          word,
          style: TextStyle(color: word == 'Proton' ? const Color(0xFF00FBFF) : Colors.white70, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: () => setState(() => _userArrangement.clear()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3436),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isCheckPressed = true),
              onTapUp: (_) => setState(() => _isCheckPressed = false),
              onTapCancel: () => setState(() => _isCheckPressed = false),
              onTap: () {
                final currentQuestion = _activeQuestions[_currentIndex];
                if (_showExplanation) {
                  _nextQuestion();
                  return;
                }
                if (currentQuestion['type'] == 'SENTENCE_ARRANGEMENT') {
                  final List<dynamic> wordsData = List.from(currentQuestion['sentence_arrangement_words'] ?? []);
                  // Sort wordsData by correct_order_index to get the correct sequence
                  wordsData.sort((a, b) => (a['correct_order_index'] ?? 0).compareTo(b['correct_order_index'] ?? 0));
                  String correctAnswer = wordsData.map((e) => e['word_text'].toString()).join(' ');
                  
                  String finalResult = _userArrangement.join(' ');
                  _handleAnswer(finalResult.trim() == correctAnswer.trim());
                  _userArrangement = []; 
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
                    _isCorrectMix = false; // Reset
                  }
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    _isCheckPressed ? 'assets/check_dark.png' : 'assets/check_bright.png',
                    height: 64,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 64,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FBFF).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: _isCheckPressed 
                            ? [const Color(0xFF006666), const Color(0xFF004444)]
                            : [const Color(0xFF00FBFF), const Color(0xFF008080)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _showExplanation ? 'NEXT' : 'CHECK', 
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildExplanationOverlay(dynamic question) {
    return Container(
      color: Colors.black87,
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isLastResultCorrect ? Icons.check_circle : Icons.error_outline,
            color: _isLastResultCorrect ? const Color(0xFFCCFF00) : Colors.redAccent,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            _isLastResultCorrect ? 'JAWABAN BENAR!' : 'JAWABAN KURANG TEPAT',
            style: TextStyle(
              color: _isLastResultCorrect ? const Color(0xFFCCFF00) : Colors.redAccent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const Text('PEMBAHASAN:', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            question['explanation'] ?? 'Penjelasan belum tersedia.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FBFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('LANJUTKAN', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
