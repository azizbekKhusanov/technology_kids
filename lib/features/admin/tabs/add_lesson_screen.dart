import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_theme.dart';
import '../../../models/lesson_model.dart';
import 'dart:math';

class AddLessonScreen extends StatefulWidget {
  const AddLessonScreen({super.key});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _videoUrlController = TextEditingController(); // Yangi

  int _selectedGrade = 1;
  LessonType _selectedType = LessonType.interactive;

  // Qadamlar ro'yxati
  final List<_StepData> _steps = [_StepData()];
  
  // Savollar ro'yxati
  final List<_QuestionData> _questions = [];

  bool _isSaving = false;

  void _addStep() {
    setState(() => _steps.add(_StepData()));
  }

  void _removeStep(int index) {
    if (_steps.length > 1) {
      setState(() => _steps.removeAt(index));
    }
  }

  void _addQuestion() {
    setState(() => _questions.add(_QuestionData()));
  }

  void _removeQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final List<StepModel> stepModels = _steps.map((s) => StepModel(
        title: s.titleController.text.trim(),
        content: s.contentController.text.trim(),
        imageUrl: s.imageController.text.trim(),
      )).toList();

      final List<LessonQuestionModel> questionModels = _questions.map((q) => LessonQuestionModel(
        question: q.questionController.text.trim(),
        options: [
          q.optA.text.trim(),
          q.optB.text.trim(),
          q.optC.text.trim(),
          q.optD.text.trim(),
        ],
        correctIndex: q.correctIndex,
      )).toList();

      final String newId = "lesson_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}";

      final lesson = LessonModel(
        id: newId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        grade: _selectedGrade,
        category: _categoryController.text.trim(),
        thumbnailUrl: _thumbnailController.text.trim(),
        videoUrl: _videoUrlController.text.trim(), // Yangi
        steps: stepModels,
        questions: questionModels,
        type: _selectedType,
      );

      await FirebaseFirestore.instance.collection('lessons').doc(newId).set(lesson.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Yangi dars va test muvaffaqiyatli saqlandi! 🎉"),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saqlashda xatolik: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text("Yangi Dars Qo'shish", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("1. Asosiy Ma'lumotlar"),
                  _buildTextField(_titleController, "Dars sarlavhasi", "Masalan: Qog'ozdan kemacha yasaymiz"),
                  _buildTextField(_descController, "Qisqacha ta'rifi (Description)", "Qog'oz buklash san'ati, logika..."),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_categoryController, "Kategoriya", "Masalan: Origami")),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: _inputDecoration("Sinf uchun"),
                          value: _selectedGrade,
                          items: [1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text("$e-sinf"))).toList(),
                          onChanged: (v) => setState(() => _selectedGrade = v!),
                        ),
                      )
                    ],
                  ),
                  
                  _buildTextField(_thumbnailController, "Rasm Linki (Asosiy Muqova)", "https://...", isRequired: false),
                  
                  if (_selectedType == LessonType.video)
                    _buildTextField(_videoUrlController, "YouTube Video Linki", "https://www.youtube.com/watch?v=...", isRequired: true),
                  
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LessonType>(
                    decoration: _inputDecoration("Dars formati turini tanlang"),
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: LessonType.interactive, child: Text("Interaktiv (Qadam-ba-qadam)")),
                      DropdownMenuItem(value: LessonType.video, child: Text("Video (YouTube)")),
                      DropdownMenuItem(value: LessonType.text, child: Text("Maqola (Matnli)")),
                    ],
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("2. Dars Qadamlari (Steps)"),
                      if (_selectedType != LessonType.video)
                        TextButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add), label: const Text("Qadam qo'shish")
                        )
                    ],
                  ),
                  
                  if (_selectedType == LessonType.video)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text("💡 Video dars tanlanganida, qadamlarga yozilgan videoni ko'rish bo'yicha qisqacha ko'rsatma yozish tavsiya qilinadi.", style: TextStyle(color: Colors.blue.shade800, fontSize: 12)),
                    ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${i + 1} - Qadam", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (_steps.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _removeStep(i),
                                    )
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(_steps[i].titleController, "Qadam nomi", _selectedType == LessonType.video ? "YouTube Video Linkini kiritishingiz ham mumkin" : "Masalan: Qog'ozni kesamiz"),
                              _buildTextField(_steps[i].contentController, "Bajariladigan ish (yoki matn)", "Batafsil matn yozing...", maxLines: 3),
                              if (_selectedType != LessonType.video)
                                _buildTextField(_steps[i].imageController, "Qadam uchun rasm linki (Ixtiyoriy)", "https://...", isRequired: false),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("3. Test Savollari (Quiz)"),
                      TextButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add_task_rounded), 
                        label: const Text("Savol qo'shish")
                      )
                    ],
                  ),
                  
                  if (_questions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("Hali savollar qo'shilmadi (Ixtiyoriy)", style: TextStyle(color: Colors.grey))),
                    ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${i + 1} - Savol", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                                    onPressed: () => _removeQuestion(i),
                                  )
                                ],
                              ),
                              _buildTextField(_questions[i].questionController, "Savol matni", "Masalan: Origami nima?"),
                              const Text("Javob variantlari (To'g'ri javobni tanlang):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 10),
                              _buildOptionField(_questions[i].optA, "A javob", 0, i),
                              _buildOptionField(_questions[i].optB, "B javob", 1, i),
                              _buildOptionField(_questions[i].optC, "C javob", 2, i),
                              _buildOptionField(_questions[i].optD, "D javob", 3, i),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
      bottomNavigationBar: _isSaving ? null : Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
          ),
          onPressed: _saveLesson,
          icon: const Icon(Icons.cloud_upload),
          label: const Text("Darsni Nashr Qilish (Saqlash)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildOptionField(TextEditingController controller, String label, int index, int qIndex) {
    final isCorrect = _questions[qIndex].correctIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Radio<int>(
            value: index, 
            groupValue: _questions[qIndex].correctIndex, 
            onChanged: (v) => setState(() => _questions[qIndex].correctIndex = v!)
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: _inputDecoration(label).copyWith(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide(color: isCorrect ? Colors.green : AppTheme.primaryColor, width: 2)
                )
              ),
              validator: (v) => v!.isEmpty ? "!" : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isRequired = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label).copyWith(hintText: hint),
        validator: isRequired ? (v) => v!.isEmpty ? "Maydonni to'ldiring!" : null : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
    );
  }
}

class _StepData {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageController = TextEditingController();
}

class _QuestionData {
  final questionController = TextEditingController();
  final optA = TextEditingController();
  final optB = TextEditingController();
  final optC = TextEditingController();
  final optD = TextEditingController();
  int correctIndex = 0;
}
