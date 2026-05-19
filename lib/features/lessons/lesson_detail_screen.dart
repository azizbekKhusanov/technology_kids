import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
  VideoPlayerController? _videoController;
  bool _isLoadingVideo = false;
  bool _videoReady = false;
  String? _errorMessage;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _extractVideoId(String url) {
    url = url.trim();
    if (url.isEmpty) return '';
    final regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1)!;
      return id.length > 11 ? id.substring(0, 11) : id;
    }
    return '';
  }

  Future<void> _loadAndPlayVideo() async {
    if (_isLoadingVideo) return;
    setState(() {
      _isLoadingVideo = true;
      _errorMessage = null;
    });

    try {
      final videoId = _extractVideoId(widget.lesson.videoUrl);
      if (videoId.isEmpty) throw Exception('Video ID topilmadi');

      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.withHighestBitrate();
      final videoUrl = streamInfo.url.toString();
      yt.close();

      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.play();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _videoReady = true;
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
          _errorMessage = 'Video yuklanmadi. Internet aloqasini tekshiring.';
        });
      }
    }
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  image: steps[_currentStep].imageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(steps[_currentStep].imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: steps[_currentStep].imageUrl.isEmpty
                                    ? Icon(Icons.image_rounded, size: 80,
                                        color: AppTheme.primaryColor.withValues(alpha: 0.4))
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(steps[_currentStep].title,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text(steps[_currentStep].content,
                                style: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() => _currentStep--),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Orqaga'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
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
                                label: Text(isLastStep ? 'Tamom!' : 'Keyingisi'),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 240,
              color: Colors.black,
              child: _videoReady && _videoController != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                        // Play/Pause toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _videoController!.value.isPlaying
                                  ? _videoController!.pause()
                                  : _videoController!.play();
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 48),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Progress bar at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _videoController!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.white38,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _isLoadingVideo
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text('Video yuklanmoqda...',
                                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                  const SizedBox(height: 8),
                                  Text(_errorMessage!,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                if (widget.lesson.thumbnailUrl.isNotEmpty)
                                  Positioned.fill(
                                    child: Image.network(
                                      widget.lesson.thumbnailUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(color: Colors.black26),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded,
                                      color: Colors.red, size: 50),
                                ),
                              ],
                            ),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.lesson.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(widget.lesson.category,
              style: TextStyle(
                  color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Text(widget.lesson.description,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoadingVideo ? null : _loadAndPlayVideo,
            icon: _isLoadingVideo
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_fill),
            label: Text(
              _isLoadingVideo ? 'Yuklanmoqda...' : "Videoni Ko'rish",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _showCompletionDialog(context),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Darsni tugatdim', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    final List<QuizQuestion> realQuestions = widget.lesson.questions
        .map((q) => QuizQuestion(
              question: q.question,
              options: q.options,
              correctIndex: q.correctIndex,
            ))
        .toList();

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
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: 64, color: AppTheme.successColor),
              ),
              const SizedBox(height: 20),
              const Text('Barakalla! 🎉',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
                    Navigator.pop(context);
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
                  label: const Text('Testni boshlash'),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Ushbu dars uchun test savollari hali qo'shilmagan.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Bosh sahifaga qaytish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
