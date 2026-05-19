import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';

class AdminLogsScreen extends StatelessWidget {
  const AdminLogsScreen({super.key});

  void _clearLogs(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Loglarni tozalash"),
        content: const Text("Haqiqatan ham barcha tizim loglarini o'chirib tashlamoqchimisiz? Ushbu amalni ortga qaytarib bo'lmaydi!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final logs = await FirebaseFirestore.instance.collection('admin_logs').get();
                final batch = FirebaseFirestore.instance.batch();
                for (var doc in logs.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Barcha tizim loglari muvaffaqiyatli tozalandi! 🧹"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Xatolik yuz berdi: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Ha, o'chirish"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const indigoColor = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text("Tizim Faollik Loglari", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            tooltip: "Loglarni tozalash",
            onPressed: () => _clearLogs(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_logs')
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: indigoColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Yuklashda xatolik: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                    ),
                    child: Icon(Icons.playlist_remove_rounded, size: 64, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Hozircha tizim loglari mavjud emas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tizimdagi faolliklar bu yerda avtomatik qayd etiladi.",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String actionType = data['actionType'] ?? 'info';
              final String description = data['description'] ?? "Noma'lum harakat";
              final String operatorName = data['operatorName'] ?? "Tizim";
              final String operatorUser = data['operatorUser'] ?? "system";
              final Timestamp? timestamp = data['timestamp'] as Timestamp?;

              // Format date beautifully
              String formattedTime = "Hozirgina";
              if (timestamp != null) {
                final date = timestamp.toDate();
                final months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
                final day = date.day.toString().padLeft(2, '0');
                final monthStr = months[date.month - 1];
                final hour = date.hour.toString().padLeft(2, '0');
                final minute = date.minute.toString().padLeft(2, '0');
                formattedTime = "$day-$monthStr, $hour:$minute";
              }

              // Determine icon & color based on actionType
              IconData icon = Icons.info_outline_rounded;
              Color color = Colors.grey;

              switch (actionType) {
                case 'login':
                  icon = Icons.vpn_key_rounded;
                  color = Colors.amber.shade700;
                  break;
                case 'artwork_approved':
                  icon = Icons.check_circle_rounded;
                  color = Colors.green;
                  break;
                case 'artwork_rejected':
                  icon = Icons.cancel_rounded;
                  color = Colors.red;
                  break;
                case 'settings_updated':
                  icon = Icons.settings_suggest_rounded;
                  color = Colors.blue;
                  break;
                case 'lesson_added':
                  icon = Icons.my_library_add_rounded;
                  color = Colors.purple;
                  break;
                case 'lesson_deleted':
                  icon = Icons.delete_sweep_rounded;
                  color = Colors.redAccent;
                  break;
                case 'lesson_edited':
                  icon = Icons.edit_note_rounded;
                  color = Colors.indigo;
                  break;
                case 'announcement_sent':
                  icon = Icons.campaign_rounded;
                  color = Colors.teal;
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action Icon Bubble
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      // Text Contents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded, size: 13, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$operatorName (@$operatorUser)",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
