import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../models/lesson_model.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  final int grade;

  const LessonListScreen({super.key, this.grade = 1});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  int _selectedGrade = 1;

  // Sample data - later comes from Firebase
  final List<Map<String, dynamic>> _categories = [
    {
      'title': "Qog'oz bilan ishlash",
      'subtitle': '5 ta dars',
      'icon': Icons.description_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Loydan buyum yasash',
      'subtitle': '4 ta dars',
      'icon': Icons.landscape_rounded,
      'color': Colors.brown,
    },
    {
      'title': 'Tabiiy materiallar',
      'subtitle': '6 ta dars',
      'icon': Icons.eco_rounded,
      'color': Colors.green,
    },
    {
      'title': "Tikish va to'qish",
      'subtitle': '3 ta dars',
      'icon': Icons.architecture_rounded,
      'color': Colors.red,
    },
    {
      'title': 'Konstruktorlar',
      'subtitle': '5 ta dars',
      'icon': Icons.view_in_ar_rounded,
      'color': Colors.orange,
    },
    {
      'title': 'Rasm chizish',
      'subtitle': '7 ta dars',
      'icon': Icons.brush_rounded,
      'color': Colors.deepPurple,
    },
    {
      'title': 'Qayta ishlash',
      'subtitle': '3 ta dars',
      'icon': Icons.recycling_rounded,
      'color': Colors.teal,
    },
  ];

  LessonModel _sampleLesson(String title) {
    return LessonModel(
      id: '1',
      title: title,
      description: 'Origami: qushdek uching!',
      grade: _selectedGrade,
      category: 'Qog\'oz',
      thumbnailUrl: '',
      steps: [
        StepModel(
          title: '1-qadam: Tayyorgarlik',
          content:
              "Kvadrat shaklidagi qog'oz oling. Qog'oz tekis va toza bo'lishi kerak.",
        ),
        StepModel(
          title: '2-qadam: Burish',
          content:
              "Qog'ozni diagonal bo'ylab ikkiga burib, uchburchak hosil qiling.",
        ),
        StepModel(
          title: '3-qadam: Shakl berish",',
          content: "Uchburchakning uchlarini markazga qarab buking.",
        ),
        StepModel(
          title: '4-qadam: Tugatish',
          content: "Barakalla! Origami tayyor. Sinf daftariga yopishtirishingiz mumkin.",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Darslar",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Grade filter
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [1, 2, 3, 4].map((grade) {
                final isSelected = _selectedGrade == grade;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGrade = grade),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$grade-sinf",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Categories list (Real lessons from Firestore)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .where('grade', isEqualTo: _selectedGrade)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "Hozircha $_selectedGrade-sinf uchun darslar yo'q.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final lessons = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final data = lessons[index].data() as Map<String, dynamic>;
                    final lessonModel = LessonModel.fromMap(data);
                    
                    // Har bir kategoriya uchun rang va ikonani tanlash (yoki darsdan olish)
                    final Color cardColor = _getCategoryColor(lessonModel.category);
                    final IconData cardIcon = _getCategoryIcon(lessonModel.category);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      shadowColor: cardColor.withOpacity(0.1),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            image: lessonModel.thumbnailUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(lessonModel.thumbnailUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: lessonModel.thumbnailUrl.isEmpty
                              ? Icon(cardIcon, color: cardColor, size: 30)
                              : null,
                        ),
                        title: Text(
                          lessonModel.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: lessonModel.type == LessonType.video 
                                    ? Colors.red.shade50 
                                    : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lessonModel.type == LessonType.video ? "Video" : "Interaktiv",
                                  style: TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold,
                                    color: lessonModel.type == LessonType.video ? Colors.red : Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(lessonModel.category,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: AppTheme.primaryColor),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonDetailScreen(
                                lesson: lessonModel,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    category = category.toLowerCase();
    if (category.contains('qog') || category.contains('origami')) return Colors.blue;
    if (category.contains('loy') || category.contains('plastilin')) return Colors.brown;
    if (category.contains('tikish') || category.contains('kiyim')) return Colors.red;
    if (category.contains('tabiat') || category.contains('o\'simlik')) return Colors.green;
    return Colors.amber;
  }

  IconData _getCategoryIcon(String category) {
    category = category.toLowerCase();
    if (category.contains('qog') || category.contains('origami')) return Icons.description_rounded;
    if (category.contains('loy') || category.contains('plastilin')) return Icons.landscape_rounded;
    if (category.contains('tikish') || category.contains('kiyim')) return Icons.architecture_rounded;
    return Icons.auto_awesome_mosaic_rounded;
  }
}
