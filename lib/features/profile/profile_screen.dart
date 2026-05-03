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
          .orderBy('createdAt', descending: true)
          .get();

      myArtworks = artworksSnapshot.docs;
      
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
    int totalXP = (myArtworks.length * 50) + (totalLikes * 10);
    // Masalan Har 100 XP bitta bosqich (Level) beradi.
    int currentLevel = (totalXP / 100).floor() + 1;
    // Keyingi bosqichgacha to'lish foizi
    double levelProgress = (totalXP % 100) / 100.0;
    
    // Yutuqlar hisobi
    bool badge1Unlocked = myArtworks.isNotEmpty; // Ilk Qadam
    bool badge2Unlocked = totalLikes >= 5;       // Yulduzcha
    bool badge3Unlocked = myArtworks.length >= 3; // Haqiqiy Rassom

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
                  _buildStatCard(totalLikes.toString(), "Yulduzlar", Icons.star_rounded, Colors.orange),
                  const SizedBox(width: 10),
                  _buildStatCard(myArtworks.length.toString(), "Ijod", Icons.brush_rounded, AppTheme.accentColor),
                  const SizedBox(width: 10),
                  _buildStatCard("$totalXP", "Ball", Icons.bolt_rounded, Colors.blue),
                ],
              ),
            ),
          ),

          // 2.5 NISHONLAR (BADGES)
          SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Text("Mening Nishonlarim 🏅", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadge("Ilk Qadam", Icons.rocket_launch, Colors.purple, badge1Unlocked),
                        _buildBadge("Mashxurlik", Icons.verified, Colors.blue, badge2Unlocked),
                        _buildBadge("Ijodkor", Icons.palette, Colors.pink, badge3Unlocked),
                      ],
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
                  _buildMenuTile(context, "Ilova Haqida", Icons.info_outline, Colors.grey, (){}),
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

  Widget _buildBadge(String title, IconData icon, Color color, bool unlocked) {
     return Column(
        children: [
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: unlocked ? color.withOpacity(0.15) : Colors.grey.shade200,
               shape: BoxShape.circle,
               border: Border.all(color: unlocked ? color : Colors.grey.shade300, width: 3)
             ),
             child: Icon(unlocked ? icon : Icons.lock_outline, color: unlocked ? color : Colors.grey.shade400, size: 30),
           ),
           const SizedBox(height: 8),
           Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: unlocked ? Colors.black87 : Colors.grey)),
           if(!unlocked) 
             Text("Yopiq", style: TextStyle(color: Colors.grey.shade500, fontSize: 10))
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
