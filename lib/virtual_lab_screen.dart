import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'widgets/background_wrapper.dart';
import 'services/api_service.dart';

class Chemical {
  final String id;
  final String name;
  final String fullName;
  final String formula;
  final String type;
  int amount;
  final String unit;
  final Color color;
  final List<Color> gradient;
  final String emoji;

  Chemical({
    required this.id,
    required this.name,
    required this.fullName,
    required this.formula,
    required this.type,
    required this.amount,
    required this.unit,
    required this.color,
    required this.gradient,
    required this.emoji,
  });
}

class ReactionResult {
  final String eq;
  final String desc;
  final String type;
  final String product;
  final String productFormula;
  final Color color;
  final List<Color> gradient;

  ReactionResult({
    required this.eq,
    required this.desc,
    required this.type,
    required this.product,
    required this.productFormula,
    required this.color,
    required this.gradient,
  });
}

class VirtualLabScreen extends StatefulWidget {
  const VirtualLabScreen({super.key});

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen> {
  // State variables
  String _selectedBeaker = "A";
  String? _selectedChemicalId;
  bool _bunsenOn = false;
  Timer? _heatingTimer;
  int? _selectedTubeIndex;
  /// Tracks reacted pairs this session to prevent duplicate XP
  final Set<String> _reactedPairs = {};
  int get _displayXp => ApiService().currentUser?.totalXp ?? 0;

  // Lab components
  Map<String, dynamic> _beakerA = {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': '', 'bg': Colors.transparent};
  Map<String, dynamic> _beakerB = {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': '', 'bg': Colors.transparent};
  List<Map<String, dynamic>> _tubes = List.generate(3, (_) => {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': '', 'name': '', 'bg': Colors.transparent});

  // Reaction Info
  String _currentEquation = "✨ Pilih bahan dan klik REACT ✨";
  String _currentReactionDesc = "Campurkan dua bahan kimia untuk melihat reaksinya";
  String _currentReactionType = "🧪 22 Bahan Siap Bereaksi";


  late Map<String, Chemical> _chemicals;

  @override
  void initState() {
    super.initState();
    _initChemicals();
  }

  void _initChemicals() {
    _chemicals = {
      'hcl': Chemical(id: 'hcl', name: "HCl", fullName: "Hydrochloric Acid", formula: "HCl", type: "acid", amount: 100, unit: "ml", color: const Color(0xFFFF6B6B), gradient: [const Color(0xFFFF6B6B), const Color(0xFFC92A2A)], emoji: "🧪"),
      'h2so4': Chemical(id: 'h2so4', name: "H₂SO₄", fullName: "Sulfuric Acid", formula: "H2SO4", type: "acid", amount: 80, unit: "ml", color: const Color(0xFFFF922B), gradient: [const Color(0xFFFF922B), const Color(0xFFE8590C)], emoji: "🧪"),
      'hno3': Chemical(id: 'hno3', name: "HNO₃", fullName: "Nitric Acid", formula: "HNO3", type: "acid", amount: 80, unit: "ml", color: const Color(0xFFFFA94D), gradient: [const Color(0xFFFFA94D), const Color(0xFFF76707)], emoji: "🧪"),
      'ch3cooh': Chemical(id: 'ch3cooh', name: "CH₃COOH", fullName: "Acetic Acid", formula: "CH3COOH", type: "acid", amount: 100, unit: "ml", color: const Color(0xFFFFC078), gradient: [const Color(0xFFFFC078), const Color(0xFFF59F00)], emoji: "🧪"),
      'naoh': Chemical(id: 'naoh', name: "NaOH", fullName: "Sodium Hydroxide", formula: "NaOH", type: "base", amount: 100, unit: "ml", color: const Color(0xFF4DABF7), gradient: [const Color(0xFF4DABF7), const Color(0xFF1864AB)], emoji: "🧪"),
      'koh': Chemical(id: 'koh', name: "KOH", fullName: "Potassium Hydroxide", formula: "KOH", type: "base", amount: 90, unit: "ml", color: const Color(0xFF74C0FC), gradient: [const Color(0xFF74C0FC), const Color(0xFF1C7ED6)], emoji: "🧪"),
      'nh3': Chemical(id: 'nh3', name: "NH₃", fullName: "Ammonia", formula: "NH3", type: "base", amount: 80, unit: "ml", color: const Color(0xFFA5D8FF), gradient: [const Color(0xFFA5D8FF), const Color(0xFF4DABF7)], emoji: "🧪"),
      'nacl': Chemical(id: 'nacl', name: "NaCl", fullName: "Sodium Chloride", formula: "NaCl", type: "salt", amount: 100, unit: "ml", color: const Color(0xFFADB5BD), gradient: [const Color(0xFFADB5BD), const Color(0xFF6C757D)], emoji: "🧂"),
      'kcl': Chemical(id: 'kcl', name: "KCl", fullName: "Potassium Chloride", formula: "KCl", type: "salt", amount: 90, unit: "ml", color: const Color(0xFFCED4DA), gradient: [const Color(0xFFCED4DA), const Color(0xFF868E96)], emoji: "🧂"),
      'cacl2': Chemical(id: 'cacl2', name: "CaCl₂", fullName: "Calcium Chloride", formula: "CaCl2", type: "salt", amount: 80, unit: "ml", color: const Color(0xFFE9ECEF), gradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)], emoji: "🧂"),
      'mgso4': Chemical(id: 'mgso4', name: "MgSO₄", fullName: "Magnesium Sulfate", formula: "MgSO4", type: "salt", amount: 80, unit: "ml", color: const Color(0xFFF8F9FA), gradient: [const Color(0xFFF8F9FA), const Color(0xFFDEE2E6)], emoji: "🧂"),
      'na2co3': Chemical(id: 'na2co3', name: "Na₂CO₃", fullName: "Sodium Carbonate", formula: "Na2CO3", type: "carbonate", amount: 80, unit: "ml", color: const Color(0xFFE9ECEF), gradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)], emoji: "🧂"),
      'zn': Chemical(id: 'zn', name: "Zn", fullName: "Zinc Metal", formula: "Zn", type: "metal", amount: 50, unit: "g", color: const Color(0xFFCED4DA), gradient: [const Color(0xFFCED4DA), const Color(0xFF868E96)], emoji: "⚙️"),
      'mg': Chemical(id: 'mg', name: "Mg", fullName: "Magnesium Metal", formula: "Mg", type: "metal", amount: 40, unit: "g", color: const Color(0xFFE9ECEF), gradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)], emoji: "⚙️"),
      'al': Chemical(id: 'al', name: "Al", fullName: "Aluminum Metal", formula: "Al", type: "metal", amount: 40, unit: "g", color: const Color(0xFFE9ECEF), gradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)], emoji: "⚙️"),
      'fe': Chemical(id: 'fe', name: "Fe", fullName: "Iron Metal", formula: "Fe", type: "metal", amount: 40, unit: "g", color: const Color(0xFF868E96), gradient: [const Color(0xFF868E96), const Color(0xFF495057)], emoji: "⚙️"),
      'caco3': Chemical(id: 'caco3', name: "CaCO₃", fullName: "Calcium Carbonate", formula: "CaCO3", type: "carbonate", amount: 60, unit: "g", color: const Color(0xFFF8F9FA), gradient: [const Color(0xFFF8F9FA), const Color(0xFFDEE2E6)], emoji: "🪨"),
      'agno3': Chemical(id: 'agno3', name: "AgNO₃", fullName: "Silver Nitrate", formula: "AgNO3", type: "salt", amount: 80, unit: "ml", color: const Color(0xFFE9ECEF), gradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)], emoji: "✨"),
      'pbno3': Chemical(id: 'pbno3', name: "Pb(NO₃)₂", fullName: "Lead(II) Nitrate", formula: "Pb(NO3)2", type: "salt", amount: 70, unit: "ml", color: const Color(0xFFE9ECEF), gradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)], emoji: "✨"),
      'ki': Chemical(id: 'ki', name: "KI", fullName: "Potassium Iodide", formula: "KI", type: "salt", amount: 80, unit: "ml", color: const Color(0xFFF8F9FA), gradient: [const Color(0xFFF8F9FA), const Color(0xFFDEE2E6)], emoji: "✨"),
      'cuso4': Chemical(id: 'cuso4', name: "CuSO₄", fullName: "Copper(II) Sulfate", formula: "CuSO4", type: "salt", amount: 70, unit: "ml", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)], emoji: "💎"),
      'fecl3': Chemical(id: 'fecl3', name: "FeCl₃", fullName: "Iron(III) Chloride", formula: "FeCl3", type: "salt", amount: 70, unit: "ml", color: const Color(0xFFFF8787), gradient: [const Color(0xFFFF8787), const Color(0xFFF03E3E)], emoji: "🔴"),
    };
  }

  final Map<String, ReactionResult> _reactions = {
    "hcl+naoh": ReactionResult(eq: "HCl + NaOH → NaCl + H₂O", desc: "Netralisasi! Asam + Basa menghasilkan garam dan air", type: "⚡ Neutralization", product: "NaCl", productFormula: "NaCl", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)]),
    "h2so4+naoh": ReactionResult(eq: "H₂SO₄ + 2NaOH → Na₂SO₄ + 2H₂O", desc: "Netralisasi! Asam Sulfat + Natrium Hidroksida", type: "⚡ Neutralization", product: "Na2SO4", productFormula: "Na2SO4", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)]),
    "hcl+zn": ReactionResult(eq: "2HCl + Zn → ZnCl₂ + H₂↑", desc: "Logam seng bereaksi dengan asam menghasilkan gas hidrogen!", type: "🔥 Redox", product: "ZnCl2", productFormula: "ZnCl2", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)]),
    "hcl+mg": ReactionResult(eq: "2HCl + Mg → MgCl₂ + H₂↑", desc: "Logam magnesium bereaksi hebat dengan asam!", type: "🔥 Redox", product: "MgCl2", productFormula: "MgCl2", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)]),
    "hcl+caco3": ReactionResult(eq: "2HCl + CaCO₃ → CaCl₂ + CO₂↑ + H₂O", desc: "Asam melarutkan batu kapur! Keluar gelembung CO₂", type: "💨 Gas Formation", product: "CaCl2", productFormula: "CaCl2", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)]),
    "hcl+na2co3": ReactionResult(eq: "2HCl + Na₂CO₃ → 2NaCl + CO₂↑ + H₂O", desc: "Asam bereaksi dengan soda kue menghasilkan gelembung CO₂!", type: "💨 Gas Formation", product: "NaCl", productFormula: "NaCl", color: const Color(0xFF69DB7E), gradient: [const Color(0xFF69DB7E), const Color(0xFF2B8A3E)]),
    "agno3+nacl": ReactionResult(eq: "AgNO₃ + NaCl → AgCl↓ + NaNO₃", desc: "Terbentuk endapan putih perak klorida!", type: "💎 Precipitation", product: "AgCl", productFormula: "AgCl", color: const Color(0xFFF8F9FA), gradient: [const Color(0xFFF8F9FA), const Color(0xFFDEE2E6)]),
    "pbno3+ki": ReactionResult(eq: "Pb(NO₃)₂ + 2KI → PbI₂↓ + 2KNO₃", desc: "Terbentuk endapan kuning cerah timbal iodida!", type: "💎 Precipitation", product: "PbI2", productFormula: "PbI2", color: const Color(0xFFFFD43B), gradient: [const Color(0xFFFFD43B), const Color(0xFFFAB005)]),
    "cuso4+naoh": ReactionResult(eq: "CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄", desc: "Terbentuk endapan biru tembaga(II) hidroksida!", type: "💎 Precipitation", product: "Cu(OH)2", productFormula: "Cu(OH)2", color: const Color(0xFF4DABF7), gradient: [const Color(0xFF4DABF7), const Color(0xFF1864AB)]),
    "fecl3+naoh": ReactionResult(eq: "FeCl₃ + 3NaOH → Fe(OH)₃↓ + 3NaCl", desc: "Terbentuk endapan coklat besi(III) hidroksida!", type: "💎 Precipitation", product: "Fe(OH)3", productFormula: "Fe(OH)3", color: const Color(0xFFD4A373), gradient: [const Color(0xFFD4A373), const Color(0xFFB5835A)]),
    "zn+cuso4": ReactionResult(eq: "Zn + CuSO₄ → ZnSO₄ + Cu↓", desc: "Logam seng menggantikan tembaga! Endapan tembaga merah", type: "🔥 Redox", product: "Cu", productFormula: "Cu", color: const Color(0xFFE8590C), gradient: [const Color(0xFFE8590C), const Color(0xFFC92A2A)]),
    "nh3+hcl": ReactionResult(eq: "NH₃ + HCl → NH₄Cl", desc: "Amonia bereaksi dengan asam membentuk asap putih!", type: "✨ Gas Reaction", product: "NH4Cl", productFormula: "NH4Cl", color: const Color(0xFFF8F9FA), gradient: [const Color(0xFFF8F9FA), const Color(0xFFDEE2E6)]),
  };

  void _selectBeaker(String id) {
    setState(() {
      _selectedBeaker = id;
    });
    final beaker = id == "A" ? _beakerA : _beakerB;
    if (beaker['amount'] > 0) {
      _showBeakerPopup(id, beaker);
    } else {
      _showToast("🧪 Beaker $id selected");
    }
  }

  void _showBeakerPopup(String id, Map<String, dynamic> beaker) {
    final chemId = beaker['chemical'];
    final chem = _chemicals[chemId];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
        title: Text("Beaker $id Content", style: GoogleFonts.spaceGrotesk(color: const Color(0xFFCCFF00), fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: beaker['color'], borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(chem?.emoji ?? "🧪", style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 16),
            Text(chem?.fullName ?? "Unknown Substance", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(beaker['formula'] ?? "", style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FBFF), fontSize: 14)),
            const SizedBox(height: 8),
            Text("Volume: ${beaker['amount']} ml", style: GoogleFonts.spaceGrotesk(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CLOSE", style: GoogleFonts.spaceGrotesk(color: Colors.white38))),
        ],
      ),
    );
  }

  void _addChemical() {
    if (_selectedChemicalId == null) {
      _showToast("❌ Pilih bahan kimia dulu!");
      return;
    }
    final chem = _chemicals[_selectedChemicalId]!;
    if (chem.amount <= 0) {
      _showToast("❌ Stok ${chem.fullName} habis! Klik RESET");
      return;
    }

    setState(() {
      final beaker = _selectedBeaker == "A" ? _beakerA : _beakerB;
      if (beaker['chemical'] != null && beaker['chemical'] != _selectedChemicalId) {
        _showToast("⚠️ Beaker sudah berisi ${beaker['chemical']}! Klik RESET");
        return;
      }
      chem.amount -= 10;
      beaker['chemical'] = _selectedChemicalId;
      beaker['amount'] = (beaker['amount'] + 10).clamp(0, 100);
      beaker['color'] = chem.color;
      beaker['formula'] = chem.formula;
    });
    _showToast("✅ ${chem.emoji} ${chem.name} +10ml ke Beaker $_selectedBeaker");
  }

  void _startReaction() {
    if (_beakerA['chemical'] == null || _beakerB['chemical'] == null) {
      _showToast("❌ Kedua beaker harus berisi bahan!");
      return;
    }
    String key1 = "${_beakerA['chemical']}+${_beakerB['chemical']}";
    String key2 = "${_beakerB['chemical']}+${_beakerA['chemical']}";
    
    ReactionResult? result = _reactions[key1] ?? _reactions[key2];

    if (result == null) {
      setState(() {
        _currentEquation = "⚠️ Tidak bereaksi";
        _currentReactionDesc = "Kombinasi ini tidak menghasilkan reaksi kimia";
        _currentReactionType = "❌ Tidak bereaksi";
      });
      _showToast("❌ Tidak bereaksi");
      return;
    }

    // Use canonical key (sorted) to detect same pair regardless of order
    final List<String> parts = [
      _beakerA['chemical'] as String,
      _beakerB['chemical'] as String,
    ]..sort();
    final String canonicalKey = parts.join('+');

    setState(() {
      _currentEquation = result.eq;
      _currentReactionDesc = result.desc;
      _currentReactionType = result.type;
      
      int emptyTube = _tubes.indexWhere((t) => t['chemical'] == null);
      if (emptyTube != -1) {
        _tubes[emptyTube] = {
          'chemical': result.product,
          'amount': _beakerA['amount'],
          'color': result.color,
          'formula': result.productFormula,
          'name': result.product,
        };
        _showToast("✨ Reaksi selesai! Hasil masuk Tube ${emptyTube + 1}");
      } else {
        _showToast("✨ Reaksi selesai! Tapi semua tube penuh");
      }
      _beakerA = {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': ''};
      _beakerB = {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': ''};
    });

    // Award XP only if this pair hasn't been reacted before in this session
    if (!_reactedPairs.contains(canonicalKey)) {
      _reactedPairs.add(canonicalKey);
      ApiService().addLabXp(10);
      setState(() {}); // Refresh header XP display
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showToast("⭐ +10 XP! Reaksi baru ditemukan!");
      });
    }
  }


  void _transferToTube() {
    final beaker = _selectedBeaker == "A" ? _beakerA : _beakerB;
    if (beaker['chemical'] == null) {
      _showToast("❌ Beaker kosong!");
      return;
    }
    setState(() {
      int emptyTube = _tubes.indexWhere((t) => t['chemical'] == null);
      if (emptyTube != -1) {
        _tubes[emptyTube] = {
          'chemical': beaker['chemical'],
          'amount': beaker['amount'],
          'color': beaker['color'],
          'formula': beaker['formula'],
          'name': beaker['chemical'],
        };
        beaker['chemical'] = null;
        beaker['amount'] = 0;
        beaker['color'] = Colors.transparent;
        _showToast("✅ Dipindahkan ke tube ${emptyTube + 1}");
      } else {
        _showToast("❌ Semua tube penuh! Klik RESET");
      }
    });
  }

  void _toggleBunsen() {
    setState(() {
      _bunsenOn = !_bunsenOn;
    });
    _showToast(_bunsenOn ? "🔥 Bunsen menyala!" : "Bunsen mati");
    if (_bunsenOn) {
      _startHeating();
    } else {
      _heatingTimer?.cancel();
    }
  }

  void _startHeating() {
    _heatingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_bunsenOn || _selectedTubeIndex == null) return;
      setState(() {
        final tube = _tubes[_selectedTubeIndex!];
        if (tube['chemical'] != null && tube['amount'] > 0) {
          tube['amount'] = (tube['amount'] - 5).clamp(0, 100);
          if (tube['amount'] == 0) {
            tube['chemical'] = null;
            ApiService().addLabXp(10);
            _showToast("🔥 Tube ${_selectedTubeIndex! + 1} habis! +10 XP");
          }
        }
      });
    });
  }

  void _resetExperiment() {
    setState(() {
      _initChemicals();
      _beakerA = {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': ''};
      _beakerB = {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': ''};
      _tubes = List.generate(3, (_) => {'chemical': null, 'amount': 0, 'color': Colors.transparent, 'formula': '', 'name': ''});
      _bunsenOn = false;
      _heatingTimer?.cancel();
      _currentEquation = "✨ Pilih bahan dan klik REACT ✨";
      _currentReactionDesc = "Campurkan dua bahan kimia untuk melihat reaksinya";
      _currentReactionType = "🧪 22 Bahan Siap Bereaksi";
    });
    _showToast("🧪 Semua direset!");
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  @override
  void dispose() {
    _heatingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      showGrid: true,
      removeSafeAreaPadding: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Lab Area
                      _buildLabArea(),
                      const SizedBox(height: 12),
                      
                      // Controls
                      _buildControlButtons(),
                      const SizedBox(height: 12),
                      
                      // Inventory
                      _buildInventory(),
                      const SizedBox(height: 12),
                      

                      // Reaction Info
                      _buildReactionInfo(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("⚗️ ALCHEMIST LAB PRO", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              Text("22 Chemicals | Mix, Heat & Calculate", style: GoogleFonts.spaceGrotesk(color: Colors.white.withOpacity(0.5), fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text("$_displayXp XP", style: GoogleFonts.spaceGrotesk(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          // Beakers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildBeakerWidget("A", _beakerA, _selectedBeaker == "A", () => _selectBeaker("A"))),
              const SizedBox(width: 16),
              Expanded(child: _buildBeakerWidget("B", _beakerB, _selectedBeaker == "B", () => _selectBeaker("B"))),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tubes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildTubeWidget(index, _tubes[index], _selectedTubeIndex == index, () => setState(() => _selectedTubeIndex = index)),
            )),
          ),
          const SizedBox(height: 16),
          
          // Bunsen
          Column(
            children: [
              _buildBunsenFlame(),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _toggleBunsen,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, color: _bunsenOn ? Colors.orange : Colors.white, size: 16),
                      const SizedBox(width: 6),
                      const Text("Bunsen Burner", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeakerWidget(String label, Map<String, dynamic> data, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text("🧪 Beaker $label", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (data['amount'] > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: (data['amount'] as int).toDouble(),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: data['color'] as Color,
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text("${data['amount']} ml", style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(data['chemical'] != null ? _chemicals[data['chemical']]?.name ?? "Empty" : "Empty", 
                 style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTubeWidget(int index, Map<String, dynamic> data, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 90,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
              border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.2), width: 2),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (data['amount'] > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: (data['amount'] as int).toDouble() * 0.9,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: data['color'] as Color,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(13), bottomRight: Radius.circular(13)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text("Tube ${index + 1}", style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildBunsenFlame() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _bunsenOn ? 1.0 : 0.0,
      child: Container(
        width: 35, height: 35,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [Color(0xFFFF6B00), Color(0xFFFFD700)]),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _actionButton("React", const Color(0xFFFFD700), Colors.black, Icons.play_arrow, _startReaction),
        _actionButton("Add", Colors.white.withOpacity(0.1), Colors.white, Icons.add, _addChemical),
        _actionButton("Transfer", Colors.white.withOpacity(0.1), Colors.white, Icons.swap_horiz, _transferToTube),
        _actionButton("Reset", Colors.red.withOpacity(0.2), const Color(0xFFFF6B6B), Icons.refresh, _resetExperiment),
      ],
    );
  }

  Widget _actionButton(String label, Color bg, Color text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: text, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventory() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text("Chemical Inventory (22 Bahan)", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _chemicals.length,
              itemBuilder: (context, index) {
                final chem = _chemicals.values.toList()[index];
                final isSelected = _selectedChemicalId == chem.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedChemicalId = chem.id);
                    _showToast("✅ Selected: ${chem.fullName} (${chem.formula})");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Container(width: 35, height: 35, decoration: BoxDecoration(color: chem.color, borderRadius: BorderRadius.circular(10))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${chem.emoji} ${chem.name}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(chem.fullName, style: const TextStyle(color: Colors.white38, fontSize: 9), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Text("${chem.amount}", style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(_currentEquation, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_currentReactionDesc, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(_currentReactionType, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9)),
          ),
        ],
      ),
    );
  }
}
