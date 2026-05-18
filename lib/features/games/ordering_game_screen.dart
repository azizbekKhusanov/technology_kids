import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class OrderingStep {
  final int correctIndex;
  final String text;

  OrderingStep({
    required this.correctIndex,
    required this.text,
  });
}

class OrderingLevel {
  final String title;
  final String description;
  final List<OrderingStep> steps;

  OrderingLevel({
    required this.title,
    required this.description,
    required this.steps,
  });
}

class OrderingGameScreen extends StatefulWidget {
  const OrderingGameScreen({super.key});

  @override
  State<OrderingGameScreen> createState() => _OrderingGameScreenState();
}

class _OrderingGameScreenState extends State<OrderingGameScreen> {
  static final List<OrderingLevel> _levelsDatabase = [
    OrderingLevel(
      title: "Origami samolyot yasash ✈️",
      description: "Qog'ozdan ajoyib uchar samolyot yasash tartibi.",
      steps: [
        OrderingStep(correctIndex: 0, text: "Qog'oz varog'ini tayyorlab oling 📄"),
        OrderingStep(correctIndex: 1, text: "Varqani o'rtasidan teng qilib buklang 📐"),
        OrderingStep(correctIndex: 2, text: "Burchaklarini ichkariga buklab uchburchak hosil qiling 🔺"),
        OrderingStep(correctIndex: 3, text: "Qanotlarini ochib samolyot shaklini bering ✈️"),
      ],
    ),
    OrderingLevel(
      title: "Loydan qushcha yasash 🐦",
      description: "Plastilin yoki loydan yoqimtoy qushcha shaklini yaratish.",
      steps: [
        OrderingStep(correctIndex: 0, text: "Loyni biroz suv bilan namlab yumshating 💧"),
        OrderingStep(correctIndex: 1, text: "Bosh va tana qismlarini yumaloq qilib oling 🪵"),
        OrderingStep(correctIndex: 2, text: "Loy pichog'i (stek) bilan patlarini chizing 🔪"),
        OrderingStep(correctIndex: 3, text: "Quriganidan so'ng yorqin ranglarga bo'yang 🎨"),
      ],
    ),
    OrderingLevel(
      title: "Tugma qadash ketma-ketligi 🧵",
      description: "Kiyimga tugma qadash amaliyotining bosqichlari.",
      steps: [
        OrderingStep(correctIndex: 0, text: "Ipni igna teshigidan o'tkazib tugun hosil qiling 🪡"),
        OrderingStep(correctIndex: 1, text: "Tugmani mato ustiga mo'ljallangan joyga qo'ying 🔘"),
        OrderingStep(correctIndex: 2, text: "Ignani mato va tugma teshiklaridan bir necha bor o'tkazing 🧵"),
        OrderingStep(correctIndex: 3, text: "Matoning ostidan tugun tugib ortiqcha ipni kesing ✂️"),
      ],
    ),
    OrderingLevel(
      title: "Qog'ozdan gul yasash 🌸",
      description: "Rangli qog'oz va kartonlardan chiroyli bahor guli yasash.",
      steps: [
        OrderingStep(correctIndex: 0, text: "Rangli qog'ozdan gulbarg shakllarini kesib oling ✂️"),
        OrderingStep(correctIndex: 1, text: "Gulbarglarni yelim yordamida bir-biriga yopishtiring 🧪"),
        OrderingStep(correctIndex: 2, text: "Gul markaziga sariq dumaloq qog'oz yopishtiring 🟡"),
        OrderingStep(correctIndex: 3, text: "Gulni yashil poyaga mahkamlab qo'ying 🌿"),
      ],
    ),
    OrderingLevel(
      title: "Yog'och quticha yasash 📦",
      description: "Oddiy yog'och taxtachalardan mayda buyumlar qutisini yasash.",
      steps: [
        OrderingStep(correctIndex: 0, text: "Yog'och taxtalarni o'lchab chizib oling 📏"),
        OrderingStep(correctIndex: 1, text: "Arra yordamida taxtalarni kesib chiqing 🪚"),
        OrderingStep(correctIndex: 2, text: "Bo'laklarni mix va yelim yordamida birlashtiring 🔨"),
        OrderingStep(correctIndex: 3, text: "Quticha yuzasini sumbada qog'ozda silliqlang 🪵"),
      ],
    ),
    OrderingLevel(
      title: "Mato yamoq solish 🩹",
      description: "Matoni tikish va bezash asosidagi yamoq ishlari.",
      steps: [
        OrderingStep(correctIndex: 0, text: "Yirtilgan joy o'lchamiga mos yamoq mato kesib oling ✂️"),
        OrderingStep(correctIndex: 1, text: "Yamoqni yirtilgan joy ustiga tekis joylashtiring 🧵"),
        OrderingStep(correctIndex: 2, text: "Igna va ip yordamida chetlarini tikib chiqing 🪡"),
        OrderingStep(correctIndex: 3, text: "Tikuv choklarini tekshirib, ipni mahkam bog'lang 🎀"),
      ],
    ),
  ];

  late OrderingLevel _currentLevel;
  late List<OrderingStep> _shuffledSteps;
  bool _finished = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateRandomLevel();
  }

  void _generateRandomLevel() {
    final pool = List<OrderingLevel>.from(_levelsDatabase)..shuffle();
    _currentLevel = pool.first;
    _shuffledSteps = List.from(_currentLevel.steps)..shuffle();
    _finished = false;
    _errorMessage = null;
  }

  void _verifyOrder() {
    bool isCorrect = true;
    for (int i = 0; i < _shuffledSteps.length; i++) {
      if (_shuffledSteps[i].correctIndex != i) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        _finished = true;
        _errorMessage = null;
      });
      _saveScore();
    } else {
      setState(() {
        _errorMessage = "Tartib noto'g'ri, qayta urinib ko'ring! 🧐";
      });
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
          "Tartiblash",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.orange,
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
          color: Colors.orange,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            children: [
              Text(
                _currentLevel.title,
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Bosqichlarni to'g'ri ketma-ketlikda tartiblang!",
                style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.nunito(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final OrderingStep item = _shuffledSteps.removeAt(oldIndex);
                  _shuffledSteps.insert(newIndex, item);
                });
              },
              children: List.generate(_shuffledSteps.length, (index) {
                final step = _shuffledSteps[index];
                return Card(
                  key: ValueKey(step.correctIndex),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(
                        "${index + 1}",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: Colors.orange),
                      ),
                    ),
                    title: Text(
                      step.text,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    trailing: const Icon(Icons.drag_handle_rounded, color: Colors.grey),
                  ),
                );
              }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _verifyOrder,
              child: Text(
                "Tekshirish ✅",
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900),
              ),
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
              "Barcha bosqichlarni to'g'ri joylashtirdingiz!",
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
                    backgroundColor: Colors.orange,
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
