enum LessonType { video, interactive, text }

class LessonModel {
  final String id;
  final String title;
  final String description;
  final int grade;
  final String category; // e.g., "Paper Craft", "Clay Modeling"
  final String thumbnailUrl;
  final String videoUrl; // YouTube havolasi uchun
  final List<StepModel> steps;
  final List<LessonQuestionModel> questions;
  final LessonType type;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.grade,
    required this.category,
    required this.thumbnailUrl,
    this.videoUrl = '',
    required this.steps,
    this.questions = const [],
    this.type = LessonType.interactive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'grade': grade,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'steps': steps.map((x) => x.toMap()).toList(),
      'questions': questions.map((x) => x.toMap()).toList(),
      'type': type.toString().split('.').last,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      grade: map['grade'] ?? 1,
      category: map['category'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      steps: List<StepModel>.from(
          (map['steps'] ?? []).map((x) => StepModel.fromMap(x))),
      questions: List<LessonQuestionModel>.from(
          (map['questions'] ?? []).map((x) => LessonQuestionModel.fromMap(x))),
      type: LessonType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => LessonType.interactive,
      ),
    );
  }
}

class LessonQuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;

  LessonQuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  factory LessonQuestionModel.fromMap(Map<String, dynamic> map) {
    return LessonQuestionModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }
}

class StepModel {
  final String title;
  final String content;
  final String imageUrl;
  final String audioUrl;

  StepModel({
    required this.title,
    required this.content,
    this.imageUrl = '',
    this.audioUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
    );
  }
}
