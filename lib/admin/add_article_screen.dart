import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/background_wrapper.dart';

class AddArticleScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddArticleScreen({super.key, this.initialData});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final ApiService _apiService = ApiService();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedLevel = 'Dasar';

  // Thumbnail state
  String? _thumbnailUrl;
  Uint8List? _thumbnailBytes;
  bool _isUploadingThumbnail = false;

  List<Map<String, dynamic>> _contents = [];
  bool _isSaving = false;
  int _nextBlockId = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _categoryController.text = widget.initialData!['category'] ?? '';
      _selectedLevel = widget.initialData!['difficulty_level'] ?? 'Dasar';
      _thumbnailUrl = widget.initialData!['thumbnail_url'];
      final rawContents = List<Map<String, dynamic>>.from(widget.initialData!['contents'] ?? []);
      _contents = rawContents.map((block) {
        return {
          ...block,
          '_id': _nextBlockId++,
          '_controller': TextEditingController(
            text: block['type'] == 'table'
                ? (block['content'] is String ? block['content'] : jsonEncode(block['content']))
                : (block['content'] ?? ''),
          ),
        };
      }).toList();
    }

    // Listen to text changes for live preview
    _titleController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _categoryController.dispose();
    for (final block in _contents) {
      (block['_controller'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _thumbnailBytes = bytes;
      _isUploadingThumbnail = true;
    });
    final url = await _apiService.uploadImage(bytes, image.name);
    if (mounted) {
      setState(() {
        _isUploadingThumbnail = false;
        if (url != null) _thumbnailUrl = url;
      });
    }
  }

  Future<void> _pickBlockImage(Map<String, dynamic> block) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      block['_imageBytes'] = bytes;
      block['_uploading'] = true;
    });
    final url = await _apiService.uploadImage(bytes, image.name);
    if (mounted) {
      setState(() {
        block['_uploading'] = false;
        if (url != null) {
          block['content'] = url;
        }
      });
    }
  }

  void _addBlock(String type) {
    setState(() {
      final controller = TextEditingController();
      String defaultContent = '';
      if (type == 'table') {
        defaultContent = '{"headers": ["Header 1", "Header 2"], "rows": [["Data 1", "Data 2"]]}';
        controller.text = defaultContent;
      }
      _contents.add({
        'type': type,
        'content': type == 'table'
            ? {'headers': ['Header 1', 'Header 2'], 'rows': [['Data 1', 'Data 2']]}
            : '',
        '_id': _nextBlockId++,
        '_controller': controller,
      });
    });
  }

  Map<String, dynamic> _cleanBlockForSave(Map<String, dynamic> block) {
    return {
      'type': block['type'],
      'content': block['content'],
    };
  }

  Future<void> _saveArticle() async {
    setState(() => _isSaving = true);
    final data = {
      'title': _titleController.text,
      'category': _categoryController.text,
      'difficulty_level': _selectedLevel,
      'thumbnail_url': _thumbnailUrl,
      'contents': _contents.map(_cleanBlockForSave).toList(),
    };

    Map<String, dynamic> result;
    if (widget.initialData != null) {
      result = await _apiService.updateArticle(widget.initialData!['id'], data);
    } else {
      result = await _apiService.createArticle(data);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (result['success'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${result['error']}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
        child: Column(
          children: [
            _buildHeader(primaryCyan),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Title'),
                    _buildTextField(_titleController, 'Enter Title'),
                    const SizedBox(height: 20),
                    _buildLabel('Category'),
                    _buildTextField(_categoryController, 'Enter Category (e.g. Acid Reactions)'),
                    const SizedBox(height: 20),
                    _buildLabel('Thumbnail'),
                    _buildImagePicker(
                      primaryCyan,
                      _thumbnailBytes,
                      _thumbnailUrl,
                      _isUploadingThumbnail,
                      _pickThumbnail,
                      () => setState(() {
                        _thumbnailBytes = null;
                        _thumbnailUrl = null;
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Level'),
                    _buildLevelDropdown(primaryCyan),
                    const SizedBox(height: 32),
                    _buildContentBuilder(primaryCyan),
                    const SizedBox(height: 32),
                    _buildLabel('Preview Article'),
                    _buildLivePreview(primaryCyan),
                    const SizedBox(height: 40),
                    _buildSaveButton(primaryCyan),
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

  Widget _buildHeader(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.initialData != null ? 'Edit Article' : 'Add Article',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Color(0xFF00FBFF), size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImagePicker(
    Color primaryCyan,
    Uint8List? imageBytes,
    String? imageUrl,
    bool isUploading,
    VoidCallback onPick,
    VoidCallback onDelete,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          if (isUploading)
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00FBFF))),
            )
          else if (imageUrl != null || imageBytes != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageBytes != null
                      ? Image.memory(imageBytes, height: 150, width: double.infinity, fit: BoxFit.cover)
                      : Image.network(imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            )
          else
            const Icon(Icons.image_outlined, color: Colors.white10, size: 48),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isUploading ? null : onPick,
            icon: const Icon(Icons.photo_library),
            label: const Text('Pilih dari Galeri (mobile)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryCyan.withOpacity(0.1),
              foregroundColor: primaryCyan,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLevelDropdown(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLevel,
          dropdownColor: const Color(0xFF151D1F),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down, color: primaryCyan),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedLevel = newValue!;
            });
          },
          items: <String>['Dasar', 'Menengah', 'Sulit'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContentBuilder(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _contents.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _contents.removeAt(oldIndex);
                _contents.insert(newIndex, item);
              });
            },
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return Material(
                color: Colors.transparent,
                elevation: 8,
                shadowColor: const Color(0xFF00FBFF).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final block = _contents[index];
              return _buildBlockItem(index, block, primaryCyan);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAddIconBtn('Text', Icons.text_fields, () => _addBlock('text')),
              _buildAddIconBtn('Gambar', Icons.image, () => _addBlock('image')),
              _buildAddIconBtn('Table', Icons.table_chart, () => _addBlock('table')),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Drag and drop the content to manage the structure position',
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockItem(int index, Map<String, dynamic> block, Color primaryCyan) {
    IconData icon = Icons.text_fields;
    String title = "Teks";
    if (block['type'] == 'image') {
      icon = Icons.image;
      title = "Image";
    } else if (block['type'] == 'table') {
      icon = Icons.table_chart;
      title = "Table";
    }

    final controller = block['_controller'] as TextEditingController;

    return Container(
      key: ValueKey(block['_id']),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Header row with drag handle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primaryCyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    (block['_controller'] as TextEditingController?)?.dispose();
                    setState(() => _contents.removeAt(index));
                  },
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.drag_indicator, color: primaryCyan.withOpacity(0.5), size: 24),
                  ),
                ),
              ],
            ),
          ),
          // Content input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _buildBlockInput(block, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockInput(Map<String, dynamic> block, TextEditingController controller) {
    if (block['type'] == 'text') {
      return TextField(
        controller: controller,
        onChanged: (v) {
          block['content'] = v;
          setState(() {});
        },
        style: const TextStyle(color: Colors.white70, fontSize: 13),
        maxLines: 5,
        minLines: 1,
        decoration: const InputDecoration(
          hintText: 'Enter content text',
          hintStyle: TextStyle(color: Colors.white10),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      );
    } else if (block['type'] == 'image') {
      return _buildImagePicker(
        const Color(0xFF00FBFF),
        block['_imageBytes'] as Uint8List?,
        block['content'] as String?,
        block['_uploading'] == true,
        () => _pickBlockImage(block),
        () => setState(() {
          block['_imageBytes'] = null;
          block['content'] = '';
        }),
      );
    } else {
      // Table
      return TextField(
        controller: controller,
        onChanged: (v) {
          try {
            block['content'] = jsonDecode(v);
          } catch (e) {
            block['content'] = v;
          }
          setState(() {});
        },
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: '{"headers": ["H1", "H2"], "rows": [["D1", "D2"]]}',
          hintStyle: TextStyle(color: Colors.white10),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      );
    }
  }

  Widget _buildAddIconBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, style: BorderStyle.solid),
            ),
            child: Icon(icon, color: const Color(0xFF00FBFF), size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  // ── LIVE PREVIEW ──────────────────────────────────────────────────

  Widget _buildLivePreview(Color primaryCyan) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1517),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: primaryCyan.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail preview
              if (_thumbnailUrl != null || _thumbnailBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _thumbnailBytes != null
                      ? Image.memory(
                          _thumbnailBytes!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _thumbnailUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red.shade900, Colors.orange.shade900],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white24, size: 40),
                            ),
                          ),
                        ),
                ),
              if (_thumbnailUrl != null || _thumbnailBytes != null) const SizedBox(height: 20),

              // Title preview
              if (_titleController.text.isNotEmpty)
                Text(
                  _titleController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              if (_titleController.text.isNotEmpty) const SizedBox(height: 20),

              // Content blocks preview
              if (_contents.isEmpty)
                SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, color: Colors.white.withOpacity(0.06), size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Add content blocks to see preview',
                          style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._contents.map((block) => _buildPreviewBlock(block, primaryCyan)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewBlock(Map<String, dynamic> block, Color primaryCyan) {
    final type = block['type'];
    final content = block['content'];
    final contentStr = content is String ? content : '';

    switch (type) {
      case 'text':
        if (contentStr.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            contentStr,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, height: 1.6),
          ),
        );

      case 'image':
        final imageBytes = block['_imageBytes'] as Uint8List?;
        if (contentStr.isEmpty && imageBytes == null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image, color: Colors.white10, size: 32),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageBytes != null
                ? Image.memory(imageBytes, width: double.infinity, fit: BoxFit.cover)
                : Image.network(
                    contentStr,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white12, size: 32),
                      ),
                    ),
                  ),
          ),
        );

      case 'table':
        try {
          final tableData = content is Map ? content : jsonDecode(content.toString());
          final headers = (tableData['headers'] as List)
              .map((h) => DataColumn(
                    label: Text(h.toString(),
                        style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                  ))
              .toList();
          final rows = (tableData['rows'] as List).map((r) {
            return DataRow(
              cells: (r as List)
                  .map((c) => DataCell(Text(c.toString(), style: const TextStyle(color: Colors.white70, fontSize: 12))))
                  .toList(),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: DataTable(
                  columns: headers,
                  rows: rows,
                  headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.03)),
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 48,
                  columnSpacing: 24,
                ),
              ),
            ),
          );
        } catch (e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Invalid table JSON',
                style: TextStyle(color: Colors.redAccent.withOpacity(0.6), fontSize: 12),
              ),
            ),
          );
        }

      default:
        return const SizedBox();
    }
  }

  Widget _buildSaveButton(Color primaryCyan) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveArticle,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                'SAVE ARTICLE',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
      ),
    );
  }
}
