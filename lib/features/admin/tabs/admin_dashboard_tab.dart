import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_theme.dart';
import 'package:intl/intl.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);
    try {
      // Get counts efficiently using aggregate queries
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').count().get();
      final artworksSnapshot = await FirebaseFirestore.instance.collection('artworks').count().get();
      final pendingSnapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final lessonsSnapshot = await FirebaseFirestore.instance.collection('lessons').count().get();

      setState(() {
        totalUsers = usersSnapshot.count ?? 0;
        totalArtworks = artworksSnapshot.count ?? 0;
        pendingArtworks = pendingSnapshot.count ?? 0;
        totalLessons = lessonsSnapshot.count ?? 0;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Xush kelibsiz, Admin! 👨‍💻",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              IconButton(
                onPressed: _loadStatistics,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                tooltip: "Yangilash",
              )
            ],
          ),
          const SizedBox(height: 24),

          // Key Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildMetricCard(
                "O'quvchilar",
                totalUsers.toString(),
                Icons.people_alt_rounded,
                Colors.blue,
                () => widget.onNavigate?.call(1), // O'quvchilar tab (index 1)
              ),
              _buildMetricCard(
                "Darslar",
                totalLessons.toString(),
                Icons.menu_book_rounded,
                Colors.purple,
                () => widget.onNavigate?.call(2), // Darslar tab (index 2)
              ),
              _buildMetricCard(
                "Ko'rgazma",
                totalArtworks.toString(),
                Icons.collections_rounded,
                Colors.green,
                () => widget.onNavigate?.call(3, subIndex: 1), // Ko'rgazma tab (index 3)
              ),
              _buildMetricCard(
                "Faollik (Kutilyapti)",
                pendingArtworks.toString(),
                Icons.hourglass_empty_rounded,
                Colors.orange,
                () => widget.onNavigate?.call(3, subIndex: 0), // Kutilyapti (index 3)
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            "Tezkor Harakatlar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickActionBtn("Dars Qo'shish", Icons.add_box_rounded, Colors.teal, () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu funksiya ustida ishlayapmiz!")));
              }),
              const SizedBox(width: 16),
              _buildQuickActionBtn("Umumiy E'lon", Icons.campaign_rounded, Colors.indigo, _showAnnouncementDialog),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
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

