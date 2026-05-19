import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/admin_exhibition_tab.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_students_tab.dart';
import 'tabs/admin_lessons_tab.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_logger.dart';
import 'admin_logs_screen.dart';

import '../../main.dart'; // AuthWrapper uchun



class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _autoApprove = false;
  bool _notificationsEnabled = true;
  bool _fastCaching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('adminUsername') ?? 'munisa_admin_04';
      _fullNameController.text = prefs.getString('adminFullName') ?? 'Munisa Raximova';
      _phoneController.text = prefs.getString('adminPhone') ?? '+998 90 123 45 67';
      _autoApprove = prefs.getBool('autoApproveArtworks') ?? false;
      _notificationsEnabled = prefs.getBool('adminNotifications') ?? true;
      _fastCaching = prefs.getBool('adminFastCaching') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveAdminData() async {
    if (_usernameController.text.trim().isEmpty || 
        _fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Barcha maydonlarni to'g'ri to'ldiring!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminUsername', _usernameController.text.trim());
    await prefs.setString('adminFullName', _fullNameController.text.trim());
    await prefs.setString('adminPhone', _phoneController.text.trim());
    await prefs.setBool('autoApproveArtworks', _autoApprove);
    await prefs.setBool('adminNotifications', _notificationsEnabled);
    await prefs.setBool('adminFastCaching', _fastCaching);

    await AdminLogger.log(
      actionType: 'settings_updated',
      description: "Admin shaxsiy ma'lumotlari yoki tizim sozlamalarini yangiladi",
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Admin sozlamalari muvaffaqiyatli saqlandi! 💾"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tizimdan chiqish"),
        content: const Text("Haqiqatan ham chiqmoqchimisiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('isAdmin');
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthWrapper()), (r) => false);
            },
            child: const Text("Ha, chiqish"),
          )
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFEEEDFE), shape: BoxShape.circle),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF4F46E5), size: 40),
              ),
              const SizedBox(height: 16),
              const Text("Texno Bilim", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Admin Panel · v1.0.0", style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              const Text(
                "Texno Bilim — boshlangʼich sinf (1–4-sinflar) oʼquvchilari uchun texnologiya fanini interaktiv tarzda oʼrgatuvchi mobil ilova. Admin panel orqali barcha kontent va foydalanuvchilar boshqariladi.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildAboutRow(Icons.school_rounded, "Darslarni boshqarish", const Color(0xFF4F46E5)),
              _buildAboutRow(Icons.people_alt_rounded, "O'quvchilarni nazorat qilish", const Color(0xFF1D9E75)),
              _buildAboutRow(Icons.collections_rounded, "Ko'rgazmani tasdiqlash", const Color(0xFFD85A30)),
              _buildAboutRow(Icons.campaign_rounded, "E'lonlar tarqatish", const Color(0xFFBA7517)),
              const SizedBox(height: 20),
              const Text("TATU · Diplom loyihasi · 2025", style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Tushunarli", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAdminDialog() {
    final fullNameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF2E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.orange,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Yangi Admin Qo'shish",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Tizimga yangi administrator hisobini qo'shish",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(fullNameCtrl, "Ism va Familiya", Icons.badge_rounded),
                  _buildTextField(usernameCtrl, "Foydalanuvchi nomi (Username)", Icons.alternate_email_rounded),
                  _buildTextField(phoneCtrl, "Telefon raqami", Icons.phone_android_rounded),
                  _buildTextField(pinCtrl, "4 xonali PIN Kod", Icons.lock_outline_rounded, obscure: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: isSaving ? null : () => Navigator.pop(ctx),
                          child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final fullName = fullNameCtrl.text.trim();
                                  final username = usernameCtrl.text.trim();
                                  final phone = phoneCtrl.text.trim();
                                  final pin = pinCtrl.text.trim();

                                  if (fullName.isEmpty || username.isEmpty || pin.length != 4) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Barcha maydonlarni to'ldiring (PIN 4 xonali bo'lishi shart)!"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSaving = true);

                                  try {
                                    // Check if duplicate
                                    final duplicate = await FirebaseFirestore.instance
                                        .collection('admins')
                                        .doc(username)
                                        .get();
                                    if (duplicate.exists) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Ushbu username band! Boshqa username tanlang."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      setDialogState(() => isSaving = false);
                                      return;
                                    }

                                    // Save new admin to Firestore
                                    await FirebaseFirestore.instance.collection('admins').doc(username).set({
                                      'username': username,
                                      'pin': pin,
                                      'fullName': fullName,
                                      'phone': phone,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                    // Add log
                                    await AdminLogger.log(
                                      actionType: 'admin_added',
                                      description: "Yangi administrator qo'shildi: $fullName (@$username)",
                                    );

                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Admin ($fullName) muvaffaqiyatli qo'shildi! 🎖️"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setDialogState(() => isSaving = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Xatolik yuz berdi: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Qo'shish", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          filled: true,
          fillColor: Colors.blueGrey.shade50.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const indigoColor = Color(0xFF4F46E5);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 — Admin identity card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: indigoColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.supervised_user_circle_rounded,
                      color: indigoColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullNameController.text.isNotEmpty 
                              ? _fullNameController.text 
                              : "Administrator",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "@${_usernameController.text}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: indigoColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "✓  Bosh Administrator",
                            style: TextStyle(
                              color: indigoColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2 — Edit Form Card
            const Text(
              "Shaxsiy ma'lumotlar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_fullNameController, "Ism va Familiya", Icons.badge_rounded),
                  _buildTextField(_usernameController, "Foydalanuvchi nomi (Username)", Icons.alternate_email_rounded),
                  _buildTextField(_phoneController, "Telefon raqami", Icons.phone_android_rounded),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: indigoColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveAdminData,
                      icon: const Icon(Icons.save_rounded, size: 20),
                      label: const Text("O'zgarishlarni saqlash", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3 — System Preferences
            const Text(
              "Tizim sozlamalari",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text("Ijodiy ishlarni avtomatik tasdiqlash", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                    subtitle: const Text("O'quvchilar yuklagan rasmlar qo'lda tasdiqlashsiz darhol chop etiladi", style: TextStyle(fontSize: 10)),
                    value: _autoApprove,
                    activeColor: indigoColor,
                    onChanged: (v) => setState(() => _autoApprove = v),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile.adaptive(
                    title: const Text("Tizim bildirishnomalari", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                    subtitle: const Text("Yangi ijodiy ishlar va faolliklar haqida bildirishnoma olish", style: TextStyle(fontSize: 10)),
                    value: _notificationsEnabled,
                    activeColor: indigoColor,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile.adaptive(
                    title: const Text("Tezkor kesh rejimi", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                    subtitle: const Text("Dars kontentlarini offline rejim uchun saqlash orqali tez yuklash", style: TextStyle(fontSize: 10)),
                    value: _fastCaching,
                    activeColor: indigoColor,
                    onChanged: (v) => setState(() => _fastCaching = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4 — More Settings
            const Text(
              "Qo'shimcha",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              "Ilova haqida",
              Icons.info_outline_rounded,
              Colors.indigo,
              _showAboutDialog,
            ),
            _buildMenuTile(
              "Yangi admin qo'shish",
              Icons.person_add_alt_1_rounded,
              Colors.orange,
              _showAddAdminDialog,
            ),
            _buildMenuTile(
              "Tizim logi",
              Icons.terminal_rounded,
              Colors.grey,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLogsScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 5 — Logout button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "Tizimdan chiqish",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
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
