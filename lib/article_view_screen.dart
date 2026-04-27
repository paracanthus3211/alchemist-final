import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';
import 'dart:convert';

class ArticleViewScreen extends StatefulWidget {
  final int articleId;
  const ArticleViewScreen({super.key, required this.articleId});

  @override
  State<ArticleViewScreen> createState() => _ArticleViewScreenState();
}

class _ArticleViewScreenState extends State<ArticleViewScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _article;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final data = await _apiService.getArticleDetails(widget.articleId);
    setState(() {
      _article = data;
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
        showGrid: false,
        removeSafeAreaPadding: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryCyan))
            : _article == null
                ? const Center(child: Text('Article not found', style: TextStyle(color: Colors.white)))
                : Column(
                    children: [
                      _buildHeader(primaryCyan),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroSection(),
                              const SizedBox(height: 32),
                              ...(_article!['contents'] as List).map((block) => _buildBlock(block, primaryCyan)).toList(),
                              const SizedBox(height: 60),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _article!['is_bookmarked'] == true ? Icons.bookmark : Icons.bookmark_border,
              color: primaryCyan,
            ),
            onPressed: () async {
              final success = await _apiService.toggleBookmark(_article!['id']);
              if (success) _fetchDetails();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00FBFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _article!['category'] ?? 'RESEARCH',
            style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _article!['title'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            _article!['thumbnail_url'] ?? 'https://picsum.photos/id/101/600/400',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildBlock(dynamic block, Color primaryCyan) {
    final type = block['type'];
    final content = block['content'];

    switch (type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            content,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, height: 1.6),
          ),
        );
      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(content, width: double.infinity, fit: BoxFit.cover),
          ),
        );
      case 'table':
        try {
          final tableData = jsonDecode(content);
          final headers = (tableData['headers'] as List).map((h) => DataColumn(label: Text(h, style: const TextStyle(color: Color(0xFF00FBFF), fontWeight: FontWeight.bold)))).toList();
          final rows = (tableData['rows'] as List).map((r) {
            return DataRow(cells: (r as List).map((c) => DataCell(Text(c.toString(), style: const TextStyle(color: Colors.white70)))).toList());
          }).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: DataTable(columns: headers, rows: rows),
              ),
            ),
          );
        } catch (e) {
          return const SizedBox();
        }
      default:
        return const SizedBox();
    }
  }
}
