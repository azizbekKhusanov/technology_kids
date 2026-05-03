import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizScreen extends StatefulWidget {
  final String lessonTitle;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.lessonTitle,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    ));
    _animController.forward();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == widget.questions[_currentQuestion].correctIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_currentQuestion < widget.questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _answered = false;
        });
        _animController.reset();
        _animController.forward();
      } else {
        _finishQuiz();
      }
    });
  }

  Future<void> _finishQuiz() async {
    setState(() {
      _finished = true;
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final int earnedBall = _score * 10;
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) return;
          
          final int currentBall = snapshot.data()?['xp'] ?? 0;
          transaction.update(docRef, {'xp': currentBall + earnedBall});
        });
      }
    } catch (e) {
      debugPrint("Ball saqlashda xatolik: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResultScreen(context);

    final q = widget.questions[_currentQuestion];
    final progress = widget.questions.isEmpty ? 0.0 : (_currentQuestion + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Test: ${widget.lessonTitle}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_currentQuestion + 1} / ${widget.questions.length}",
                      style: const TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text("$_score ball",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white30,
                    color: Colors.amber,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.help_outline_rounded,
                              size: 40, color: AppTheme.primaryColor),
                          const SizedBox(height: 12),
                          Text(
                            q.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(q.options.length, (i) {
                      return _buildOptionButton(q, i);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(QuizQuestion q, int i) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color textColor = Colors.black87;
    IconData? trailingIcon;

    if (_answered && _selectedAnswer == i) {
      if (i == q.correctIndex) {
        bgColor = AppTheme.successColor.withOpacity(0.15);
        borderColor = AppTheme.successColor;
        trailingIcon = Icons.check_circle_rounded;
        textColor = Colors.green[800]!;
      } else {
        bgColor = AppTheme.errorColor.withOpacity(0.15);
        borderColor = AppTheme.errorColor;
        trailingIcon = Icons.cancel_rounded;
        textColor = Colors.red[800]!;
      }
    } else if (_answered && i == q.correctIndex) {
      bgColor = AppTheme.successColor.withOpacity(0.1);
      borderColor = AppTheme.successColor;
      textColor = Colors.green[700]!;
    }

    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: () => _selectAnswer(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                letters[i],
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                q.options[i],
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor),
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon,
                  color: i == q.correctIndex ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context) {
    final total = widget.questions.length;
    final earned = _score * 10;
    final percent = total > 0 ? (_score / total * 100).round() : 0;
    final passed = percent >= 60;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving)
                const CircularProgressIndicator()
              else
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: passed
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed
                        ? Icons.emoji_events_rounded
                        : Icons.sentiment_dissatisfied_rounded,
                    size: 80,
                    color:
                        passed ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                passed ? "Barakalla! 🎉" : "Harakat qiling! 💪",
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "$_score / $total to'g'ri javob — $percent%",
                style:
                    const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              if (earned > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "+$earned Ball to'pladingiz!",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 40,
                    color: i < (percent >= 80 ? 3 : percent >= 60 ? 2 : 1)
                        ? Colors.amber
                        : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home_rounded),
                label: const Text("Darsga qaytish"),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQuestion = 0;
                    _selectedAnswer = null;
                    _answered = false;
                    _score = 0;
                    _finished = false;
                  });
                  _animController.forward();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Qayta urinish"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
