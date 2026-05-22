import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';

class AvatarShopScreen extends StatefulWidget {
  const AvatarShopScreen({super.key});

  @override
  State<AvatarShopScreen> createState() => _AvatarShopScreenState();
}

class _AvatarShopScreenState extends State<AvatarShopScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _allAvatars = [];
  List<dynamic> _myAvatars = [];
  int? _equippedId;
  bool _isLoading = true;
  bool _isSaving = false;
  
  late PageController _pageController;
  int _currentPageIndex = 0;
  Color? _selectedColor;

  final List<Color> _availableColors = [
    const Color(0xFF00FBFF), // Cyan
    const Color(0xFFE67E22), // Orange
    const Color(0xFF34495E), // Dark Blue Grey
    const Color(0xFF9B59B6), // Purple
    const Color(0xFFCCFF00), // Lime
    const Color(0xFFE74C3C), // Red
    const Color(0xFFF1C40F), // Yellow
    const Color(0xFF00529B), // Deep Blue
  ];

  static const _cyan = Color(0xFF00FBFF);
  static const _lime = Color(0xFFCCFF00);
  static const _bgCard = Color(0xFF161D1E);
  static const _btnTeal = Color(0xFF4F818A);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _api.getAvatars(),
      _api.getMyAvatars(),
    ]);
    if (mounted) {
      setState(() {
        _allAvatars = results[0];
        _myAvatars = results[1];
        _equippedId = _api.currentUser?.equippedAvatarId;
        
        // Find current equipped index
        if (_equippedId != null) {
          final idx = _allAvatars.indexWhere((a) => a['id'] == _equippedId);
          if (idx != -1) {
            _currentPageIndex = idx;
            // Delay moving the page until the view is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(idx);
              }
            });
          }
        }
        
        if (_api.currentUser?.profileBgColor != null) {
          try {
            final hex = _api.currentUser!.profileBgColor!.replaceFirst('#', '');
            _selectedColor = Color(int.parse('FF$hex', radix: 16));
          } catch (e) {
            _selectedColor = _availableColors[0];
          }
        } else {
          _selectedColor = _availableColors[0];
        }
        
        _isLoading = false;
      });
    }
  }

  Future<void> _equip(int id) async {
    final success = await _api.equipAvatar(id);
    if (success && mounted) {
      setState(() => _equippedId = id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar equipped!'), backgroundColor: _lime),
      );
    }
  }

  Future<void> _pickImage(Function(String) onUrlReady) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      final String? url = await _api.uploadImage(bytes, image.name);
      if (url != null) {
        onUrlReady(url);
      }
    }
  }

  Future<void> _deleteAvatar(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bgCard,
        title: const Text('Delete Avatar?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _api.deleteAvatar(id);
      if (success) _loadData();
    }
  }

  void _showAvatarForm([dynamic avatar]) {
    final nameController = TextEditingController(text: avatar?['name']);
    final descController = TextEditingController(text: avatar?['description']);
    String imageUrl = avatar?['image_url'] ?? '';
    final valueController = TextEditingController(text: avatar?['unlock_value']?.toString());
    String type = avatar?['unlock_type'] ?? 'streak';
    String rarity = avatar?['rarity'] ?? 'common';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _bgCard,
          title: Text(avatar == null ? 'ADD AVATAR' : 'EDIT AVATAR', style: const TextStyle(color: _cyan)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _pickImage((url) => setDialogState(() => imageUrl = url)),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                      border: Border.all(color: _cyan.withOpacity(0.3)),
                      image: imageUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: imageUrl.isEmpty 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: _cyan, size: 30),
                            Text('GALLERY', style: TextStyle(color: _cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : null,
                  ),
                ),
                const SizedBox(height: 20),
                _formField('Name', nameController),
                _formField('Description', descController),
                _formField('Unlock Value', valueController, isNumber: true),
                const SizedBox(height: 12),
                _dropdown('Unlock Type', type, ['streak', 'xp', 'special'], (v) => setDialogState(() => type = v!)),
                _dropdown('Rarity', rarity, ['common', 'rare', 'epic', 'legendary'], (v) => setDialogState(() => rarity = v!)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _lime),
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required!')));
                  return;
                }
                if (imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick an image!')));
                  return;
                }
                final data = {
                  'name': nameController.text,
                  'description': descController.text,
                  'image_url': imageUrl,
                  'unlock_type': type,
                  'unlock_value': int.tryParse(valueController.text) ?? 0,
                  'rarity': rarity,
                };
                
                bool success;
                if (avatar == null) {
                  success = await _api.createAvatar(data);
                } else {
                  success = await _api.updateAvatar(avatar['id'], data);
                }

                if (success) {
                  if (mounted) Navigator.pop(context);
                  _loadData();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save avatar. Check connection or data.'), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
              child: const Text('SAVE', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _bgCard,
          style: const TextStyle(color: Colors.white),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _api.currentUser?.role.toString().contains('admin') ?? false;

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('CHANGE AVATAR', style: TextStyle(color: _cyan, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.add, color: _cyan),
                onPressed: () => _showAvatarForm(),
              ),
            if (isAdmin && _allAvatars.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.edit, color: _lime),
                onPressed: () => _showAvatarForm(_allAvatars[_currentPageIndex]),
              ),
            if (isAdmin && _allAvatars.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteAvatar(_allAvatars[_currentPageIndex]['id']),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _cyan))
            : _allAvatars.isEmpty
                ? const Center(child: Text('No avatars found', style: TextStyle(color: Colors.white)))
                : Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) => setState(() => _currentPageIndex = index),
                              itemCount: _allAvatars.length,
                              itemBuilder: (context, index) {
                                final avatar = _allAvatars[index];
                                final isUnlocked = _myAvatars.any((m) => m['id'] == avatar['id']);
                                return Center(
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(avatar['image_url']),
                                          fit: BoxFit.cover,
                                        ),
                                        color: _selectedColor ?? Colors.transparent,
                                      ),
                                    foregroundDecoration: isUnlocked ? null : const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: !isUnlocked
                                        ? const Icon(Icons.lock, color: Colors.white, size: 80)
                                        : null,
                                  ),
                                );
                              },
                            ),
                            if (_currentPageIndex > 0)
                              Positioned(
                                left: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
                                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                ),
                              ),
                            if (_currentPageIndex < _allAvatars.length - 1)
                              Positioned(
                                right: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                                  onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_allAvatars.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _currentPageIndex == index ? _btnTeal : Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // Name
                      Text(
                        _allAvatars[_currentPageIndex]['name'].toString().toUpperCase(),
                        style: const TextStyle(color: _cyan, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          (_allAvatars[_currentPageIndex]['description'] ?? '').toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Rarity
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: _lime,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _allAvatars[_currentPageIndex]['rarity'].toString().toUpperCase(),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Color Selection
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: _availableColors.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color),
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                  border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _btnTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 140,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _btnTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _isSaving ? null : () async {
                                final avatarId = _allAvatars[_currentPageIndex]['id'];
                                final isUnlocked = _myAvatars.any((m) => m['id'] == avatarId);
                                if (isUnlocked) {
                                  setState(() => _isSaving = true);
                                  try {
                                    // Save color too
                                    String? hex;
                                    if (_selectedColor != null) {
                                      hex = '#${_selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}';
                                    }
                                    await _api.updateProfileBgColor(hex);
                                    await _equip(avatarId);
                                    if (mounted) Navigator.pop(context);
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
                                    }
                                  } finally {
                                    if (mounted) setState(() => _isSaving = false);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar is locked!')));
                                }
                              },
                              child: _isSaving
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('SAVE AVATAR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
      ),
    );
  }
}
