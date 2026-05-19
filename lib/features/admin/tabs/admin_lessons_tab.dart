import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_theme.dart';
import '../../../models/lesson_model.dart';
import '../tabs/add_lesson_screen.dart';
import '../../lessons/lesson_detail_screen.dart';

class AdminLessonsTab extends StatefulWidget {
  const AdminLessonsTab({super.key});

  @override
  State<AdminLessonsTab> createState() => _AdminLessonsTabState();
}

class _AdminLessonsTabState extends State<AdminLessonsTab> {
  int _selectedGradeFilter = 0; // 0: Barchasi, 1: 1-sinf, 2: 2-sinf, etc.
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const indigoColor = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Column(
        children: [
          // Filter & Search Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    hintText: "Darslarni izlash...",
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Colors.blueGrey.shade50.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Grade Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (ctx, index) {
                      final label = index == 0 ? "Barchasi 🌍" : "$index - sinf";
                      final isSelected = _selectedGradeFilter == index;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blueGrey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGradeFilter = index;
                            });
                          },
                          selectedColor: indigoColor,
                          backgroundColor: Colors.blueGrey.shade50,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // StreamBuilder for Lessons list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('lessons').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Xatolik yuz berdi: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Parse and filter lessons in Dart to ensure instant search & filtering
                final allLessons = snapshot.data!.docs.map((doc) {
                  return LessonModel.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                // Sort alphabetically by title
                allLessons.sort((a, b) => a.title.compareTo(b.title));

                final filteredLessons = allLessons.where((lesson) {
                  final matchesGrade = _selectedGradeFilter == 0 || lesson.grade == _selectedGradeFilter;
                  final matchesSearch = _searchQuery.isEmpty || 
                      lesson.title.toLowerCase().contains(_searchQuery) ||
                      lesson.category.toLowerCase().contains(_searchQuery) ||
                      lesson.description.toLowerCase().contains(_searchQuery);
                  return matchesGrade && matchesSearch;
                }).toList();

                if (filteredLessons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          "Mos darslar topilmadi!",
                          style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                  itemCount: filteredLessons.length,
                  itemBuilder: (ctx, i) {
                    final lesson = filteredLessons[i];
                    return _buildLessonCard(lesson, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: indigoColor,
        foregroundColor: Colors.white,
        onPressed: () => _openAddLesson(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Yangi Dars", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson, BuildContext context) {
    const indigoColor = Color(0xFF4F46E5);
    final String typeLabel = lesson.type == LessonType.video 
        ? "Video 🎥" 
        : lesson.type == LessonType.text 
            ? "Matnli 📄" 
            : "Interaktiv 🧩";

    final Color typeColor = lesson.type == LessonType.video
        ? Colors.red
        : lesson.type == LessonType.text
            ? Colors.orange
            : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Admin can click to enter the lesson and view it exactly as a student
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonDetailScreen(lesson: lesson),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top part: Thumbnail & Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail Image or Gradient Icon Box
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: typeColor.withValues(alpha: 0.1),
                        child: lesson.thumbnailUrl.isNotEmpty
                            ? Image.network(
                                lesson.thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  lesson.type == LessonType.video 
                                      ? Icons.video_library_rounded 
                                      : Icons.auto_stories_rounded,
                                  color: typeColor,
                                  size: 32,
                                ),
                              )
                            : Icon(
                                lesson.type == LessonType.video 
                                    ? Icons.video_library_rounded 
                                    : Icons.auto_stories_rounded,
                                color: typeColor,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Titles and Tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Grade Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: indigoColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${lesson.grade}-sinf",
                                  style: const TextStyle(
                                    color: indigoColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Type Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  typeLabel,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.description.isNotEmpty 
                                ? lesson.description 
                                : "Tavsif kiritilmagan...",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 10),
                // Bottom row: Counts & Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Step & Question stats
                    Row(
                      children: [
                        const Icon(Icons.style_rounded, size: 14, color: Colors.teal),
                        const SizedBox(width: 4),
                        Text(
                          "${lesson.steps.length} ta qadam",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.assignment_turned_in_rounded, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          "${lesson.questions.length} ta savol",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                    // Action Buttons (Edit & Delete)
                    Row(
                      children: [
                        // EDIT BUTTON
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddLessonScreen(lessonToEdit: lesson),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, color: Colors.teal),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.teal.shade50,
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // DELETE BUTTON
                        IconButton(
                          onPressed: () => _deleteLesson(lesson.id, context),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Hali darslar yaratilmagan!", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _openAddLesson(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Birinchi darsni qo'shish"),
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Darsni o'chirish", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Haqiqatan ham ushbu darsni butunlay o'chirib yubormoqchimisiz? Ushbu amalni qaytarib bo'lmaydi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text("Yo'q", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Ha, O'chirish", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );

    if (sure == true) {
      FirebaseFirestore.instance.collection('lessons').doc(docId).delete();
    }
  }
}
