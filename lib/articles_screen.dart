import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';
import 'admin/add_article_screen.dart';
import 'article_view_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ApiService _apiService = ApiService();
  String _selectedCategory = 'ALL RESEARCH';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _articles = [];
  bool _isLoading = true;

  final List<String> _categories = ['ALL RESEARCH', 'ACID REACTIONS', 'ELEMENTS'];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getArticles(
      category: _selectedCategory,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
    setState(() {
      _articles = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const darkBg = Color(0xFF111718); // Updated to match image somewhat, or use existing 0xFF050F10
    final isAdmin = _apiService.currentUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF101416),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primaryCyan),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildAdminAddButton(primaryCyan),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: _buildSearchBar(primaryCyan),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryTabs(primaryCyan),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: primaryCyan))
                    else if (_articles.isEmpty)
                      const Center(child: Text('No articles found', style: TextStyle(color: Colors.white38)))
                    else
                      ..._articles.map((article) => _buildArticleCard(article, primaryCyan)).toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161F21),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00FBFF)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'LIBRARY',
            style: TextStyle(
              color: Color(0xFF00FBFF),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(_apiService.currentUser?.avatarUrl ?? 'https://i.pravatar.cc/150?u=user'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAddButton(Color primaryCyan) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddArticleScreen()),
        );
        if (result == true) _fetchArticles();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchBar(Color primaryCyan) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF005658)), // Deep cyan border
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _fetchArticles(),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Scan for research topics...',
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(Color primaryCyan) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          bool isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              _fetchArticles();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryCyan : const Color(0xFF151D1F),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? primaryCyan : Colors.white10),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArticleCard(dynamic article, Color primaryCyan) {
    final isAdmin = _apiService.currentUser?.isAdmin ?? false;
    final isBookmarked = article['is_bookmarked'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(article['thumbnail_url'] ?? 'https://picsum.photos/id/101/600/800'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Icon(Icons.search, color: primaryCyan.withOpacity(0.5), size: 24),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Row(
                  children: [
                    if (isAdmin)
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddArticleScreen(initialData: article)),
                          );
                          if (result == true) _fetchArticles();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    GestureDetector(
                      onTap: () async {
                        final success = await _apiService.toggleBookmark(article['id']);
                        if (success) _fetchArticles();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: primaryCyan,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            article['title'] ?? '5 Types of Chemical Reactions',
            style: const TextStyle(
              color: Color(0xFFCFFFFF),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
              shadows: [Shadow(color: Color(0xFF00FBFF), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 16),
          // Description
          if (article['description'] != null && article['description'].toString().isNotEmpty) ...[
            Text(
              article['description'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Read Button Image
          _ImageButton(
            image1: 'assets/read_article1.png',
            image2: 'assets/read_article2.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticleViewScreen(articleId: article['id'])),
              );
            },
          ),
          const SizedBox(height: 16),
          // Separator line
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}

class _ImageButton extends StatefulWidget {
  final String image1;
  final String image2;
  final VoidCallback onTap;

  const _ImageButton({
    required this.image1,
    required this.image2,
    required this.onTap,
  });

  @override
  State<_ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<_ImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        height: 60, // Fixed height to prevent layout shift
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          _isPressed ? widget.image2 : widget.image1,
          width: double.infinity,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
