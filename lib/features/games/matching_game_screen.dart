import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class MatchingPair {
  final String leftId;
  final String leftName;
  final IconData leftIcon;
  
  final String rightId;
  final String rightName;
  final IconData rightIcon;

  MatchingPair({
    required this.leftId,
    required this.leftName,
    required this.leftIcon,
    required this.rightId,
    required this.rightName,
    required this.rightIcon,
  });
}

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  // Massive database of 15 unique matching pairs!
  static final List<MatchingPair> _allPairsDatabase = [
    MatchingPair(
      leftId: 'scissors', leftName: 'Qaychi ✂️', leftIcon: Icons.content_cut_rounded,
      rightId: 'paper', rightName: 'Rangli Qog\'oz 📄', rightIcon: Icons.newspaper_rounded,
    ),
    MatchingPair(
      leftId: 'needle', leftName: 'Igna 🪡', leftIcon: Icons.architecture_rounded,
      rightId: 'thread', rightName: 'Chiroyli Ip 🧵', rightIcon: Icons.circle_outlined,
    ),
    MatchingPair(
      leftId: 'clay_knife', leftName: 'Loy pichog\'i 🔪', leftIcon: Icons.palette_rounded,
      rightId: 'clay', rightName: 'Plastilin / Loy 🪵', rightIcon: Icons.landscape_rounded,
    ),
    MatchingPair(
      leftId: 'hammer', leftName: 'Bolg\'a 🔨', leftIcon: Icons.handyman_rounded,
      rightId: 'nail', rightName: 'Temir Mix 🔩', rightIcon: Icons.construction_rounded,
    ),
    MatchingPair(
      leftId: 'button', leftName: 'Tugma 🔘', leftIcon: Icons.circle_rounded,
      rightId: 'fabric', rightName: 'Mato kiyim 👗', rightIcon: Icons.checkroom_rounded,
    ),
    MatchingPair(
      leftId: 'pattern', leftName: 'Andoza 📐', leftIcon: Icons.architecture_rounded,
      rightId: 'pattern_paper', rightName: 'Andoza qog\'ozi 📄', rightIcon: Icons.feed_rounded,
    ),
    MatchingPair(
      leftId: 'thimble', leftName: 'Angishvona 🛡️', leftIcon: Icons.verified_user_rounded,
      rightId: 'finger', rightName: 'Barmoq himoyasi ☝️', rightIcon: Icons.back_hand_rounded,
    ),
    MatchingPair(
      leftId: 'plane', leftName: 'Randa 🪵', leftIcon: Icons.crop_portrait_rounded,
      rightId: 'board', rightName: 'Yog\'och taxta 🪵', rightIcon: Icons.layers_rounded,
    ),
    MatchingPair(
      leftId: 'saw', leftName: 'Arra 🪚', leftIcon: Icons.handyman_rounded,
      rightId: 'tree', rightName: 'Qalin daraxt 🌲', rightIcon: Icons.nature_rounded,
    ),
    MatchingPair(
      leftId: 'sandpaper', leftName: 'Sumbada 📄', leftIcon: Icons.texture_rounded,
      rightId: 'polish', rightName: 'Silliqlash 🧴', rightIcon: Icons.brush_rounded,
    ),
    MatchingPair(
      leftId: 'glue', leftName: 'Yelim 🧪', leftIcon: Icons.science_rounded,
      rightId: 'glue_paper', rightName: 'Qog\'oz yopishtirish 🔗', rightIcon: Icons.link_rounded,
    ),
    MatchingPair(
      leftId: 'ruler', leftName: 'Chizg\'ich 📏', leftIcon: Icons.straighten_rounded,
      rightId: 'measure', rightName: 'O\'lchash 📐', rightIcon: Icons.mode_edit_rounded,
    ),
    MatchingPair(
      leftId: 'brush', leftName: 'Mo\'yqalam 🖌️', leftIcon: Icons.brush_rounded,
      rightId: 'paint', rightName: 'Akvarel bo\'yoq 🎨', rightIcon: Icons.palette_rounded,
    ),
    MatchingPair(
      leftId: 'pencil', leftName: 'Qalam ✏️', leftIcon: Icons.edit_rounded,
      rightId: 'sketch', rightName: 'Chizilgan chiziq 📈', rightIcon: Icons.show_chart_rounded,
    ),
    MatchingPair(
      leftId: 'drill', leftName: 'Parma 🔩', leftIcon: Icons.settings_backup_restore_rounded,
      rightId: 'hole', rightName: 'Teshik ochish 🕳️', rightIcon: Icons.adjust_rounded,
    ),
  ];

  List<Map<String, dynamic>> _leftItems = [];
  List<Map<String, dynamic>> _rightItems = [];

  String? _selectedLeftId;
  String? _selectedRightId;
  final Set<String> _matchedLeftIds = {};
  final Set<String> _matchedRightIds = {};
  bool _finished = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _generateRandomLevel();
  }

  void _generateRandomLevel() {
    // Pick 4 random pairs from our massive 15-pairs database!
    final List<MatchingPair> pool = List<MatchingPair>.from(_allPairsDatabase)..shuffle();
    final List<MatchingPair> selectedPairs = pool.take(4).toList();

    // Map left side and right side
    _leftItems = selectedPairs.map((pair) => {
      'id': pair.leftId,
      'name': pair.leftName,
      'icon': pair.leftIcon,
      'pairId': pair.rightId,
    }).toList()..shuffle();

    _rightItems = selectedPairs.map((pair) => {
      'id': pair.rightId,
      'name': pair.rightName,
      'icon': pair.rightIcon,
      'pairId': pair.leftId,
    }).toList()..shuffle();

    _selectedLeftId = null;
    _selectedRightId = null;
    _matchedLeftIds.clear();
    _matchedRightIds.clear();
    _finished = false;
  }

  void _onLeftTap(String id) {
    if (_matchedLeftIds.contains(id) || _finished) return;
    setState(() {
      _selectedLeftId = id;
      _checkMatch();
    });
  }

  void _onRightTap(String id) {
    if (_matchedRightIds.contains(id) || _finished) return;
    setState(() {
      _selectedRightId = id;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (_selectedLeftId != null && _selectedRightId != null) {
      final leftItem = _leftItems.firstWhere((item) => item['id'] == _selectedLeftId);
      final rightItem = _rightItems.firstWhere((item) => item['id'] == _selectedRightId);

      if (leftItem['pairId'] == rightItem['id']) {
        // Success match!
        _matchedLeftIds.add(_selectedLeftId!);
        _matchedRightIds.add(_selectedRightId!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("To'g'ri moslashtirdingiz! 🎉", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 600),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        // Wrong match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Noto'g'ri juftlik, qayta urinib ko'ring! 🧐", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 600),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      _selectedLeftId = null;
      _selectedRightId = null;

      if (_matchedLeftIds.length == _leftItems.length) {
        setState(() {
          _finished = true;
        });
        _saveScore();
      }
    }
  }

  Future<void> _saveScore() async {
    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            final currentXP = snapshot.data()?['xp'] ?? 0;
            transaction.update(docRef, {'xp': currentXP + 30});
          }
        });
      } catch (e) {
        debugPrint("Ball saqlashda xatolik: $e");
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Moslashtirish", style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _finished ? _buildFinishedScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.deepPurple,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Text(
            "Asbob va materiallarni bir-biriga to'g'ri moslang!",
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Left Items (Tools)
                Expanded(
                  child: Column(
                    children: _leftItems.map((item) {
                      final String id = item['id'] as String;
                      final isMatched = _matchedLeftIds.contains(id);
                      final isSelected = _selectedLeftId == id;
                      return GestureDetector(
                        onTap: () => _onLeftTap(id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.green.shade50
                                : isSelected
                                    ? Colors.deepPurple.shade50
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isMatched
                                  ? Colors.green
                                  : isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade200,
                              width: 2.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item['icon'] as IconData, size: 36, color: isMatched ? Colors.green : Colors.deepPurple),
                              const SizedBox(height: 8),
                              Text(
                                item['name'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isMatched ? Colors.green : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 20),
                // Right Items (Materials)
                Expanded(
                  child: Column(
                    children: _rightItems.map((item) {
                      final String id = item['id'] as String;
                      final isMatched = _matchedRightIds.contains(id);
                      final isSelected = _selectedRightId == id;
                      return GestureDetector(
                        onTap: () => _onRightTap(id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.green.shade50
                                : isSelected
                                    ? Colors.deepPurple.shade50
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isMatched
                                  ? Colors.green
                                  : isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade200,
                              width: 2.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item['icon'] as IconData, size: 36, color: isMatched ? Colors.green : Colors.deepPurple),
                              const SizedBox(height: 8),
                              Text(
                                item['name'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isMatched ? Colors.green : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Barakalla! 🎉",
              style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              "Barcha asboblarni muvaffaqiyatli moslashtirdingiz!",
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "+30 Ball to'pladingiz!",
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    setState(() {
                      _generateRandomLevel();
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text("Yana o'ynash", style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text("Orqaga", style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
