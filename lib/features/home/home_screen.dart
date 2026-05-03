import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "O'quvchi";
  int _selectedGrade = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['username'] ?? "O'quvchi";
          _selectedGrade = doc.data()?['grade'] ?? 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Oq va toza fon
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tepa qism: Salomlashish
              // 1. Tepa qism: KidTech Brending
              Row(
                children: [
                   Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('images/base_image.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "KidTech",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Salom, $_userName! 👋",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Katta Banner (Hero qism)
              _buildHeroBanner(),
              const SizedBox(height: 24),

              // 3. Joriy Statistika (Progress)
              _buildProgressCard(),
              const SizedBox(height: 30),

              // 4. Sinf Tanlash
              const Text(
                "Sinfni Tanlang",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildGradeSelector(),
              const SizedBox(height: 30),

              // 5. Tavsiya etilgan dars / Eng mashhur
              _buildFeaturedCard(),
              const SizedBox(height: 30), // Pastki navbar uchun bo'sh joy
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A34D3), Color(0xFF8344E0)], // Bantning chiroyli binafsharang gradienti
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
             color: const Color(0xFF4A34D3).withOpacity(0.4),
             blurRadius: 15,
             offset: const Offset(0, 8),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Qog'oz Sehrini\nKashf Et!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Bugun qaysi shaklni yasaymiz?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ajoyib boshlash! Davom eting!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "12 dars qoldi",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.2, // 20%
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "20%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        int grade = 4 - index; // 4, 3, 2, 1 ketma ketligi
        bool isSelected = _selectedGrade == grade;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedGrade = grade;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: MediaQuery.of(context).size.width * 0.18,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ] : [],
            ),
            child: Column(
              children: [
                Text(
                  "$grade",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Sinf",
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      width: double.infinity,
      height: 200, // Vaqtincha hajm
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Ichki dizayn yoki rasm
          const Positioned.fill(
            child: Center(
               child: Icon(Icons.flight_takeoff, size: 100, color: Colors.deepPurple)
            )
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: const Text("OSON", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text("MASHHUR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
