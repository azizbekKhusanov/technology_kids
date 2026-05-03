import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ParentPanel extends StatelessWidget {
  const ParentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Ota-ona paneli",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child summary card
            _buildChildCard(),
            const SizedBox(height: 20),
            // Daily activity
            const Text("Bugungi faollik",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildActivityCard(),
            const SizedBox(height: 20),
            // Screen time control
            const Text("Ekran vaqtini boshqarish",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildScreenTimeCard(context),
            const SizedBox(height: 20),
            // Notifications
            const Text("So'nggi bildirishnomalar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildNotification(
              "✅ Dars tugatildi",
              "Aziza 'Qog'oz ishlash' darsini tugatdi",
              "2 soat oldin",
              Colors.green,
            ),
            _buildNotification(
              "🎮 O'yin o'ynaldi",
              "Aziza 'Moslashtirish' o'yinida 100 ball to'pladi",
              "3 soat oldin",
              Colors.blue,
            ),
            _buildNotification(
              "📋 Topshiriq bor",
              "O'qituvchi yangi topshiriq berdi: Origami",
              "Kecha",
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.teal, Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
                'https://api.dicebear.com/7.x/bottts/png?seed=Aziza'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Aziza Karimova",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text("2-sinf • 1-daraja",
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text("145 yulduz",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityItem("3", "Dars", Icons.auto_stories_rounded, Colors.blue),
                _buildActivityItem("25 min", "Vaqt", Icons.timer_rounded, Colors.orange),
                _buildActivityItem("2", "O'yin", Icons.videogame_asset_rounded, Colors.purple),
                _buildActivityItem("85%", "Ball", Icons.trending_up_rounded, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: AppTheme.successColor, size: 20),
                SizedBox(width: 8),
                Text("Bugungi vazifalar bajarildi!",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(val,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildScreenTimeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bugungi ekran vaqti",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text("25 minut / 60 minut",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Switch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 25 / 60,
                backgroundColor: Colors.grey[200],
                color: Colors.teal,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            const Text("Ruxsat berilgan vaqt: 60 daqiqa/kun",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification(
      String title, String body, String time, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(title[0], style: TextStyle(color: color)),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(body, style: const TextStyle(fontSize: 13)),
        trailing:
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }
}
