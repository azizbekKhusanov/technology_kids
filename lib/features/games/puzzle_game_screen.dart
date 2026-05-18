import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class PuzzlePiece {
  final int correctIndex;
  final String content;
  final Color color;

  PuzzlePiece({
    required this.correctIndex,
    required this.content,
    required this.color,
  });
}

class PuzzleLevel {
  final String title;
  final String description;
  final List<PuzzlePiece> pieces;

  PuzzleLevel({
    required this.title,
    required this.description,
    required this.pieces,
  });
}

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  // Massive database of 6 unique levels/themes!
  static final List<PuzzleLevel> _levelsDatabase = [
    PuzzleLevel(
      title: "Texnologiya Asboblari 🛠️",
      description: "Maktabdagi texnologiya darsining eng kerakli asboblari.",
      pieces: [
        PuzzlePiece(correctIndex: 0, content: "✂️", color: const Color(0xFFFEE2E2)),
        PuzzlePiece(correctIndex: 1, content: "📄", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 2, content: "📐", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 3, content: "🪡", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 4, content: "🧶", color: const Color(0xFFF3E8FF)),
        PuzzlePiece(correctIndex: 5, content: "🔨", color: const Color(0xFFFFF1F2)),
        PuzzlePiece(correctIndex: 6, content: "🪵", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 7, content: "🎨", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 8, content: "🏆", color: const Color(0xFFFFFBEB)),
      ],
    ),
    PuzzleLevel(
      title: "Tabiat materiallari 🍁",
      description: "Tabiiy materiallar va o'simliklar dunyosi.",
      pieces: [
        PuzzlePiece(correctIndex: 0, content: "🍁", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 1, content: "🪵", color: const Color(0xFFF5F5F4)),
        PuzzlePiece(correctIndex: 2, content: "🐚", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 3, content: "🪨", color: const Color(0xFFF1F5F9)),
        PuzzlePiece(correctIndex: 4, content: "🌰", color: const Color(0xFFFAF7F5)),
        PuzzlePiece(correctIndex: 5, content: "🌲", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 6, content: "🌸", color: const Color(0xFFFFF1F2)),
        PuzzlePiece(correctIndex: 7, content: "🍄", color: const Color(0xFFFEE2E2)),
        PuzzlePiece(correctIndex: 8, content: "🍀", color: const Color(0xFFF0FDF4)),
      ],
    ),
    PuzzleLevel(
      title: "Tikuvchilik olami 🪡",
      description: "Kiyim bichish, tikish va dizayn dunyosi.",
      pieces: [
        PuzzlePiece(correctIndex: 0, content: "🧵", color: const Color(0xFFF3E8FF)),
        PuzzlePiece(correctIndex: 1, content: "🪡", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 2, content: "✂️", color: const Color(0xFFFEE2E2)),
        PuzzlePiece(correctIndex: 3, content: "👗", color: const Color(0xFFFFF1F2)),
        PuzzlePiece(correctIndex: 4, content: "🧣", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 5, content: "🧢", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 6, content: "🧦", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 7, content: "🧥", color: const Color(0xFFF1F5F9)),
        PuzzlePiece(correctIndex: 8, content: "🎖️", color: const Color(0xFFFFFBEB)),
      ],
    ),
    PuzzleLevel(
      title: "Dars xonasi 🏫",
      description: "Bizning sevimli sinf xonamiz va o'quv qurollari.",
      pieces: [
        PuzzlePiece(correctIndex: 0, content: "🎒", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 1, content: "✏️", color: const Color(0xFFFEE2E2)),
        PuzzlePiece(correctIndex: 2, content: "📏", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 3, content: "📓", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 4, content: "🖍️", color: const Color(0xFFF3E8FF)),
        PuzzlePiece(correctIndex: 5, content: "🎨", color: const Color(0xFFFFF1F2)),
        PuzzlePiece(correctIndex: 6, content: "📚", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 7, content: "🏫", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 8, content: "🎓", color: const Color(0xFFFFFBEB)),
      ],
    ),
    PuzzleLevel(
      title: "Mevalar dunyosi 🍎",
      description: "Dasturxonimiz ko'rki bo'lgan shirin va foydali mevalar.",
      pieces: [
        PuzzlePiece(correctIndex: 0, content: "🍎", color: const Color(0xFFFEE2E2)),
        PuzzlePiece(correctIndex: 1, content: "🍐", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 2, content: "🍊", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 3, content: "🍋", color: const Color(0xFFFFFBEB)),
        PuzzlePiece(correctIndex: 4, content: "🍌", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 5, content: "🍉", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 6, content: "🍇", color: const Color(0xFFF3E8FF)),
        PuzzlePiece(correctIndex: 7, content: "🍓", color: const Color(0xFFFFF1F2)),
        PuzzlePiece(correctIndex: 8, content: "🍒", color: const Color(0xFFFEE2E2)),
      ],
    ),
    PuzzleLevel(
      title: "Kosmos olami 🚀",
      description: "Sirlarga to'la cheksiz koinot va yulduzlar.",
      pieces: [
        PuzzlePiece(correctIndex: 0, content: "🚀", color: const Color(0xFFE0F2FE)),
        PuzzlePiece(correctIndex: 1, content: "🛸", color: const Color(0xFFF3E8FF)),
        PuzzlePiece(correctIndex: 2, content: "🪐", color: const Color(0xFFFEF3C7)),
        PuzzlePiece(correctIndex: 3, content: "🌙", color: const Color(0xFFFFFBEB)),
        PuzzlePiece(correctIndex: 4, content: "☀️", color: const Color(0xFFFFFBEB)),
        PuzzlePiece(correctIndex: 5, content: "🌟", color: const Color(0xFFFFFBEB)),
        PuzzlePiece(correctIndex: 6, content: "🌍", color: const Color(0xFFECFDF5)),
        PuzzlePiece(correctIndex: 7, content: "☄️", color: const Color(0xFFFEE2E2)),
        PuzzlePiece(correctIndex: 8, content: "🛰️", color: const Color(0xFFF1F5F9)),
      ],
    ),
  ];

  late PuzzleLevel _currentLevel;
  late List<PuzzlePiece> _shuffledPieces;
  int? _selectedPieceIndex;
  bool _finished = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _generateRandomLevel();
  }

  void _generateRandomLevel() {
    final pool = List<PuzzleLevel>.from(_levelsDatabase)..shuffle();
    _currentLevel = pool.first;
    _shuffledPieces = List.from(_currentLevel.pieces)..shuffle();
    _selectedPieceIndex = null;
    _finished = false;
  }

  void _onPieceTap(int index) {
    if (_finished) return;
    setState(() {
      if (_selectedPieceIndex == null) {
        _selectedPieceIndex = index;
      } else {
        // Swap pieces!
        final temp = _shuffledPieces[_selectedPieceIndex!];
        _shuffledPieces[_selectedPieceIndex!] = _shuffledPieces[index];
        _shuffledPieces[index] = temp;
        _selectedPieceIndex = null;
        _checkResult();
      }
    });
  }

  void _checkResult() {
    bool isCorrect = true;
    for (int i = 0; i < _shuffledPieces.length; i++) {
      if (_shuffledPieces[i].correctIndex != i) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        _finished = true;
      });
      _saveScore();
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
        title: Text(
          "Puzzle O'yini",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.blue,
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
          color: Colors.blue,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            children: [
              Text(
                _currentLevel.title,
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Ikki bo'lakni tanlab, o'rinlarini almashtiring. Ularni tartibga keltiring!",
                style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _shuffledPieces.length,
              itemBuilder: (context, index) {
                final piece = _shuffledPieces[index];
                final isSelected = _selectedPieceIndex == index;
                return GestureDetector(
                  onTap: () => _onPieceTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: piece.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.blue.shade100,
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      piece.content,
                      style: GoogleFonts.nunito(fontSize: 36),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
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
              "Puzzleni muvaffaqiyatli yig'dingiz!",
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
                    backgroundColor: Colors.blue,
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
