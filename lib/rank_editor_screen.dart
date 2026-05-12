import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';

class RankEditorScreen extends StatefulWidget {
  const RankEditorScreen({super.key});

  @override
  State<RankEditorScreen> createState() => _RankEditorScreenState();
}

class _RankEditorScreenState extends State<RankEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _chapterCtrl = TextEditingController();
  final _xpCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  
  Uint8List? _imageBytes;
  String? _fileName;

  List<dynamic> _ranks = [];
  bool _isLoading = true;
  String? _editingRankId;

  static const _cyan = Color(0xFF00FBFF);
  static const _cardBg = Color(0xFF161D1E);
  static const _bg = Color(0xFF0D1213);
  static const _inputBg = Color(0xFF20292B);

  @override
  void initState() {
    super.initState();
    _fetchRanks();
  }

  Future<void> _fetchRanks() async {
    setState(() => _isLoading = true);
    final data = await ApiService().getRanks();
    if (mounted) {
      setState(() {
        _ranks = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _fileName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _handleForge() async {
    if (_nameCtrl.text.isEmpty || _xpCtrl.text.isEmpty) return;
    
    String? iconUrl;
    if (_imageBytes != null && _fileName != null) {
      iconUrl = await ApiService().uploadImage(_imageBytes!, _fileName!);
    }

    final xpVal = int.tryParse(_xpCtrl.text) ?? 0;
    final rankData = {
      'name': _nameCtrl.text,
      'chapter': _chapterCtrl.text,
      'xp_threshold': xpVal,
      'min_xp': xpVal,
      'xp_required': xpVal,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (iconUrl != null) 'image_url': iconUrl,
    };

    String? error;
    if (_editingRankId != null) {
      final success = await ApiService().updateRank(int.parse(_editingRankId!), rankData);
      error = success ? null : "Update failed";
    } else {
      error = await ApiService().createRank(rankData);
    }

    if (mounted) {
      if (error == null) {
        _nameCtrl.clear();
        _chapterCtrl.clear();
        _xpCtrl.clear();
        setState(() {
          _imageBytes = null;
          _fileName = null;
          _editingRankId = null;
        });
        _fetchRanks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingRankId == null ? 'Rank forged successfully!' : 'Rank updated successfully!'), backgroundColor: _cyan)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $error'), backgroundColor: Colors.redAccent)
        );
      }
    }
  }

  Future<void> _handleDelete(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return;
    final success = await ApiService().deleteRank(intId);
    if (success && mounted) {
      if (_editingRankId == id) {
        setState(() {
          _editingRankId = null;
          _nameCtrl.clear();
          _chapterCtrl.clear();
          _xpCtrl.clear();
        });
      }
      _fetchRanks();
    }
  }

  void _handleEdit(dynamic rank) {
    setState(() {
      _editingRankId = rank['id'].toString();
      _nameCtrl.text = rank['name'] ?? '';
      _chapterCtrl.text = rank['chapter']?.toString() ?? '';
      _xpCtrl.text = (rank['xp_threshold'] ?? 0).toString();
    });
    
    // Scroll to top to see the form
    _scrollCtrl.animateTo(
      0, 
      duration: const Duration(milliseconds: 500), 
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Text('Edit Rank', style: TextStyle(color: _cyan, fontSize: 22, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🧪 REGISTRY MANAGEMENT', style: TextStyle(color: _cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    const Text('Rank Editor', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('Configure the hierarchical thresholds for alchemical progression.', 
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                    
                    const SizedBox(height: 32),
                    
                    // Form Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.add_circle_outline, color: _cyan, size: 24),
                              const SizedBox(width: 12),
                              Text(_editingRankId == null ? 'Add New Rank' : 'Edit Rank #${_editingRankId}', 
                                style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.bold)),
                              if (_editingRankId != null) ...[
                                const Spacer(),
                                IconButton(
                                  onPressed: () => setState(() {
                                    _editingRankId = null;
                                    _nameCtrl.clear();
                                    _chapterCtrl.clear();
                                    _xpCtrl.clear();
                                  }),
                                  icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                                )
                              ]
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Upload Box
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.02),
                              ),
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    painter: DashPainter(),
                                    size: Size.infinite,
                                  ),
                                  if (_imageBytes != null)
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(_imageBytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.upload_file_outlined, color: Colors.white38, size: 32),
                                          const SizedBox(height: 8),
                                          const Text('Upload Rank Sigil (PNG/SVG)', style: TextStyle(color: Colors.white24, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _fieldLabel('RANK NAME'),
                          _buildInput(_nameCtrl, 'e.g., Lead Transmuter'),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _fieldLabel('CHAPTER LOG'),
                                    _buildInput(_chapterCtrl, 'Chapter 5'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _fieldLabel('XP THRESHOLD'),
                                    _buildInput(_xpCtrl, '2500', isNumber: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Forge Button
                          GestureDetector(
                            onTap: _handleForge,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [_cyan, Color(0xFF00B4D8)]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: _cyan.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_editingRankId == null ? Icons.auto_fix_high : Icons.save_outlined, color: Colors.black, size: 20),
                                  const SizedBox(width: 12),
                                  Text(_editingRankId == null ? 'Forge New Rank' : 'Update Rank Registry', 
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Active Hierarchies Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ACTIVE HIERARCHIES', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('${_ranks.length} TOTAL', style: const TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Hierarchies List
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: _cyan))
                      : Column(
                          children: _ranks.map((rank) => _hierarchyCard(rank)).toList(),
                        ),
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

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _hierarchyCard(dynamic rank) {
    final color = _getRankColor(rank['name']);
    return GestureDetector(
      onTap: () => _handleEdit(rank),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border(bottom: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              child: (rank['icon_url'] != null && rank['icon_url'].startsWith('http'))
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(rank['icon_url']),
                  )
                : Icon(_getRankIcon(rank['name']), color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(rank['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text('ID: ALC-${rank['id'].toString().padLeft(2, '0')}', style: TextStyle(color: _cyan.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: Colors.white24, size: 12),
                      const SizedBox(width: 4),
                      Text('Ch. ${rank['chapter'] ?? '1'}', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                      const SizedBox(width: 12),
                      const Icon(Icons.bolt, color: Colors.white24, size: 12),
                      const SizedBox(width: 4),
                      Text('${rank['xp_threshold'] ?? rank['min_xp'] ?? rank['xp_required'] ?? 0} XP', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () => _handleEdit(rank), icon: const Icon(Icons.edit_outlined, color: Colors.white24, size: 20)),
            IconButton(onPressed: () => _handleDelete(rank['id'].toString()), icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20)),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('grand')) return const Color(0xFFD4AF37);
    if (n.contains('adept')) return const Color(0xFF00FBFF);
    return const Color(0xFFCCFF00);
  }

  IconData _getRankIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('grand')) return Icons.star;
    if (n.contains('adept')) return Icons.science;
    return Icons.bolt;
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    const double dashWidth = 5;
    const double dashSpace = 5;
    
    // Top
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Bottom
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    // Left
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Right
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
