import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'dart:convert';
import '../workshop/drawing_models.dart';

import '../../main.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  Map<String, dynamic>? userData;
  List<QueryDocumentSnapshot> myArtworks = [];
  int totalLikes = 0;
  bool isLoading = true;
  
  // Emojilar to'plami (Avatar almashtirish uchun)
  final List<String> _avatars = [
    '🐶', '🐱', '🦊', '🐻', '🐼', '🐯', '🦁', '🐮',
    '🐷', '🐸', '🐵', '🐔', '🐧', '🦉', '🦄', '🦖',
    '🐕', '🐈', '🐆', '🦓', '🦒', '🦘', '🐴', '🐑',
    '🐐', '🦅', '🦆', '🐢', '🐙', '🦕', '🐝', '🦋'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (currentUser == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if(doc.exists) {
        userData = doc.data();
      }

      final artworksSnapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('userId', isEqualTo: currentUser!.uid)
          .get();

      myArtworks = artworksSnapshot.docs;
      myArtworks.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final t1 = dataA['createdAt'] as Timestamp?;
        final t2 = dataB['createdAt'] as Timestamp?;
        if (t1 == null && t2 == null) return 0;
        if (t1 == null) return 1;
        if (t2 == null) return -1;
        return t2.compareTo(t1);
      });
      
      totalLikes = 0;
      for(var work in myArtworks) {
        final data = work.data() as Map<String, dynamic>;
        totalLikes += (data['likes'] ?? 0) as int;
      }
      
    } catch(e) {
      debugPrint("Profil yuklashda xatolik: $e");
    } finally {
      if(mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateAvatar(String newEmoji) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'avatar': newEmoji
      });
      setState(() {
        userData?['avatar'] = newEmoji;
      });
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ajoyib, qahramoningiz o'zgardi! 🎭", style: TextStyle(fontWeight: FontWeight.bold))));
      }
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              const Text("Yangi qahramonga aylaning!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
                  itemCount: _avatars.length,
                  itemBuilder: (ctx, i) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _updateAvatar(_avatars[i]);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        child: Text(_avatars[i], style: const TextStyle(fontSize: 35)),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tizimdan chiqish"),
        content: const Text("Haqiqatan ham hisobingizdan chiqmoqchimisiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Yo'q", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthWrapper()), (r) => false);
              }
            }, 
            child: const Text("Ha, chiqish")
          )
        ],
      )
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8FF), // Light purple
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF7F77DD), // Purple
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Texno Bilim",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "Versiya 1.0.0",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Texno Bilim — boshlang'ich sinf (1-4 sinflar) o'quvchilari uchun texnologiya fanini qiziqarli, o'yinlar va amaliy topshiriqlar orqali o'rganishga mo'ljallangan mobil ilovadir. ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.menu_book_rounded, "Qiziqarli interaktiv darslar", const Color(0xFF7F77DD)),
              _buildFeatureRow(Icons.extension_rounded, "Bilimni mustahkamlovchi o'yinlar", const Color(0xFF1D9E75)),
              _buildFeatureRow(Icons.construction_rounded, "Virtual rasm chizish ustaxonasi", const Color(0xFFD85A30)),
              _buildFeatureRow(Icons.emoji_events_rounded, "Nishonlar va faollik darajalari", const Color(0xFFBA7517)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F77DD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Tushunarli",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }


  List<Widget> _getBadgesList(int totalXP, int completedLessons) {
    return [
      _build1FitBadge(title: "Ilk Qadam", current: myArtworks.length, target: 1, icon: Icons.rocket_launch, colors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)]),
      _build1FitBadge(title: "Faol O'quvchi", current: completedLessons, target: 5, icon: Icons.school_rounded, colors: [const Color(0xFF36D1DC), const Color(0xFF5B86E5)]),
      _build1FitBadge(title: "Mashhurlik", current: totalLikes, target: 5, icon: Icons.star_rounded, colors: [const Color(0xFFFFD700), const Color(0xFFF7971E)]),
      _build1FitBadge(title: "Kashfiyotchi", current: totalXP, target: 200, icon: Icons.explore_rounded, colors: [const Color(0xFF1D976C), const Color(0xFF93F9B9)]),
      _build1FitBadge(title: "Rassom", current: myArtworks.length, target: 3, icon: Icons.palette, colors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]),
      _build1FitBadge(title: "Bilimdon", current: completedLessons, target: 15, icon: Icons.emoji_events_rounded, colors: [const Color(0xFFF09819), const Color(0xFFEDDE5D)]),
      _build1FitBadge(title: "Oltin Qo'llar", current: myArtworks.length, target: 10, icon: Icons.back_hand, colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)]),
      _build1FitBadge(title: "Super Yulduz", current: totalLikes, target: 20, icon: Icons.local_fire_department, colors: [const Color(0xFFf12711), const Color(0xFFf5af19)]),
      _build1FitBadge(title: "Daho", current: totalXP, target: 500, icon: Icons.psychology, colors: [const Color(0xFF00c6ff), const Color(0xFF0072ff)]),
      _build1FitBadge(title: "Tashabbuskor", current: totalXP, target: 1000, icon: Icons.bolt, colors: [const Color(0xFFf857a6), const Color(0xFFff5858)]),
    ];
  }

  void _showAllBadges(BuildContext context, int totalXP, int completedLessons) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              const Text("Barcha Yutuqlar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.68,
                  children: _getBadgesList(totalXP, completedLessons),
                )
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String name = userData?['username'] ?? "O'quvchi";
    int grade = userData?['grade'] ?? 1;
    String avatarStr = userData?['avatar'] ?? "🐶";
    if(avatarStr.length > 5) avatarStr = "🐨";

    // --- GAMEIFICATION HISOB-KITOBI ---
    // Har bir rasm uchun 50 XP, Har layk uchun 10 XP.
    int dbXP = userData?['xp'] ?? 0;
    int totalXP = dbXP + (myArtworks.length * 50) + (totalLikes * 10);
    // Masalan Har 100 XP bitta bosqich (Level) beradi.
    int currentLevel = (totalXP / 100).floor() + 1;
    // Keyingi bosqichgacha to'lish foizi
    double levelProgress = (totalXP % 100) / 100.0;
    
    // Yutuqlar hisobi
    int completedLessons = 0;
    if (userData?['completedLessons'] != null) {
      completedLessons = (userData?['completedLessons'] as List).length;
    } else {
      completedLessons = (myArtworks.length + (totalXP / 30).floor()).clamp(1, 30);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. Qahramon (Header)
          SliverAppBar(
            expandedHeight: 280, // Biroz kattalashdi progress uchun
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // LEVEL VA AVATAR PROGRESSI
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130, height: 130,
                          child: CircularProgressIndicator(
                            value: levelProgress,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            color: Colors.amber,
                            strokeWidth: 8,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(avatarStr, style: const TextStyle(fontSize: 50)),
                          ),
                        ),
                        // LEVEL NISHONI
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)]
                            ),
                            child: Text("LEVEL $currentLevel", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("$grade-sinf | $totalXP Ball", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          
          // 2. Yutuqlar (Stats) Qutisi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  _buildStatCard(totalLikes.toString(), "Layklar", Icons.favorite_rounded, Colors.red),
                  const SizedBox(width: 10),
                  _buildStatCard(myArtworks.length.toString(), "Ijod", Icons.brush_rounded, AppTheme.accentColor),
                  const SizedBox(width: 10),
                  _buildStatCard("$totalXP", "Ball", Icons.star_rounded, Colors.amber),
                ],
              ),
            ),
          ),

          // 2.5 NISHONLAR (BADGES) - 1Fit dizayni asosida (Oq fon)
          SliverToBoxAdapter(
             child: Container(
               margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: [
                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                 ]
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Yutuqlar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        GestureDetector(
                          onTap: () => _showAllBadges(context, totalXP, completedLessons),
                          child: Row(
                            children: [
                              Text("Barchasi ", style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w600, fontSize: 14)),
                              Icon(Icons.chevron_right, color: Colors.blue.shade600, size: 20),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _getBadgesList(totalXP, completedLessons).map((badgeWidget) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: badgeWidget,
                        )).toList(),
                      )
                    )
                 ],
               ),
             ),
          ),

          // 3. Mening Ijodlarim (Portfolio)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mening Ijodlarim 🎨", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (myArtworks.isEmpty)
                     Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text("Sizda hali tasdiqlangan asarlar yo'q.\nUstaxonada ijod qiling va nishonlarni oching!", 
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                      ),
                    )
                  else
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: myArtworks.length,
                      itemBuilder: (ctx, i) {
                        final data = myArtworks[i].data() as Map<String, dynamic>;
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: data['bgColor'] != null ? Color(data['bgColor']) : Colors.white,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: 400, height: 480,
                                      child: _buildArtworkRenderer(data),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.orange, size: 14),
                                        const SizedBox(width: 4),
                                        Text("${data['likes'] ?? 0}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                if (data['status'] == 'pending')
                                  Positioned(
                                    top: 8, left: 8,
                                    child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5)),
                                    child: const Text("Kutilyapti", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),

          // 4. Boshqa Sozlamalar va Chiqish
          SliverToBoxAdapter(
            child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sozlamalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMenuTile(context, "Qahramonni (Avatarni) O'zgartirish", Icons.pets, Colors.indigo, _showAvatarPicker),
                  _buildMenuTile(context, "Ilova Haqida", Icons.info_outline, Colors.grey, _showAboutAppDialog),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                      onPressed: _logout, 
                      icon: const Icon(Icons.logout), 
                      label: const Text("Tizimdan chiqish", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _build1FitBadge({
    required String title,
    required int current,
    required int target,
    required IconData icon,
    required List<Color> colors,
  }) {
    bool unlocked = current >= target;
    double progress = current / target;
    if (progress > 1.0) progress = 1.0;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unlocked 
              ? LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
            color: unlocked ? null : Colors.grey.shade100,
            border: Border.all(
              color: unlocked ? Colors.amber.withOpacity(0.8) : Colors.grey.shade300, 
              width: unlocked ? 3 : 2
            ),
            boxShadow: unlocked ? [
              BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 12, spreadRadius: 2)
            ] : null,
          ),
          child: Center(
            child: Icon(
              icon, 
              color: unlocked ? Colors.white : Colors.grey.shade400, 
              size: 40
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 90,
          child: Text(
            title, 
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12, 
              color: unlocked ? Colors.black87 : Colors.grey.shade600
            )
          ),
        ),
        if (!unlocked) ...[
          const SizedBox(height: 4),
          Text(
            "$current / $target", 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)
          )
        ]
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

   Widget _buildArtworkRenderer(Map<String, dynamic> data) {
    List<DrawingPoint?> points = [];
    if(data['pointsData'] != null) {
      List<dynamic> rawPoints = jsonDecode(data['pointsData']);
      for(var p in rawPoints) {
         if(p['isNull'] == true) { points.add(null); } 
         else { points.add(DrawingPoint(Offset(p['dx'].toDouble(), p['dy'].toDouble()), Paint()..color = Color(p['color'])..strokeWidth = p['width'].toDouble()..strokeCap = StrokeCap.round));}
      }
    }
    List<StickerNode> stickers = [];
    if(data['stickersData'] != null) {
      List<dynamic> rawStickers = jsonDecode(data['stickersData']);
      for(var s in rawStickers) { stickers.add(StickerNode(emoji: s['emoji'], offset: Offset(s['dx'].toDouble(), s['dy'].toDouble()), scale: s['scale'].toDouble(), rotation: s['rotation'].toDouble()));}
    }
    String? base64img = data['imageBase64'];
    return Stack(
      children: [
        if (base64img != null) Positioned.fill(child: Opacity(opacity: 0.9, child: Image.memory(base64Decode(base64img), fit: BoxFit.contain))),
        CustomPaint(painter: DrawingPainter(pointsList: points), child: Container()),
        ...stickers.map((s) => Positioned(left: s.offset.dx, top: s.offset.dy, child: Transform.rotate(angle: s.rotation, child: Transform.scale(scale: s.scale, child: Text(s.emoji, style: const TextStyle(fontSize: 50, decoration: TextDecoration.none))))))
      ],
    );
  }
}
