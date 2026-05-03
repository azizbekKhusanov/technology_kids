import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStudentsTab extends StatelessWidget {
  const AdminStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchStudentsWithXP(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Xatolik: ${snapshot.error}"));
        }
        
        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return const Center(child: Text("Hozircha o'quvchilar ro'yxatdan o'tmagan.", style: TextStyle(color: Colors.grey, fontSize: 16)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final rank = index + 1;
            
            return _buildStudentCard(student, rank);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchStudentsWithXP() async {
    // 1. O'quvchilarni olish
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    // 2. XP hisoblash uchun barcha asarlarni olish (Ma'lumotlar kam bo'lganda bu eng oson usul)
    final artworksSnapshot = await FirebaseFirestore.instance.collection('artworks').get();
    
    // Map: userId -> {artworksCount, totalLikes}
    final Map<String, _UserStats> userStatsMap = {};
    for (var doc in artworksSnapshot.docs) {
      final data = doc.data();
      final uId = data['userId'] as String?;
      if (uId == null) continue;

      if (!userStatsMap.containsKey(uId)) {
        userStatsMap[uId] = _UserStats();
      }
      userStatsMap[uId]!.artworksCount += 1;
      userStatsMap[uId]!.totalLikes += (data['likes'] ?? 0) as int;
    }

    // 3. Userlarni yig'ish va hisoblash
    List<Map<String, dynamic>> students = [];
    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      String uid = doc.id;
      int xp = 0;
      
      if (userStatsMap.containsKey(uid)) {
        final stats = userStatsMap[uid]!;
        // XP formulasi ProfileScreen bilan bir xil: 50 * artworks + 10 * likes
        xp = (stats.artworksCount * 50) + (stats.totalLikes * 10);
      }

      data['uid'] = uid;
      data['calculated_xp'] = xp;
      students.add(data);
    }

    // 4. E'ng ko'p XP olganlar bo'yicha saralash
    students.sort((a, b) => (b['calculated_xp'] as int).compareTo(a['calculated_xp'] as int));

    return students;
  }

  Widget _buildStudentCard(Map<String, dynamic> data, int rank) {
    final String name = data['username'] ?? "Noma'lum";
    final int grade = data['grade'] ?? 1;
    final String avatarStr = data['avatar'] ?? "🐶";
    final int xp = data['calculated_xp'] ?? 0;
    final int level = (xp / 100).floor() + 1;

    // Leaderboard ranglari
    Color medalColor = Colors.grey.shade300;
    if (rank == 1) medalColor = Colors.amber;
    if (rank == 2) medalColor = Colors.grey.shade400; // Silver
    if (rank == 3) medalColor = Colors.brown.shade300; // Bronze

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: rank <= 3 ? Border.all(color: medalColor.withOpacity(0.5), width: 2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade100,
              child: Text(avatarStr, style: const TextStyle(fontSize: 30)),
            ),
            if (rank <= 3)
              Container(
                decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.star, color: Colors.white, size: 16),
              )
          ],
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("$grade-sinf | LEVEL $level", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$xp Ball",
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _UserStats {
  int artworksCount = 0;
  int totalLikes = 0;
}
