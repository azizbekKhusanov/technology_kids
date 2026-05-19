import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../core/app_theme.dart';
import '../../models/lesson_model.dart';
import '../lessons/lesson_detail_screen.dart';
import '../lessons/lesson_list_screen.dart';
import '../games/games_screen.dart';
import '../achievements/achievements_screen.dart';
import '../workshop/virtual_workshop_screen.dart';
import '../exhibition/exhibition_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "O'quvchi";
  int _totalXP = 0;
  int _userGrade = 3;
  int _streakCount = 5;
  int _completedLessonsCount = 12;
  int _totalLessonsCount = 30;
  int _unlockedBadgesCount = 5;
  List<QueryDocumentSnapshot> _myArtworks = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _pickAndUploadArtwork() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          bool isUploading = false;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text(
                  "Rasm yuklash",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Ushbu rasmni ko'rgazmaga yuklamoqchimisiz?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: Image.memory(bytes, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ism: $_userName\nSinf: $_userGrade-sinf",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isUploading ? null : () => Navigator.pop(context),
                    child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isUploading
                        ? null
                        : () async {
                            setDialogState(() => isUploading = true);
                            try {
                              await FirebaseFirestore.instance.collection('artworks').add({
                                'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
                                'userName': _userName,
                                'grade': _userGrade,
                                'imageBase64': base64String,
                                'likes': 0,
                                'likedBy': [],
                                'status': 'pending',
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Muvaffaqiyatli yuklandi! Admin tasdiqlaganidan so'ng ko'rgazmada paydo bo'ladi.",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: AppTheme.successColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Yuklashda xatolik: $e"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                );
                              }
                            }
                          },
                    child: isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Yuklash"),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Galereyani ochishda xatolik: $e")),
      );
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        // XP calculations
        final artworks = await FirebaseFirestore.instance.collection('artworks').where('userId', isEqualTo: user.uid).get();
        final myArtworksDocs = artworks.docs;
        
        int totalLikes = 0;
        int artXP = myArtworksDocs.length * 50;
        for (var work in myArtworksDocs) {
          totalLikes += ((work.data()['likes'] ?? 0) as int);
        }
        artXP += totalLikes * 10;

        int dbXP = 0;
        int grade = 3;
        int streak = 5;
        String fetchedName = "O'quvchi";

        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            dbXP = data['xp'] ?? 0;
            grade = data['grade'] ?? 3;
            streak = data['streak'] ?? data['streakCount'] ?? 5;
            final name = data['username'];
            if (name != null && name.toString().isNotEmpty) {
              fetchedName = name.toString();
            }
          }
        }

        int finalXP = dbXP + artXP;

        // Get total lessons count dynamically
        final lessonsSnapshot = await FirebaseFirestore.instance.collection('lessons').get();
        final int totalLessons = lessonsSnapshot.docs.isEmpty ? 30 : lessonsSnapshot.docs.length;

        // Completed lessons count (dynamic calculation based on activity)
        int completedCount = 0;
        if (doc.exists && doc.data()?['completedLessons'] != null) {
          completedCount = (doc.data()?['completedLessons'] as List).length;
        } else {
          completedCount = (myArtworksDocs.length + (finalXP / 30).floor()).clamp(1, totalLessons);
        }

        // Unlocked Badges count calculation (matches Profile screen perfectly!)
        int badges = 0;
        if (myArtworksDocs.isNotEmpty) badges++; // 1. Ilk Qadam
        if (completedCount >= 5) badges++;       // 2. Faol O'quvchi
        if (totalLikes >= 5) badges++;          // 3. Mashhurlik
        if (finalXP >= 200) badges++;           // 4. Kashfiyotchi
        if (myArtworksDocs.length >= 3) badges++; // 5. Rassom
        if (completedCount >= 15) badges++;      // 6. Bilimdon
        if (myArtworksDocs.length >= 10) badges++; // 7. Oltin Qo'llar
        if (totalLikes >= 20) badges++;         // 8. Super Yulduz
        if (finalXP >= 500) badges++;           // 9. Daho
        if (finalXP >= 1000) badges++;          // 10. Tashabbuskor

        if (mounted) {
          setState(() {
            _userName = fetchedName;
            _totalXP = finalXP;
            _userGrade = grade;
            _streakCount = streak;
            _myArtworks = myArtworksDocs;
            _totalLessonsCount = totalLessons;
            _completedLessonsCount = completedCount;
            _unlockedBadgesCount = badges;
          });
        }
      } catch (e) {
        debugPrint("Foydalanuvchi ma'lumotlarini yuklashda xatolik: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('lessons').snapshots(),
          builder: (context, snapshot) {
            List<LessonModel> lessons = [];
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              lessons = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return LessonModel.fromMap(data);
              }).toList();
            }

            // Fallback lesson if no lessons are found in Firestore yet
            final LessonModel currentLesson = lessons.isNotEmpty
                ? lessons[0]
                : LessonModel(
                    id: 'mock_lesson_1',
                    title: "Qog'oz bilan ishlash",
                    description: "Qog'ozdan har xil shakllar va chiroyli narsalar yasashni o'rganamiz.",
                    grade: 3,
                    category: "Origami",
                    thumbnailUrl: "",
                    steps: [
                      StepModel(
                        title: "1-qadam: Material tayyorlash",
                        content: "Kerakli ashyolarni tayyorlab oling.",
                      ),
                    ],
                  );

            final LessonModel todayLesson = lessons.length > 1
                ? lessons[1]
                : currentLesson;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. GREETING + PROFILE CARD
                  _buildGreetingCard(context),
                  const SizedBox(height: 16),

                  // 2. STATS ROW
                  _buildStatsRow(context),
                  const SizedBox(height: 16),

                  // 3. CONTINUE LEARNING CARD
                  _buildContinueLearningCard(context, currentLesson),
                  const SizedBox(height: 16),

                  // 4. QUICK ACCESS GRID (2x2 Grid)
                  _buildQuickAccessGrid(context),
                  const SizedBox(height: 16),

                  // 5. TODAY'S TASK CARD
                  _buildTodayTaskCard(context, todayLesson),
                  const SizedBox(height: 16),

                  // 6. EXHIBITION CARD
                  _buildExhibitionCard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 1. Greeting + Profile Card
  Widget _buildGreetingCard(BuildContext context) {
    // Generate initials based on username
    String initials = "AS";
    if (_userName.isNotEmpty) {
      final parts = _userName.trim().split(' ');
      if (parts.length > 1) {
        initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else if (parts[0].length > 1) {
        initials = "${parts[0][0]}${parts[0][1]}".toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular avatar with initials (e.g. 'AS')
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F77DD), Color(0xFF378ADD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7F77DD).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Greeting + Class Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Salom, $_userName!",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$_userGrade-sinf",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Score + Streak column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Score/points (e.g. '42 ball')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), // Amber background tint
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "$_totalXP ball",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Streak counter (e.g. '🔥 5 kun')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2), // Coral background tint
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEE2E2), width: 1),
                  ),
                  child: Text(
                    "🔥 $_streakCount kun",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. Stats Row (2 metric cards side by side)
  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Card 1: O'tilgan darslar
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Light gray/secondary background
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF7F77DD), // Purple
                          size: 20,
                        ),
                      ),
                      Text(
                        "$_completedLessonsCount / $_totalLessonsCount ta",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "O'tilgan darslar",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Card 2: Yutuqlar
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Light gray/secondary background
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.military_tech_rounded,
                          color: Color(0xFFBA7517), // Amber
                          size: 20,
                        ),
                      ),
                      Text(
                        "$_unlockedBadgesCount nishon",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Yutuqlar",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category icon selector
  IconData _getCategoryIcon(String category) {
    category = category.toLowerCase();
    if (category.contains('qog') || category.contains('origami')) return Icons.content_cut_rounded;
    if (category.contains('loy') || category.contains('plastilin')) return Icons.landscape_rounded;
    if (category.contains('tikish') || category.contains('kiyim')) return Icons.architecture_rounded;
    if (category.contains('rasm') || category.contains('chizish')) return Icons.brush_rounded;
    if (category.contains('tabiat') || category.contains('material')) return Icons.eco_rounded;
    if (category.contains('konstruktor')) return Icons.view_in_ar_rounded;
    return Icons.menu_book_rounded;
  }

  // 3. 'Continue Learning' Card
  Widget _buildContinueLearningCard(BuildContext context, LessonModel lesson) {
    final int totalSteps = lesson.steps.isEmpty ? 5 : lesson.steps.length;
    final int currentStep = (totalSteps * 0.6).round();
    final double progressPercent = totalSteps > 0 ? (currentStep / totalSteps) : 0.6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Davom etish",
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonDetailScreen(lesson: lesson),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Last lesson icon (category icon)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF), // Light purple background
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(lesson.category),
                          color: const Color(0xFF7F77DD), // Purple
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Lesson name + linear progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progressPercent,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7F77DD)),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "$currentStep / $totalSteps bo'lim",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arrow icon on the right
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Quick Access Grid (2x2 grid of category buttons)
  Widget _buildQuickAccessGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tezkor kirish",
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          // 2x2 Custom Row grid
          Row(
            children: [
              // Button 1: Darslar
              Expanded(
                child: _buildGridButton(
                  context: context,
                  label: "Darslar",
                  icon: Icons.school_rounded,
                  backgroundColor: const Color(0xFF7F77DD), // Purple
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LessonListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Button 2: O'yinlar
              Expanded(
                child: _buildGridButton(
                  context: context,
                  label: "O'yinlar",
                  icon: Icons.extension_rounded, // puzzle icon
                  backgroundColor: const Color(0xFF1D9E75), // Teal
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GamesScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Button 3: Yutuqlar
              Expanded(
                child: _buildGridButton(
                  context: context,
                  label: "Yutuqlar",
                  icon: Icons.emoji_events_rounded, // trophy icon
                  backgroundColor: const Color(0xFFBA7517), // Amber
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Button 4: Ustaxona
              Expanded(
                child: _buildGridButton(
                  context: context,
                  label: "Ustaxona",
                  icon: Icons.construction_rounded, // tool icon
                  backgroundColor: const Color(0xFFD85A30), // Coral
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VirtualWorkshopScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Today's Task Card
  Widget _buildTodayTaskCard(BuildContext context, LessonModel lesson) {
    // Check if the user has uploaded artwork matching this lesson title to determine status dynamically!
    final bool isCompleted = _myArtworks.any((art) {
      final data = art.data() as Map<String, dynamic>?;
      if (data == null) return false;
      final String artTitle = (data['title'] ?? '').toString().toLowerCase();
      return artTitle.contains(lesson.title.toLowerCase()) || lesson.title.toLowerCase().contains(artTitle);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bugungi topshiriq",
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFEBF5FF), // Green tint if completed, else blue tint
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isCompleted ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE), width: 1.5),
            ),
            child: Row(
              children: [
                // Clipboard/Check icon on the left
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_box_rounded : Icons.assignment_rounded,
                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF378ADD),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${lesson.category} — ${lesson.title}",
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isCompleted ? const Color(0xFF065F46) : const Color(0xFF1E3A8A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? "Topshiriq bajarilgan 🎉" : "Topshiriq bajarilmagan",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Launch button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? const Color(0xFF10B981) : const Color(0xFF378ADD),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(64, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to details if completed or to workshop if not
                    if (isCompleted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VirtualWorkshopScreen()),
                      );
                    }
                  },
                  child: Text(
                    isCompleted ? "Ko'rish" : "Boshlash",
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Exhibition Card
  Widget _buildExhibitionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ko'rgazma",
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _pickAndUploadArtwork,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Photo icon placeholder
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB), // light amber background
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFEF3C7), width: 2),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded, // placeholder photo icon
                          color: Color(0xFFBA7517), // Amber color
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Ishlaringizni ko'rsating",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rasm yuklash → baholash",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
