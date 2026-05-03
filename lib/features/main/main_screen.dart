import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../home/home_screen.dart';
import '../lessons/lesson_list_screen.dart';
import '../profile/profile_screen.dart';

import '../workshop/virtual_workshop_screen.dart';

import '../exhibition/exhibition_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),        // 0 - Asosiy
    const LessonListScreen(),  // 1 - Darslar
    const ExhibitionScreen(),  // 2 - Ko'rgazma
    const ProfileScreen(),     // 3 - Profil
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _pages[_currentIndex],
      
      // Pastki Menyu (Bottom Navigation)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.home_rounded, label: "Asosiy", index: 0),
                _buildNavItem(icon: Icons.auto_stories_rounded, label: "Darslar", index: 1),
                
                // Markazdagi Yaratish (Ustaxona) tugmasi - qatorga tushirildi
                _buildCenterItem(context),
                
                _buildNavItem(icon: Icons.collections_rounded, label: "Ko'rgazma", index: 2),
                _buildNavItem(icon: Icons.person_rounded, label: "Profil", index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualWorkshopScreen()));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black, // Bolalar uchun ajralib turuvchi tasvirdagi qora dizayn
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ustaxona",
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryColor : Colors.grey;

    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
