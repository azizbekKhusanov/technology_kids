import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> badges = [
      {
        'title': 'Birinchi dars',
        'description': 'Birinchi darsni tugatdi',
        'icon': Icons.school_rounded,
        'color': Colors.amber,
        'earned': true,
      },
      {
        'title': 'Izlanuvchan',
        'description': '5 ta darsni tugatdi',
        'icon': Icons.explore_rounded,
        'color': Colors.blue,
        'earned': true,
      },
      {
        'title': 'Yulduz',
        'description': '10 ta yulduzcha to\'pladi',
        'icon': Icons.star_rounded,
        'color': Colors.orange,
        'earned': true,
      },
      {
        'title': 'Super o\'quvchi',
        'description': '10 ta darsni tugatdi',
        'icon': Icons.emoji_events_rounded,
        'color': Colors.green,
        'earned': false,
      },
      {
        'title': 'Matematik',
        'description': 'Barcha testlardan 100 ball',
        'icon': Icons.calculate_rounded,
        'color': Colors.purple,
        'earned': false,
      },
      {
        'title': 'Yaratuvchan',
        'description': 'Barcha mavzularni o\'rgandi',
        'icon': Icons.auto_awesome_rounded,
        'color': Colors.red,
        'earned': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Yutuqlar",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stars summary
          Container(
            width: double.infinity,
            color: AppTheme.successColor,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("124", "Yulduz", Icons.star_rounded, Colors.amber),
                _buildStatItem("3", "Nishon", Icons.military_tech_rounded, Colors.white),
                _buildStatItem("7", "Dars", Icons.auto_stories_rounded, Colors.lightBlue[100]!),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Barcha nishonlar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final color = badge['color'] as Color;
                final earned = badge['earned'] as bool;
                return Container(
                  decoration: BoxDecoration(
                    color: earned ? color.withOpacity(0.12) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: earned ? color.withOpacity(0.4) : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Icon(
                            badge['icon'] as IconData,
                            size: 52,
                            color: earned ? color : Colors.grey[400],
                          ),
                          if (!earned)
                            const Icon(Icons.lock_rounded,
                                size: 18, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        badge['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: earned ? Colors.black87 : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          badge['description'] as String,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
      ],
    );
  }
}
