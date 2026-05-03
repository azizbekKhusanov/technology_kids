import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class TeacherPanel extends StatefulWidget {
  const TeacherPanel({super.key});

  @override
  State<TeacherPanel> createState() => _TeacherPanelState();
}

class _TeacherPanelState extends State<TeacherPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _students = [
    {'name': 'Aziza Karimova', 'grade': '2-sinf', 'stars': 145, 'progress': 0.85, 'active': true},
    {'name': 'Bobur Toshmatov', 'grade': '2-sinf', 'stars': 98, 'progress': 0.60, 'active': true},
    {'name': 'Dilnoza Yusupova', 'grade': '2-sinf', 'stars': 210, 'progress': 0.95, 'active': false},
    {'name': 'Eldor Rашidov', 'grade': '2-sinf', 'stars': 55, 'progress': 0.30, 'active': true},
    {'name': 'Feruza Nazarova', 'grade': '2-sinf', 'stars': 175, 'progress': 0.75, 'active': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("O'qituvchi paneli",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.people_rounded), text: "O'quvchilar"),
            Tab(icon: Icon(Icons.bar_chart_rounded), text: "Statistika"),
            Tab(icon: Icon(Icons.assignment_rounded), text: "Topshiriqlar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentsTab(),
          _buildStatsTab(),
          _buildTasksTab(context),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, i) {
        final s = _students[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: NetworkImage(
                      'https://api.dicebear.com/7.x/bottts/png?seed=${s['name']}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(s['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (s['active'] as bool)
                                  ? AppTheme.successColor.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (s['active'] as bool) ? "Faol" : "Kamfaol",
                              style: TextStyle(
                                fontSize: 11,
                                color: (s['active'] as bool)
                                    ? Colors.green[700]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(s['grade'],
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: s['progress'] as double,
                                backgroundColor: Colors.grey[200],
                                color: AppTheme.primaryColor,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${((s['progress'] as double) * 100).round()}%",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 18),
                    Text("${s['stars']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard("5", "O'quvchi", Icons.people_rounded, AppTheme.primaryColor),
              const SizedBox(width: 12),
              _buildStatCard("7", "Mavzu", Icons.auto_stories_rounded, AppTheme.accentColor),
              const SizedBox(width: 12),
              _buildStatCard("69%", "O'rtacha", Icons.trending_up_rounded, AppTheme.successColor),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mavzular bo'yicha o'zlashtirish",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  ...{
                    "Qog'oz ishlash": 0.85,
                    "Loy yasash": 0.60,
                    "Tabiiy materiallar": 0.72,
                    "Tikish": 0.45,
                    "Konstruktorlar": 0.90,
                  }.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key,
                                    style: const TextStyle(fontSize: 14)),
                                Text("${(e.value * 100).round()}%",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value,
                                backgroundColor: Colors.grey[200],
                                color: e.value >= 0.7
                                    ? AppTheme.successColor
                                    : AppTheme.accentColor,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Yangi topshiriq berish"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTaskItem("Qog'ozdan samolyot yasash", "2-sinf barchasi", "21 Apr"),
              _buildTaskItem("Tabiat materiallaridan kollaj yasash", "2-sinf A", "23 Apr"),
              _buildTaskItem("Origami: qushcha", "2-sinf barchasi", "25 Apr"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(String title, String target, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.assignment_turned_in_rounded,
              color: AppTheme.primaryColor),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$target · $date",
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: () {},
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Topshiriq berish"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Topshiriq mazmunini yozing...",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Bekor qilish")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yuborish"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(val,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
