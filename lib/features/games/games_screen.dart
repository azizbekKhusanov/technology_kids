import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "${game['title']} o'yini tez orada qo'shiladi!"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: AppTheme.primaryColor,
                        ),
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
}
