import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';
import 'article_view_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getBookmarks();
    setState(() {
      _articles = data;
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
            _buildHeader(primaryCyan),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryCyan))
                  : _articles.isEmpty
                      ? const Center(child: Text('No bookmarked articles', style: TextStyle(color: Colors.white38)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _articles.length,
                          itemBuilder: (context, index) {
                            final article = _articles[index];
                            return _buildArticleCard(article, primaryCyan);
                          },
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'BOOKMARKS',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(dynamic article, Color primaryCyan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              article['thumbnail_url'] ?? 'https://picsum.photos/id/101/200/200',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['category'] ?? 'RESEARCH',
                  style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  article['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticleViewScreen(articleId: article['id'])),
              ).then((_) => _fetchBookmarks());
            },
          ),
        ],
      ),
    );
  }
}
