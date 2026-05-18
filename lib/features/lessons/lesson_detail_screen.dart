import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../core/app_theme.dart';
import '../../models/lesson_model.dart';
import '../quiz/quiz_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _currentStep = 0;
  bool _playVideo = false;
  YoutubePlayerController? _ytController; // Nullable qildik

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == LessonType.video && widget.lesson.videoUrl.isNotEmpty) {
      final videoId = _extractVideoId(widget.lesson.videoUrl);
      if (videoId.isNotEmpty) {
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showFullscreenButton: true,
            mute: false,
            showControls: true,
            enableJavaScript: true,
            origin: 'https://www.youtube.com',
          ),
        );
      }
    }
  }

  String _extractVideoId(String url) {
    url = url.trim();
    if (url.isEmpty) return "";
    final regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1)!;
      // YouTube ID'lar odatda 11 belgidan iborat bo'ladi
      return id.length > 11 ? id.substring(0, 11) : id;
    }
    return "";
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.lesson.steps;
    final isLastStep = _currentStep == steps.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.lesson.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: widget.lesson.type == LessonType.video
          ? _buildVideoLayout()
          : (steps.isEmpty
              ? const Center(child: Text("Dars tarkibi yo'q"))
              : Column(
                  children: [
                    // Progress bar
                    Container(
                      width: double.infinity,
                      color: AppTheme.primaryColor,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Qadam ${_currentStep + 1} / ${steps.length}",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (_currentStep + 1) / steps.length,
                              backgroundColor: Colors.white30,
                              color: Colors.white,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Step content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step Image
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  image: steps[_currentStep].imageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(steps[_currentStep].imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: steps[_currentStep].imageUrl.isEmpty
                                    ? Icon(
                                        Icons.image_rounded,
                                        size: 80,
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              steps[_currentStep].title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              steps[_currentStep].content,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom navigation
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => _currentStep--);
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text("Orqaga"),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (!isLastStep) {
                                    setState(() => _currentStep++);
                                  } else {
                                    _showCompletionDialog(context);
                                  }
                                },
                                icon: Icon(isLastStep
                                    ? Icons.emoji_events_rounded
                                    : Icons.arrow_forward_rounded),
                                label: Text(isLastStep ? "Tamom!" : "Keyingisi"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }

  Widget _buildVideoLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Area
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: _playVideo && _ytController != null
                ? YoutubePlayer(controller: _ytController!)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.lesson.thumbnailUrl.isNotEmpty)
                        Positioned.fill(
                          child: Image.network(widget.lesson.thumbnailUrl, fit: BoxFit.cover),
                        )
                      else
                        Container(color: Colors.black12),
                      GestureDetector(
                        onTap: () {
                          if (widget.lesson.videoUrl.isNotEmpty) {
                            setState(() => _playVideo = true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ushbu dars uchun video havola qo'shilmagan!")),
                            );
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.red, size: 50),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.lesson.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(widget.lesson.category, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Text(widget.lesson.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
          const SizedBox(height: 40),
          // CTA Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (widget.lesson.videoUrl.isNotEmpty) {
                setState(() => _playVideo = true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Video havola mavjud emas!")),
                );
              }
            },
            icon: const Icon(Icons.play_circle_fill),
            label: const Text("Videoni Ko'rish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          // Finish button to get reward
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _showCompletionDialog(context),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text("Darsni tugatdim", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    // Admin tomonidan darsga qo'shilgan real savollarni tayyorlaymiz
    final List<QuizQuestion> realQuestions = widget.lesson.questions.map((q) => QuizQuestion(
      question: q.question,
      options: q.options,
      correctIndex: q.correctIndex,
    )).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: 64, color: AppTheme.successColor),
              ),
              const SizedBox(height: 20),
              const Text(
                "Barakalla! 🎉",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Darsni muvaffaqiyatli o'rganib chiqdingiz!\nEndi bilimlaringizni sinab ko'ramiz.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              if (realQuestions.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          lessonTitle: widget.lesson.title,
                          questions: realQuestions,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz_rounded),
                  label: const Text("Testni boshlash"),
                )
              else
                 const Padding(
                   padding: EdgeInsets.all(8.0),
                   child: Text("Ushbu dars uchun test savollari hali qo'shilmagan.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                 ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text("Bosh sahifaga qaytish"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
