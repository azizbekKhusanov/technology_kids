import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _totalXP = 0;
  int _completedLessons = 0;
  int _artworksCount = 0;
  int _totalLikes = 0;
  int _unlockedBadgesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievementsData();
  }

  Future<void> _loadAchievementsData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final artworks = await FirebaseFirestore.instance.collection('artworks').where('userId', isEqualTo: user.uid).get();
      
      int totalLikes = 0;
      int artXP = artworks.docs.length * 50;
      for (var work in artworks.docs) {
        totalLikes += ((work.data()['likes'] ?? 0) as int);
      }
      artXP += totalLikes * 10;

      int dbXP = 0;
      int completedLessons = 0;

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          dbXP = data['xp'] ?? 0;
          if (data['completedLessons'] != null) {
            completedLessons = (data['completedLessons'] as List).length;
          }
        }
      }

      int finalXP = dbXP + artXP;
      if (completedLessons == 0) {
        completedLessons = (artworks.docs.length + (finalXP / 30).floor()).clamp(1, 30);
      }

      // Calculate badges matching profile!
      int badges = 0;
      if (artworks.docs.isNotEmpty) badges++; // 1. Ilk Qadam
      if (completedLessons >= 5) badges++;     // 2. Faol O'quvchi
      if (totalLikes >= 5) badges++;          // 3. Mashhurlik
      if (finalXP >= 200) badges++;           // 4. Kashfiyotchi
      if (artworks.docs.length >= 3) badges++; // 5. Rassom
      if (completedLessons >= 15) badges++;    // 6. Bilimdon
      if (artworks.docs.length >= 10) badges++; // 7. Oltin Qo'llar
      if (totalLikes >= 20) badges++;         // 8. Super Yulduz
      if (finalXP >= 500) badges++;           // 9. Daho
      if (finalXP >= 1000) badges++;          // 10. Tashabbuskor

      if (mounted) {
        setState(() {
          _totalXP = finalXP;
          _completedLessons = completedLessons;
          _artworksCount = artworks.docs.length;
          _totalLikes = totalLikes;
          _unlockedBadgesCount = badges;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Yutuqlarni yuklashda xatolik: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Map<String, dynamic>> badges = [
      {
        'title': 'Ilk Qadam',
        'description': 'Ijod olamiga ilk qadam (1 ta rasm chizish)',
        'icon': Icons.rocket_launch,
        'colors': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
        'current': _artworksCount,
        'target': 1,
        'earned': _artworksCount >= 1,
      },
      {
        'title': 'Faol O\'quvchi',
        'description': '5 ta darsni muvaffaqiyatli o\'rgandingiz',
        'icon': Icons.school_rounded,
        'colors': [const Color(0xFF36D1DC), const Color(0xFF5B86E5)],
        'current': _completedLessons,
        'target': 5,
        'earned': _completedLessons >= 5,
      },
      {
        'title': 'Mashhurlik',
        'description': 'Ijodiy ishingiz 5 ta layk oldi',
        'icon': Icons.star_rounded,
        'colors': [const Color(0xFFFFD700), const Color(0xFFF7971E)],
        'current': _totalLikes,
        'target': 5,
        'earned': _totalLikes >= 5,
      },
      {
        'title': 'Kashfiyotchi',
        'description': 'Koinot va texnologiyalarni o\'rganib 200 ball to\'pladingiz',
        'icon': Icons.explore_rounded,
        'colors': [const Color(0xFF1D976C), const Color(0xFF93F9B9)],
        'current': _totalXP,
        'target': 200,
        'earned': _totalXP >= 200,
      },
      {
        'title': 'Rassom',
        'description': '3 ta ajoyib ijodiy ish yaratdingiz',
        'icon': Icons.palette,
        'colors': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
        'current': _artworksCount,
        'target': 3,
        'earned': _artworksCount >= 3,
      },
      {
        'title': 'Bilimdon',
        'description': '15 ta darsni muvaffaqiyatli o\'rgandingiz',
        'icon': Icons.emoji_events_rounded,
        'colors': [const Color(0xFFF09819), const Color(0xFFEDDE5D)],
        'current': _completedLessons,
        'target': 15,
        'earned': _completedLessons >= 15,
      },
      {
        'title': 'Oltin Qo\'llar',
        'description': '10 ta ajoyib ijodiy ish yaratdingiz',
        'icon': Icons.back_hand,
        'colors': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
        'current': _artworksCount,
        'target': 10,
        'earned': _artworksCount >= 10,
      },
      {
        'title': 'Super Yulduz',
        'description': 'Ijodiy ishingiz 20 ta layk oldi',
        'icon': Icons.local_fire_department,
        'colors': [const Color(0xFFF12711), const Color(0xFFF5AF19)],
        'current': _totalLikes,
        'target': 20,
        'earned': _totalLikes >= 20,
      },
      {
        'title': 'Daho',
        'description': '500 balldan oshiq marraga yetdingiz',
        'icon': Icons.psychology,
        'colors': [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
        'current': _totalXP,
        'target': 500,
        'earned': _totalXP >= 500,
      },
      {
        'title': 'Tashabbuskor',
        'description': 'Loyiha bo\'ylab faollik ko\'rsatib 1000 ball to\'pladingiz',
        'icon': Icons.bolt,
        'colors': [const Color(0xFFF857A6), const Color(0xFFFF5858)],
        'current': _totalXP,
        'target': 1000,
        'earned': _totalXP >= 1000,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Mening Yutuqlarim",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFBA7517),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stars summary (Completely dynamic!)
          Container(
            width: double.infinity,
            color: const Color(0xFFBA7517),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("$_totalXP", "Ball", Icons.star_rounded, Colors.amber),
                _buildStatItem("$_unlockedBadgesCount", "Nishon", Icons.military_tech_rounded, Colors.white),
                _buildStatItem("$_completedLessons", "Dars", Icons.auto_stories_rounded, Colors.lightBlue[100]!),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Barcha nishonlar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final colors = badge['colors'] as List<Color>;
                final earned = badge['earned'] as bool;
                final current = badge['current'] as int;
                final target = badge['target'] as int;
                double progress = current / target;
                if (progress > 1.0) progress = 1.0;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: earned ? Colors.amber.withOpacity(0.4) : Colors.grey.shade200,
                      width: earned ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: earned 
                            ? LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)
                            : null,
                          color: earned ? null : Colors.grey.shade100,
                        ),
                        child: Icon(
                          badge['icon'] as IconData,
                          size: 32,
                          color: earned ? Colors.white : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        badge['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: earned ? Colors.black87 : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          badge['description'] as String,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!earned) ...[
                        Text(
                          "$current / $target",
                          style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors[0],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Bajarildi",
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
        ),
      ],
    );
  }
}
