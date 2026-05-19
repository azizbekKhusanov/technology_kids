import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_theme.dart';

class AdminDashboardTab extends StatefulWidget {
  final void Function(int, {int? subIndex})? onNavigate;

  const AdminDashboardTab({super.key, this.onNavigate});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  int totalUsers = 0;
  int totalArtworks = 0;
  int pendingArtworks = 0;
  int totalLessons = 0;
  List<Map<String, dynamic>> topStudents = [];
  List<Map<String, dynamic>> recentArtworks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);
    try {
      // 1. Fetch counts & documents
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
          
      final artworksSnapshot = await FirebaseFirestore.instance.collection('artworks').get();
      final lessonsSnapshot = await FirebaseFirestore.instance.collection('lessons').count().get();

      // 2. Calculate stats
      final Map<String, int> artworksCountMap = {};
      final Map<String, int> totalLikesMap = {};
      int pendingCount = 0;

      for (var doc in artworksSnapshot.docs) {
        final data = doc.data();
        final uId = data['userId'] as String?;
        final status = data['status'] as String?;
        if (status == 'pending') {
          pendingCount++;
        }
        if (uId == null) continue;
        artworksCountMap[uId] = (artworksCountMap[uId] ?? 0) + 1;
        totalLikesMap[uId] = (totalLikesMap[uId] ?? 0) + ((data['likes'] ?? 0) as int);
      }

      // 3. Process students XP and sort
      List<Map<String, dynamic>> processedStudents = [];
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final uid = doc.id;
        final dbXP = data['xp'] ?? 0;
        final artworksCount = artworksCountMap[uid] ?? 0;
        final totalLikes = totalLikesMap[uid] ?? 0;
        final calculatedXP = dbXP + (artworksCount * 50) + (totalLikes * 10);

        data['uid'] = uid;
        data['calculated_xp'] = calculatedXP;
        processedStudents.add(data);
      }

      processedStudents.sort((a, b) => (b['calculated_xp'] as int).compareTo(a['calculated_xp'] as int));

      // 4. Process recent artworks (sort by createdAt)
      List<Map<String, dynamic>> processedArtworks = artworksSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      processedArtworks.sort((a, b) {
        final t1 = a['createdAt'] as Timestamp?;
        final t2 = b['createdAt'] as Timestamp?;
        if (t1 == null && t2 == null) return 0;
        if (t1 == null) return 1;
        if (t2 == null) return -1;
        return t2.compareTo(t1);
      });

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        totalArtworks = artworksSnapshot.docs.length;
        pendingArtworks = pendingCount;
        totalLessons = lessonsSnapshot.count ?? 0;
        topStudents = processedStudents.take(3).toList();
        recentArtworks = processedArtworks.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Statistika yuklashda xatolik: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    const indigoColor = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 — Header card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: indigoColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bosh sahifa",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Texno Bilim Boshqaruv Paneli",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _loadStatistics,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: indigoColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Tizim faol",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2 — Stats grid
            const Text(
              "Umumiy ko'rsatkichlar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMetricCard(
                  label: "O'quvchilar",
                  value: totalUsers,
                  icon: Icons.people_alt_rounded,
                  color: Colors.blue,
                  onTap: () => widget.onNavigate?.call(1),
                ),
                _buildMetricCard(
                  label: "Darslar",
                  value: totalLessons,
                  icon: Icons.menu_book_rounded,
                  color: Colors.purple,
                  onTap: () => widget.onNavigate?.call(2),
                ),
                _buildMetricCard(
                  label: "Ko'rgazma",
                  value: totalArtworks,
                  icon: Icons.collections_rounded,
                  color: Colors.green,
                  onTap: () => widget.onNavigate?.call(3, subIndex: 1),
                ),
                _buildMetricCard(
                  label: "Kutilmoqda",
                  value: pendingArtworks,
                  icon: Icons.hourglass_top_rounded,
                  color: Colors.orange,
                  onTap: () => widget.onNavigate?.call(3, subIndex: 0),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // DYNAMIC ADDITION 1: Top 3 Students Leaderboard Preview
            if (topStudents.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "Faol o'quvchilar (Top 3)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => widget.onNavigate?.call(1),
                    child: const Text("Barchasi", style: TextStyle(color: indigoColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: List.generate(topStudents.length, (index) {
                    final student = topStudents[index];
                    final String name = student['username'] ?? "Noma'lum";
                    final int xp = student['calculated_xp'] ?? 0;
                    final int grade = student['grade'] ?? 1;
                    final String avatar = student['avatar'] ?? "🐱";
                    
                    String medal = "🥇";
                    if (index == 1) medal = "🥈";
                    if (index == 2) medal = "🥉";

                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(medal, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(avatar, style: const TextStyle(fontSize: 20)),
                              ),
                            ],
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text("$grade-sinf o'quvchisi", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$xp Ball",
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        if (index < topStudents.length - 1)
                          const Divider(height: 1, indent: 60),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // DYNAMIC ADDITION 2: Recent Artworks Gallery Preview
            if (recentArtworks.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.palette_rounded, color: Colors.teal, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "Yaqinda qo'shilgan ijodiy ishlar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => widget.onNavigate?.call(3, subIndex: 1),
                    child: const Text("Barchasi", style: TextStyle(color: indigoColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: recentArtworks.length,
                  itemBuilder: (context, index) {
                    final work = recentArtworks[index];
                    final author = work['userName'] ?? "Noma'lum";
                    final status = work['status'] ?? "pending";
                    final likes = work['likes'] ?? 0;

                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.primaries[author.length % Colors.primaries.length].withValues(alpha: 0.2),
                                child: Text(
                                  author.isNotEmpty ? author[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: Colors.primaries[author.length % Colors.primaries.length],
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  author,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              Text("$likes ta yulduz", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: status == 'approved' ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status == 'approved' ? "Tasdiqlangan" : "Kutilmoqda",
                              style: TextStyle(
                                color: status == 'approved' ? Colors.green.shade800 : Colors.orange.shade800,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Section 3 — Quick actions
            const Text(
              "Tezkor amallar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickActionButton(
                  label: "Dars qo'shish",
                  icon: Icons.add_box_rounded,
                  color: Colors.teal,
                  onTap: () => widget.onNavigate?.call(2),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 4 — Info banner
            Container(
              decoration: BoxDecoration(
                color: indigoColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: indigoColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: indigoColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Texno Bilim",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: indigoColor,
                          ),
                        ),
                        Text(
                          "v1.0.0 — Diplom loyihasi, TATU",
                          style: TextStyle(
                            fontSize: 12,
                            color: indigoColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "ta",
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text("Barchaga e'lon yozish", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Sarlavha",
                    hintText: "Ertangi ochiq dars haqida",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "To'liq xabar",
                    hintText: "Barchani ko'rgazmaga taklif qilamiz...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: isSaving ? null : () async {
                  if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) return;
                  setDialogState(() => isSaving = true);
                  try {
                    await FirebaseFirestore.instance.collection('announcements').add({
                      'title': titleController.text.trim(),
                      'body': bodyController.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                      'isActive': true,
                    });
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Muhim e'lon muvaffaqiyatli tarqatildi! 📢", style: TextStyle(fontWeight: FontWeight.bold))));
                    }
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tarqatishda xatolik: $e")));
                  }
                },
                child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Tarqatish"),
              )
            ],
          );
        }
      )
    );
  }
}
