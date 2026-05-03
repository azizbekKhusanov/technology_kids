import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/admin_exhibition_tab.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_students_tab.dart';
import 'tabs/admin_lessons_tab.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart'; // AuthWrapper uchun



class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});
  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdmin');
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthWrapper()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout),
        label: const Text("Tizimdan chiqish"),
      )
    );
  }
}


class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _currentIndex = 0; // Default to Dashboard Tab

  int _exhibitionInitialTab = 0; // Qaysi qismdan ochilishi (Tasdiqlash yoki Umumiy)

  late final List<Widget> _pages = [
    AdminDashboardTab(onNavigate: (index, {int? subIndex}) {
      setState(() {
        _currentIndex = index;
        if (subIndex != null) _exhibitionInitialTab = subIndex;
      });
    }),   // 0
    const AdminStudentsTab(),    // 1 - O'quvchilar
    const AdminLessonsTab(),     // 2 - Darslar (YANGI)
    AdminExhibitionTab(initialTabIndex: _exhibitionInitialTab), // 3 - Ko'rgazma
    const AdminProfileTab(),     // 4 - Profil
  ];

  final List<String> _titles = [
    "Dashboard",
    "O'quvchilar",
    "Darslar Boshqaruvi",
    "Ko'rgazma (Tasdiqlash)",
    "Mening Profilim"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Asosiy"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "O'quvchilar"),
          BottomNavigationBarItem(icon: Icon(Icons.play_lesson_rounded), label: "Darslar"),
          BottomNavigationBarItem(icon: Icon(Icons.collections_rounded), label: "Ko'rgazma"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
