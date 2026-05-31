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
  static const String _vlAssetBase = 'assets/virtual_lab';

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
    "agno3+kcl": ReactionResult(eq: "AgNO₃ + KCl → AgCl↓ + KNO₃", desc: "Terbentuk endapan putih perak klorida!", type: "💎 Precipitation", product: "AgCl", productFormula: "AgCl", color: const Color(0xFFF8F9FA), gradient: [const Color(0xFFF8F9FA), const Color(0xFFDEE2E6)]),
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

    // Award XP (+25) only once per reaction (server-enforced),
    // and avoid spamming the server for the same reaction within the same session.
    if (_reactedPairs.contains(canonicalKey)) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _showToast("Reaksi ini sudah dicoba. XP tidak bertambah.");
      });
      return;
    }

    ApiService().recordLabReaction(canonicalKey).then((data) {
      if (!mounted) return;
      setState(() {}); // Refresh header XP display
      if (data == null) {
        _showToast("⚠️ Gagal menyimpan XP (server).");
        return;
      }
      // Mark as tried this session (whether XP was added or not),
      // so we don't keep spamming the server for the same pair.
      _reactedPairs.add(canonicalKey);
      final xpAdded = ApiService.toInt(data['xp_added']);
      if (xpAdded > 0) {
        _showToast("⭐ +$xpAdded XP! Reaksi baru ditemukan!");
      } else {
        _showToast("Reaksi sudah pernah dilakukan. XP tidak bertambah.");
      }
    });
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
            _showToast("🔥 Tube ${_selectedTubeIndex! + 1} kosong (hasil diuapkan)");
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
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Lab Area (title + beakers + tubes + bunsen)
                      _buildLabArea(),
                      const SizedBox(height: 16),

                      // Action buttons
                      _buildControlButtons(),
                      const SizedBox(height: 20),

                      // Inventory
                      _buildInventory(),
                      const SizedBox(height: 20),

                      // Reaction Info
                      _buildReactionInfo(),
                      const SizedBox(height: 40),
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

  Widget _buildLabArea() {
    return Column(
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alchemist virtual lab',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('22 chemicals | mix, Heat & calculate Molar mass!',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
            ],
          ),
        ),

        // Beakers row
        Row(
          children: [
            Expanded(child: _buildBeakerWidget("A", _beakerA, _selectedBeaker == "A", () => _selectBeaker("A"))),
            const SizedBox(width: 12),
            Expanded(child: _buildBeakerWidget("B", _beakerB, _selectedBeaker == "B", () => _selectBeaker("B"))),
          ],
        ),
        const SizedBox(height: 16),

        // Tubes row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildTubeWidget(index, _tubes[index], _selectedTubeIndex == index,
                () => setState(() => _selectedTubeIndex = index)),
          )),
        ),
        const SizedBox(height: 16),

        // Bunsen burner flame + button
        Column(
          children: [
            _buildBunsenFlame(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _toggleBunsen,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 4), blurRadius: 0)],
                ),
                child: Text('BUNSEN BURNER',
                    style: GoogleFonts.spaceGrotesk(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBeakerWidget(String label, Map<String, dynamic> data, bool isSelected, VoidCallback onTap) {
    final int amount = ApiService.toInt(data['amount']);
    final String? chemId = data['chemical'] as String?;
    final Chemical? chem = chemId != null ? _chemicals[chemId] : null;
    final bool has = chemId != null && amount > 0;
    final Color liquidColor = has ? (data['color'] as Color? ?? const Color(0xFF00BCD4)) : Colors.transparent;
    final Color borderColor = isSelected ? const Color(0xFF00FBFF) : const Color(0xFF4A5568);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Beaker container
          Container(
            width: 160,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF0F1419),
            ),
            child: Stack(
              children: [
                // Liquid fill
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 160 * (amount.clamp(0, 100) / 100.0),
                    decoration: BoxDecoration(
                      color: liquidColor.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(17),
                        bottomRight: Radius.circular(17),
                      ),
                    ),
                  ),
                ),
                // Top label bar
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Beaker $label',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Volume and status
          Text(
            '$amount ml',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            has ? (chem?.name ?? 'UNKNOWN') : 'EMPTY',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTubeWidget(int index, Map<String, dynamic> data, bool isSelected, VoidCallback onTap) {
    final int amount = ApiService.toInt(data['amount']);
    final bool has = (data['chemical'] != null || data['name'] != null) && amount > 0;
    final Color liquidColor = has ? (data['color'] as Color? ?? const Color(0xFF00BCD4)) : Colors.transparent;
    final String chemName = has ? (data['name'] ?? data['chemical'] ?? 'UNKNOWN') : 'EMPTY';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tube container
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF4A5568),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF0F1419),
            ),
            child: Stack(
              children: [
                // Liquid fill
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 120 * (amount.clamp(0, 100) / 100.0),
                    decoration: BoxDecoration(
                      color: liquidColor.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tube label
          Text(
            'Tube ${index + 1}',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBunsenFlame() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _bunsenOn ? 1.0 : 0.3,
      child: Image.asset(
        'assets/bunsen_burner.png',
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.local_fire_department, color: Colors.white, size: 40),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    final buttons = [
      {'label': 'REACT',    'color': const Color(0xFFB8F400), 'shadow': const Color(0xFF8CBD00), 'action': _startReaction},
      {'label': 'ADD',      'color': const Color(0xFFD896FF), 'shadow': const Color(0xFFA256CC), 'action': _addChemical},
      {'label': 'TRANSFER', 'color': const Color(0xFF00D4D4), 'shadow': const Color(0xFF009999), 'action': _transferToTube},
      {'label': 'RESET',    'color': const Color(0xFFFF4D4D), 'shadow': const Color(0xFFCC2424), 'action': _resetExperiment},
    ];

    return Row(
      children: buttons.map((b) {
        final color = b['color'] as Color;
        final shadow = b['shadow'] as Color;
        final action = b['action'] as VoidCallback;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _LabButton(label: b['label'] as String, color: color, shadowColor: shadow, onPressed: action),
          ),
        );
      }).toList(),
    );
  }

  // _actionButton removed in favor of PNG button assets

  Widget _buildInventory() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _chemicals.length,
      itemBuilder: (context, index) {
        final chem = _chemicals.values.toList()[index];
        final isSelected = _selectedChemicalId == chem.id;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedChemicalId = chem.id);
            _showToast('Selected: ${chem.fullName}');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00D4D4).withOpacity(0.12) : const Color(0xFF0D2B2B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF00D4D4) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: chem.color, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chem.name,
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(chem.fullName,
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white54, fontSize: 9),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text('${chem.amount} ml',
                    style: GoogleFonts.spaceGrotesk(
                        color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactionInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(_currentEquation,
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(_currentReactionDesc,
              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A3A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_currentReactionType,
                style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// Tombol lab dengan efek 3D press (warna solid).
class _LabButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback onPressed;

  const _LabButton({
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.onPressed,
  });

  @override
  State<_LabButton> createState() => _LabButtonState();
}

class _LabButtonState extends State<_LabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _pressed
              ? []
              : [BoxShadow(color: widget.shadowColor, offset: const Offset(0, 5), blurRadius: 0)],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            widget.label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol gambar dengan efek "mendelep" (3D press).
class _ImageButton3D extends StatefulWidget {
  final String assetPath;
  final double height;
  final VoidCallback onPressed;

  const _ImageButton3D({
    required this.assetPath,
    required this.height,
    required this.onPressed,
  });

  @override
  State<_ImageButton3D> createState() => _ImageButton3DState();
}

class _ImageButton3DState extends State<_ImageButton3D> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 5 : 0, 0),
        child: Image.asset(
          widget.assetPath,
          height: widget.height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
