import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_theme.dart';
import 'add_lesson_screen.dart';

class AdminLessonsTab extends StatelessWidget {
  const AdminLessonsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lessons').orderBy('title').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.video_library_rounded, size: 80, color: Colors.grey.shade300),
                   const SizedBox(height: 16),
                   Text("Hali darslar yaratilmagan!", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                   const SizedBox(height: 16),
                   ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                      onPressed: () => _openAddLesson(context),
                      icon: const Icon(Icons.add), label: const Text("Birinchi darsni qo'shish")
                   )
                 ],
               ),
             );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
               final data = docs[i].data() as Map<String, dynamic>;
               final type = data['type'] ?? 'interactive';
               final String title = data['title'] ?? 'Sarlavhasiz';
               final int grade = data['grade'] ?? 1;

               return Card(
                 margin: const EdgeInsets.only(bottom: 12),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   leading: CircleAvatar(
                     backgroundColor: type == 'video' ? Colors.red.shade100 : Colors.blue.shade100,
                     child: Icon(type == 'video' ? Icons.play_arrow_rounded : Icons.library_books_rounded, color: type == 'video' ? Colors.red : Colors.blue),
                   ),
                   title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Text("$grade-sinf | ${data['category'] ?? ''}"),
                   trailing: IconButton(
                     icon: const Icon(Icons.delete_outline, color: Colors.red),
                     onPressed: () => _deleteLesson(docs[i].id, context),
                   ),
                 ),
               );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _openAddLesson(context),
        icon: const Icon(Icons.add),
        label: const Text("Yangi Dars"),
      ),
    );
  }

  void _openAddLesson(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLessonScreen()));
  }

  void _deleteLesson(String docId, BuildContext context) async {
    final sure = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: const Text("Haqiqatan ham bu darsni o'chirib yubormoqchimisiz? Undan keyin qaytarib bo'lmaydi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Yo'q", style: TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () => Navigator.pop(ctx, true), child: const Text("Ha, O'chirish")),
        ],
      )
    );

    if (sure == true) {
      FirebaseFirestore.instance.collection('lessons').doc(docId).delete();
    }
  }
}
