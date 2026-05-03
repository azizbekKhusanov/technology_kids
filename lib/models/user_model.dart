enum UserRole { student, teacher, parent, admin }

class UserModel {
  final String id;
  final String name;
  final int grade; // 1-4
  final UserRole role;
  final String avatarUrl;
  final int level;
  final int stars;
  final Map<String, dynamic> progress; // LessonID : ProgressPercentage

  UserModel({
    required this.id,
    required this.name,
    this.grade = 1,
    this.role = UserRole.student,
    this.avatarUrl = '',
    this.level = 1,
    this.stars = 0,
    this.progress = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'role': role.toString().split('.').last,
      'avatarUrl': avatarUrl,
      'level': level,
      'stars': stars,
      'progress': progress,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'] ?? 1,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.student,
      ),
      avatarUrl: map['avatarUrl'] ?? '',
      level: map['level'] ?? 1,
      stars: map['stars'] ?? 0,
      progress: Map<String, dynamic>.from(map['progress'] ?? {}),
    );
  }
}
