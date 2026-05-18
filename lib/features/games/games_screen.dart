import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'matching_game_screen.dart';
import 'puzzle_game_screen.dart';
import 'ordering_game_screen.dart';
import 'word_game_screen.dart';
import '../quiz/quiz_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Moslashtirish',
        'description': 'Rasm va so\'zlarni to\'g\'ri joylashtir!',
        'icon': Icons.swap_horiz_rounded,
        'color': Colors.deepPurple,
        'tag': 'Yangi',
      },
      {
        'title': 'Puzzle',
        'description': 'Rasmni to\'g\'ri yig\'ib ko\'r!',
        'icon': Icons.extension_rounded,
        'color': Colors.blue,
        'tag': '',
      },
      {
        'title': 'Tartiblash',
        'description': 'Jarayonlarni to\'g\'ri tartibda joylashtir!',
        'icon': Icons.format_list_numbered_rounded,
        'color': Colors.orange,
        'tag': 'Mashhur',
      },
      {
        'title': 'Test',
        'description': 'Bilimingizni sinab ko\'ring!',
        'icon': Icons.quiz_rounded,
        'color': Colors.green,
        'tag': '',
      },
      {
        'title': 'So\'zlar o\'yini',
        'description': 'Texnologiya atamalarini top!',
        'icon': Icons.text_fields_rounded,
        'color': Colors.red,
        'tag': '',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("O'yinlar",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            width: double.infinity,
            color: AppTheme.accentColor,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: const Text(
              "O'yin o'ynab, bilimingizni mustahkamlang! 🎮",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          // Games list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final color = game['color'] as Color;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final String title = game['title'] as String;
                      Widget targetScreen;
                      if (title == 'Moslashtirish') {
                        targetScreen = const MatchingGameScreen();
                      } else if (title == 'Puzzle') {
                        targetScreen = const PuzzleGameScreen();
                      } else if (title == 'Tartiblash') {
                        targetScreen = const OrderingGameScreen();
                      } else if (title == 'So\'zlar o\'yini') {
                        targetScreen = const WordGameScreen();
                      } else if (title == 'Test') {
                        final List<QuizQuestion> randomQuestions = List<QuizQuestion>.from(_allQuestions)..shuffle();
                        targetScreen = QuizScreen(
                          lessonTitle: "Texnologiya Asoslari",
                          questions: randomQuestions.take(5).toList(),
                        );
                      } else {
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => targetScreen),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(game['icon'] as IconData,
                                color: color, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      game['title'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                    if ((game['tag'] as String).isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          game['tag'] as String,
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(game['description'] as String,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                          Icon(Icons.play_circle_filled_rounded,
                              color: color, size: 36),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const List<QuizQuestion> _allQuestions = [
    QuizQuestion(
      question: "Origami nima?",
      options: ["Qog'ozni buklash san'ati", "Loydan shakl yasash", "Yog'och o'ymakorligi", "Ip bilan to'qish"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Plastilin bilan ishlashda qaysi asbob ishlatiladi?",
      options: ["Qaychi", "Loy pichog'i (Stek)", "Igna", "Randa"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Tabiiy materiallar guruhiga nimalar kiradi?",
      options: ["Plastmassa va oyna", "Quruq barglar va toshlar", "Rangli qog'oz va karton", "Sintetik iplar"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Qog'ozni bir-biriga yopishtirish uchun nima kerak?",
      options: ["Randa", "Yelim (kley)", "Igna", "Sim"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Tikuvchilikda barmoqni igna sanchilishidan nima himoya qiladi?",
      options: ["Qaychi", "Angishvona", "Andoza", "Ip"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Yog'och yuzasini silliq qilish uchun nima ishlatiladi?",
      options: ["Bolg'a", "Randa va sumbada qog'oz", "Pichoq", "Yelim"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Qog'oz birinchi marta qayerda kashf etilgan?",
      options: ["Qadimgi Xitoyda", "Misrda", "Rimda", "Samarqandda"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Applikatsiya nima?",
      options: ["Yog'och chopish", "Har xil shakllarni qog'ozga yopishtirish", "Loy pishirish", "Qo'shiq kuylash"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Ignaga ip o'tkazishda qaysi xavfsizlik qoidasiga amal qilinadi?",
      options: ["Ignani og'izga solmaslik kerak", "Ignani yerga tashlash kerak", "Ignani do'stimizga otish kerak", "Ignasiz tikish kerak"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Plastilindan shakl yasash qanday ataladi?",
      options: ["Tikish", "Loy ishlari / Plastilin haykaltaroshligi", "Bichish", "Duradgorlik"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Qaychi bilan ishlashda eng muhim qoida nima?",
      options: ["Uni faqat dasta qismidan ushlab uzatish", "Uni havoda o'ynatish", "Uni og'izga solish", "Uni o'tkir tomoni bilan otish"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Origami san'ati dastlab qaysi mamlakatda keng rivojlangan?",
      options: ["Yaponiya", "Germaniya", "Angliya", "Braziliya"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Qog'oz va karton o'rtasidagi farq nima?",
      options: ["Karton qalinroq va qattiqroq", "Qog'oz og'irroq", "Ularning farqi yo'q", "Karton faqat yashil bo'ladi"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Duradgor kim?",
      options: ["Kiyim tikadigan usta", "Yog'ochdan buyumlar yasaydigan usta", "Rasm chizadigan rassom", "Non yopadigan novvoy"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Yelim bilan ishlagandan keyin nima qilish kerak?",
      options: ["Qo'lni yuvish va elim qopqog'ini yopish", "Elimni ochiq qoldirish", "Qo'lni kiyimga surtish", "Elimni tatib ko'rish"],
      correctIndex: 0,
    ),
  ];
}
