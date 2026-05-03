import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Xush kelibsiz!",
      description: "TexnoBilim bilan texnologiya fanini qiziqarli o'rganing.",
      color: AppTheme.primaryColor,
      icon: Icons.school_rounded,
    ),
    OnboardingData(
      title: "Interaktiv darslar",
      description: "Har bir darsni bosqichma-bosqich, o'yin tarzida bajaring.",
      color: AppTheme.accentColor,
      icon: Icons.extension_rounded,
    ),
    OnboardingData(
      title: "Yutuqlar va mukofotlar",
      description: "Vazifalarni bajarib, yulduzchalar va nishonlar to'plang!",
      color: AppTheme.successColor,
      icon: Icons.emoji_events_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(data: _pages[index]);
            },
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Next Button
                FloatingActionButton.extended(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  label: Text(_currentPage == _pages.length - 1 ? "Boshlash" : "Keyingisi"),
                  icon: Icon(_currentPage == _pages.length - 1 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 120,
              color: data.color,
            ),
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
