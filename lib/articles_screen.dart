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
    const darkBg = Color(0xFF050F10);
    final isAdmin = _apiService.currentUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: darkBg,
      body: BackgroundWrapper(
        showGrid: true,
        removeSafeAreaPadding: true,
        child: Column(
          children: [
            _buildHeader(primaryCyan),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAdmin) ...[
                          _buildAdminAddButton(primaryCyan),
                          const SizedBox(height: 20),
                        ],
                        _buildSearchBar(primaryCyan),
                        const SizedBox(height: 24),
                        _buildCategoryTabs(primaryCyan),
                        const SizedBox(height: 32),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: Colors.white),
          const Text(
            'NEON_LIBRARY',
            style: TextStyle(
              color: Color(0xFF00FBFF),
              fontSize: 20,
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
              radius: 16,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildSearchBar(Color primaryCyan) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1618),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryCyan.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: primaryCyan.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchArticles(),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Scan for research topics...',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(article['thumbnail_url'] ?? 'https://picsum.photos/id/101/600/800'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdmin)
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddArticleScreen(initialData: article),
                          ),
                        );
                        if (result == true) _fetchArticles();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
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
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        article['is_bookmarked'] == true ? Icons.bookmark : Icons.bookmark_border,
                        color: primaryCyan,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              article['title'] ?? '5 Types of Chemical Reactions',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            _buildReadButton(primaryCyan, article),
          ],
        ),
      ),
    );
  }

  Widget _buildReadButton(Color primaryCyan, dynamic article) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            primaryCyan.withOpacity(0.8),
            const Color(0xFF008080).withOpacity(0.8),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArticleViewScreen(articleId: article['id'])),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'READ ARTICLE',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
}
