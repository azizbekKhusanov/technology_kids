import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class WordLevel {
  final String word;
  final String hint;
  final String category;

  WordLevel({
    required this.word,
    required this.hint,
    required this.category,
  });
}

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  // Massive database of 15 technology terms!
  static final List<WordLevel> _levelsDatabase = [
    WordLevel(
      word: "ORIGAMI",
      hint: "Qog'ozni buklab har xil shakllar yasash san'ati 📄",
      category: "Qog'oz ishlari",
    ),
    WordLevel(
      word: "PLASTILIN",
      hint: "Loydan shakl yasash uchun bolalarning eng sevimli yumshoq materiali 🪵",
      category: "Loy ishlari",
    ),
    WordLevel(
      word: "ANDOZA",
      hint: "Kiyim bichish va kesish uchun tayyor qog'oz shakl-namuna 📐",
      category: "Tikuvchilik",
    ),
    WordLevel(
      word: "QAYCHI",
      hint: "Mato yoki qog'ozlarni kesishda eng ko'p ishlatiladigan asosiy asbob ✂️",
      category: "Asboblar",
    ),
    WordLevel(
      word: "TEXNOLOGIYA",
      hint: "Bizning sevimli, turli hunarlar va ijod o'rgatuvchi fanimiz! 🏆",
      category: "Umumiy",
    ),
    WordLevel(
      word: "TUGMA",
      hint: "Kiyimlarni ilintirish va bezash uchun ishlatiladigan dumaloq buyum 🔘",
      category: "Tikuvchilik",
    ),
    WordLevel(
      word: "YELIM",
      hint: "Qog'oz va kartonlarni bir-biriga yopishtiruvchi suyuq modda 🧪",
      category: "Materiallar",
    ),
    WordLevel(
      word: "ARRA",
      hint: "Yog'och taxtalarni bo'laklash uchun ishlatiladigan tishli asbob 🪚",
      category: "Asboblar",
    ),
    WordLevel(
      word: "BOLG'A",
      hint: "Mixlarni taxtaga qoqish uchun ishlatiladigan og'ir ish quroli 🔨",
      category: "Asboblar",
    ),
    WordLevel(
      word: "RANDA",
      hint: "Yog'och yuzasini tekislash va silliqlash asbobi 🪓",
      category: "Duradgorlik",
    ),
    WordLevel(
      word: "IP",
      hint: "Ignaga o'tkazib matolarni tikishda foydalaniladigan tola 🧵",
      category: "Tikuvchilik",
    ),
    WordLevel(
      word: "LOYLAR",
      hint: "Tabiiy material bo'lib, undan turli idishlar va o'yinchoqlar yasaladi 🏺",
      category: "Materiallar",
    ),
    WordLevel(
      word: "CHIZG'ICH",
      hint: "To'g'ri chiziq chizish va o'lchamlarni aniqlash asbobi 📏",
      category: "O'lchash",
    ),
    WordLevel(
      word: "QALAM",
      hint: "Qog'ozga shakllar va andozalarni chizish uchun ish quroli ✏️",
      category: "Chizmachilik",
    ),
    WordLevel(
      word: "KARTON",
      hint: "Qog'ozdan ko'ra qalin va qattiqroq bo'lgan material 📦",
      category: "Materiallar",
    ),
  ];

  late WordLevel _currentLevel;
  late List<String> _shuffledLetters;
  final List<String> _selectedLetters = [];
  bool _finished = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateRandomLevel();
  }

  void _generateRandomLevel() {
    final pool = List<WordLevel>.from(_levelsDatabase)..shuffle();
    _currentLevel = pool.first;
    _shuffledLetters = _currentLevel.word.split('')..shuffle();
    _selectedLetters.clear();
    _finished = false;
    _errorMessage = null;
  }

  void _onLetterTap(int index, String letter) {
    if (_finished) return;
    setState(() {
      _selectedLetters.add(letter);
      _shuffledLetters.removeAt(index);
      _errorMessage = null;
      _checkResult();
    });
  }

  void _onSelectedLetterTap(int index, String letter) {
    if (_finished) return;
    setState(() {
      _selectedLetters.removeAt(index);
      _shuffledLetters.add(letter);
      _errorMessage = null;
    });
  }

  void _checkResult() {
    if (_shuffledLetters.isEmpty) {
      final currentWord = _selectedLetters.join('');
      if (currentWord == _currentLevel.word) {
        setState(() {
          _finished = true;
        });
        _saveScore();
      } else {
        setState(() {
          _errorMessage = "Noto'g'ri so'z, harflarni qaytadan joylashtiring! 🧐";
        });
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

  void _reset() {
    setState(() {
      _shuffledLetters = _currentLevel.word.split('')..shuffle();
      _selectedLetters.clear();
      _finished = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "So'zlar o'yini",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _finished
          ? _buildFinishedScreen()
          : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.red,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Text(
            "Berilgan harflardan yashiringan atamani to'g'ri yig'ing!",
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        // Hint card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                "Yordamchi ma'lumot 💡",
                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.red.shade800),
              ),
              const SizedBox(height: 8),
              Text(
                _currentLevel.hint,
                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        const Spacer(),
        // Selected letters slots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_currentLevel.word.length, (index) {
              final hasLetter = index < _selectedLetters.length;
              return GestureDetector(
                onTap: hasLetter ? () => _onSelectedLetterTap(index, _selectedLetters[index]) : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasLetter ? Colors.red.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasLetter ? Colors.red : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hasLetter ? _selectedLetters[index] : "",
                    style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                ),
              );
            }),
          ),
        ),
        const Spacer(),
        // Shuffled pool
        Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_shuffledLetters.length, (index) {
              final letter = _shuffledLetters[index];
              return GestureDetector(
                onTap: () => _onLetterTap(index, letter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Text(
                    letter,
                    style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        if (_selectedLetters.isNotEmpty)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
            label: Text("Qayta boshlash", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        const Spacer(),
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
              "To'g'ri so'zni yig'dingiz: ${_currentLevel.word}",
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
                    backgroundColor: Colors.red,
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
