import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../widgets/background_wrapper.dart';
import '../services/api_service.dart';

class EditChapterScreen extends StatefulWidget {
  final int nextOrder;
  final Map<String, dynamic>? initialData;
  final int? parentChapterId; // If provided, we are adding a LEVEL to this chapter

  const EditChapterScreen({super.key, required this.nextOrder, this.initialData, this.parentChapterId});

  @override
  State<EditChapterScreen> createState() => _EditChapterScreenState();
}

class _EditChapterScreenState extends State<EditChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _xpThresholdController = TextEditingController();
  
  // Level fields
  final _levelNameController = TextEditingController();
  final _levelDescController = TextEditingController();
  final _levelXpController = TextEditingController();
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _isUploadingImage = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _xpThresholdController.text = (widget.initialData!['xp_threshold'] ?? 0).toString();
      
      // If it's a level being edited (logic for later)
      _levelNameController.text = widget.initialData!['name'] ?? '';
      _levelDescController.text = widget.initialData!['description'] ?? '';
      _levelXpController.text = (widget.initialData!['xp_required'] ?? 0).toString();
      _imageUrl = widget.initialData!['icon_url'];
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    bool success;
    
    if (widget.parentChapterId != null) {
      // ADDING A LEVEL
      final levelData = {
        'chapter_id': widget.parentChapterId,
        'name': _levelNameController.text,
        'description': _levelDescController.text,
        'xp_required': int.tryParse(_levelXpController.text) ?? 0,
        'order_index': widget.initialData?['order_index'] ?? widget.nextOrder,
        'icon_url': _imageUrl ?? 'https://example.com/icon.png',
      };
      
      if (widget.initialData != null && widget.initialData!['id'] != null) {
        success = await ApiService().updateLevel(widget.initialData!['id'], levelData);
      } else {
        success = await ApiService().createLevel(levelData);
      }
    } else {
      // ADDING/EDITING A CHAPTER
      final chapterData = {
        'title': _titleController.text,
        'xp_threshold': int.tryParse(_xpThresholdController.text) ?? 0,
        'order_index': widget.initialData?['order_index'] ?? widget.nextOrder,
        'icon_emoji': '🧪',
      };

      if (widget.initialData != null) {
        success = await ApiService().updateChapter(widget.initialData!['id'], chapterData);
      } else {
        success = await ApiService().createChapter(chapterData);
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save data')));
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
        showGrid: true,
        removeSafeAreaPadding: true,
        child: Column(
          children: [
            _buildHeader(context, primaryCyan),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.parentChapterId == null) ...[
                        _sectionTitle('SECTION CHAPTER'),
                        const SizedBox(height: 24),
                        _buildTextField('TITLE CHAPTER', _titleController, 'Input Title Chapter'),
                        const SizedBox(height: 20),
                        _buildTextField('XP THRESHOLD / XP REQUIREMENT', _xpThresholdController, 'Input XP Requirement', isNumber: true),
                      ],
                      
                      if (widget.parentChapterId != null) ...[
                        _sectionTitle('SECTION LEVEL'),
                        const SizedBox(height: 24),
                        _buildTextField('NAMA LEVEL', _levelNameController, 'Input Nama Level'),
                        const SizedBox(height: 20),
                        _buildTextField('DESKRIPSI LEVEL', _levelDescController, 'Input Deskripsi Level', maxLines: 3),
                        const SizedBox(height: 20),
                        _buildUploadButton('UPLOAD IMAGE LEVEL'),
                        const SizedBox(height: 20),
                        _buildTextField('XP REQUIRED / XP THRESHOLD', _levelXpController, 'Input XP Requirement', isNumber: true),
                      ],
                      
                      const SizedBox(height: 60),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryCyan) {
    String title = widget.initialData == null ? 'ADD CHAPTER' : 'EDIT CHAPTER';
    if (widget.parentChapterId != null) {
      title = widget.initialData == null ? 'ADD LEVEL' : 'EDIT LEVEL';
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF0A1618),
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00FBFF), width: 1),
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Cannot be empty' : null,
        ),
      ],
    );
  }

  Widget _buildUploadButton(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1618),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (_imageUrl != null || _imageBytes != null) ? const Color(0xFF00FBFF) : Colors.white.withOpacity(0.05)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    if (_isUploadingImage)
                      const CircularProgressIndicator(color: Color(0xFF00FBFF))
                    else if (_imageBytes != null || _imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _imageBytes != null 
                          ? Image.memory(_imageBytes!, height: 60)
                          : Image.network(_imageUrl!, height: 60, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.red)),
                      ),
                      const SizedBox(height: 8),
                      Text('CHANGE IMAGE', style: TextStyle(color: const Color(0xFF00FBFF), fontSize: 12, fontWeight: FontWeight.bold)),
                    ] else ...[
                      const Icon(Icons.cloud_upload_outlined, color: Color(0xFF00FBFF), size: 32),
                      const SizedBox(height: 8),
                      Text('PILIH DARI GALERI', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                if ((_imageUrl != null || _imageBytes != null) && !_isUploadingImage)
                  Positioned(
                    top: -10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      onPressed: () => setState(() {
                        _imageUrl = null;
                        _imageBytes = null;
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _isUploadingImage = true;
    });

    final url = await ApiService().uploadImage(bytes, image.name);
    if (mounted) {
      setState(() {
        _isUploadingImage = false;
        if (url != null) _imageUrl = url;
      });
    }
  }

  Future<String?> _showUrlDialog() async {
    final controller = TextEditingController(text: _imageUrl);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1618),
        title: const Text('Image URL', style: TextStyle(color: Color(0xFF00FBFF))),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter image URL',
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FBFF))),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FBFF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.black)
          : Text(
              widget.parentChapterId != null ? 'SAVE LEVEL' : 'SAVE CHAPTER', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)
            ),
      ),
    );
  }
}
