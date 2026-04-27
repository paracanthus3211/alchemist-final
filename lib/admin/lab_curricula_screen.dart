import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';
import '../services/api_service.dart';
import 'edit_question_screen.dart';
import 'edit_chapter_screen.dart';

class LabCurriculaScreen extends StatefulWidget {
  const LabCurriculaScreen({super.key});

  @override
  State<LabCurriculaScreen> createState() => _LabCurriculaScreenState();
}

class _LabCurriculaScreenState extends State<LabCurriculaScreen> {
  String _activeTab = 'Chapter'; // 'Chapter' or 'Quiz Content'
  List<dynamic> _chapters = [];
  bool _isLoading = true;
  dynamic _selectedQuiz;

  List<dynamic> get _allQuizzes {
    List<dynamic> quizzes = [];
    for (var chapter in _chapters) {
      if (chapter['levels'] != null) {
        for (var level in chapter['levels']) {
          // Flattening for quiz selection if needed
          var l = Map<String, dynamic>.from(level);
          l['chapter_title'] = chapter['title'];
          quizzes.add(l);
        }
      }
    }
    return quizzes;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await ApiService().getCurriculum();
    setState(() {
      _chapters = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const darkBg = Color(0xFF050F10);

    return Scaffold(
      backgroundColor: darkBg,
      body: BackgroundWrapper(
        showGrid: true,
        removeSafeAreaPadding: true,
        child: Column(
          children: [
            _buildHeader(context, primaryCyan),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: primaryCyan))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      children: [
                        _buildStatsRow(),
                        const SizedBox(height: 32),
                        _buildTabs(),
                        const SizedBox(height: 32),
                        _activeTab == 'Chapter' ? _buildChapterTab() : _buildQuizContentTab(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'CHAPTER & QUIZ(CRUD)',
            style: TextStyle(
              color: Color(0xFF00FBFF),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    int chapterCount = _chapters.length;
    int levelCount = 0;
    for (var c in _chapters) {
      if (c['levels'] != null) levelCount += (c['levels'] as List).length;
    }

    return Row(
      children: [
        _statBox(chapterCount.toString(), 'CHAPTERS'),
        const SizedBox(width: 12),
        _statBox(levelCount.toString(), 'LEVELS'),
        const SizedBox(width: 12),
        _statBox(levelCount.toString(), 'QUIZZES'), // Each level has a set of questions
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1618),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF00FBFF),
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem('Chapter'),
        const SizedBox(width: 32),
        _tabItem('Quiz Content'),
      ],
    );
  }

  Widget _tabItem(String label) {
    bool isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00FBFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive ? [
                BoxShadow(color: const Color(0xFF00FBFF).withOpacity(0.5), blurRadius: 10),
              ] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterTab() {
    return Column(
      children: [
        ..._chapters.map((chapter) => _chapterAccordion(chapter)).toList(),
        const SizedBox(height: 16),
        _addNewButton('Add New Chapter', onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditChapterScreen(nextOrder: _chapters.length + 1),
            ),
          );
          if (result == true) _fetchData();
        }),
      ],
    );
  }

  Widget _chapterAccordion(dynamic chapter) {
    final levels = (chapter['levels'] as List?) ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FBFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.science_outlined, color: Color(0xFF00FBFF), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    chapter['title'] ?? 'Untitled Chapter',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00FBFF), size: 24),
                  onPressed: () async {
                    // Add Level to this Chapter
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChapterScreen(
                          nextOrder: levels.length + 1,
                          parentChapterId: chapter['id'], // Signal adding a level
                        ),
                      ),
                    );
                    if (result == true) _fetchData();
                  },
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                ...levels.map((lvl) => _levelTile(
                  'LEVEL ${lvl['order_index'] ?? 1}', 
                  lvl['name'] ?? 'Untitled Level',
                  lvl,
                  chapter['id'],
                )).toList(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditChapterScreen(
                              nextOrder: chapter['order_index'] ?? 1,
                              initialData: chapter,
                            ),
                          ),
                        );
                        if (result == true) _fetchData();
                      },
                      child: const Text('EDIT CHAPTER', style: TextStyle(color: Color(0xFF00FBFF), fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () async {
                        bool? confirm = await _showDeleteConfirm('Chapter');
                        if (confirm == true) {
                          await ApiService().deleteChapter(chapter['id']);
                          _fetchData();
                        }
                      },
                      child: const Text('DELETE CHAPTER', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelTile(String label, String title, dynamic lvl, int chapterId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF132628),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Color(0xFF00FBFF), width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 10, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF00FBFF), size: 20),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditChapterScreen(
                    nextOrder: lvl['order_index'] ?? 1,
                    initialData: lvl,
                    parentChapterId: chapterId,
                  ),
                ),
              );
              if (result == true) _fetchData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 20),
            onPressed: () async {
              bool? confirm = await _showDeleteConfirm('Level');
              if (confirm == true) {
                await ApiService().deleteLevel(lvl['id']);
                _fetchData();
              }
            },
          ),
        ],
      ),
    );
  }

  dynamic _selectedLevel;

  Widget _buildQuizContentTab() {
    // Collect all levels for the dropdown
    List<dynamic> allLevels = [];
    for (var chapter in _chapters) {
      if (chapter['levels'] != null) {
        for (var level in chapter['levels']) {
          var l = Map<String, dynamic>.from(level);
          l['chapter_title'] = chapter['title'];
          allLevels.add(l);
        }
      }
    }

    if (allLevels.isEmpty) {
      return const Center(child: Text('Add a chapter and level first', style: TextStyle(color: Colors.white38)));
    }

    _selectedLevel ??= allLevels.first;

    final questions = (_selectedLevel['questions'] as List?) ?? [];

    return Column(
      children: [
        // Level Selector
        GestureDetector(
          onTap: () {
            // Show a simple picker or dialog
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF0D1C1E),
              builder: (context) => ListView.builder(
                itemCount: allLevels.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(allLevels[index]['name'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(allLevels[index]['chapter_title'], style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  onTap: () {
                    setState(() => _selectedLevel = allLevels[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1618),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, color: Color(0xFF00FBFF), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${_selectedLevel['chapter_title']} - ${_selectedLevel['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.unfold_more, color: Colors.white38),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FBFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00FBFF), shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text('TOTAL QUESTIONS: ${questions.length.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ...questions.map((q) => _questionCard(
          q['question_text'] ?? 'Untitled Soal',
          q['type'] ?? 'MULTIPLE_CHOICE',
          q['explanation'] ?? '',
          '${q['xp_reward'] ?? 0} XP REWARD',
          q['type'] == 'MULTIPLE_CHOICE' ? Icons.checklist_rtl : Icons.science_outlined,
          q,
        )).toList(),
        const SizedBox(height: 16),
        _addNewButton('Add new question', onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditQuestionScreen(
                levelId: _selectedLevel['id'],
                nextOrder: questions.length + 1,
              ),
            ),
          );
          if (result == true) _fetchData();
        }),
      ],
    );
  }

  Widget _questionCard(String title, String type, String snippet, String xp, IconData icon, dynamic qData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1618),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF00FBFF), size: 24),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 22),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditQuestionScreen(
                        levelId: _selectedLevel['id'],
                        nextOrder: qData['order_index'] ?? 1,
                        initialData: qData,
                      ),
                    ),
                  );
                  if (result == true) _fetchData();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 22),
                onPressed: () async {
                  bool? confirm = await _showDeleteConfirm('Question');
                  if (confirm == true) {
                    await ApiService().deleteQuestion(qData['id']);
                    _fetchData();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Text(type, style: const TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              snippet,
              style: const TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFCCFF00), size: 18),
                  const SizedBox(width: 6),
                  Text(xp, style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
              const Text('View Details', style: TextStyle(color: Color(0xFF00FBFF), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addNewButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00FBFF).withOpacity(0.2),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_circle_outline, color: Color(0xFF00FBFF), size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF00FBFF),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(String type) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1C1E),
        title: Text('Delete $type?', style: const TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this $type? This action cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}
