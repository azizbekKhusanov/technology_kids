import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  int _selectedAvatarIndex = 0;
  int _selectedGrade = 1;
  bool _isLoading = false;

  final List<String> _avatars = [
    '🐶', '🐱', '🦊', '🐻', '🐼', '🐯', '🦁', '🐮',
    '🐷', '🐸', '🐵', '🐔', '🐧', '🦉', '🦄', '🦖',
    '🐕', '🐈', '🐆', '🦓', '🦒', '🦘', '🐴', '🐑',
    '🐐', '🦅', '🦆', '🐢', '🐙', '🦕', '🐝', '🦋'
  ];

  void _register() async {
    final username = _nameController.text.trim();
    final pin = _pinController.text.trim();
    final secret = _secretController.text.trim();

    if (username.isEmpty || pin.length != 4 || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, barcha maydonlarni to'ldiring! PIN 4 xonali bo'lishi shart.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final error = await _authService.registerWithUsername(
      username: username,
      pin: pin,
      grade: _selectedGrade,
      avatar: _avatars[_selectedAvatarIndex],
      secretAnswer: secret,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor));
      }
    } else {
      if(mounted) {
        Navigator.pop(context); // Go back to login/home
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 24),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Text(
                "Qahramonni tanlang",
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_avatars.length, (index) {
                      final isSelected = _selectedAvatarIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedAvatarIndex = index);
                          Navigator.pop(context); // Menyu yopiladi
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : Colors.grey.shade50,
                            border: Border.all(
                              color: isSelected ? AppTheme.accentColor : Colors.grey.shade200,
                              width: isSelected ? 4 : 2,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(color: AppTheme.accentColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
                            ] : [],
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.transparent,
                            child: Text(_avatars[index], style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Profil yaratish", style: Theme.of(context).textTheme.displayMedium),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sizning qahramoningiz:",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Column(
                        children: [
                          // 1-QATOR (5 ta avatar)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: List.generate(5, (i) {
                              int avatarIndex = i;
                              final isSelected = _selectedAvatarIndex == avatarIndex;
                              
                              return GestureDetector(
                                onTap: () => setState(() => _selectedAvatarIndex = avatarIndex),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : Colors.grey.shade50,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.accentColor : Colors.grey.shade200,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(color: AppTheme.accentColor.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)
                                    ] : [],
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.transparent,
                                    child: Text(_avatars[avatarIndex], style: const TextStyle(fontSize: 32)),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          // 2-QATOR (4 ta avatar + 1 ta Boshqalar tugmasi)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ...List.generate(4, (i) {
                                int avatarIndex = i + 5; // 5 dan 8 gacha
                                // Agar tanlangan avatar 8 tadan katta bo'lsa, to'qqizinchi pozitsiya (index 8) da uni ko'rsatamiz
                                if (i == 3 && _selectedAvatarIndex > 8) {
                                  avatarIndex = _selectedAvatarIndex;
                                }
                                final isSelected = _selectedAvatarIndex == avatarIndex;
                                
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedAvatarIndex = avatarIndex),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : Colors.grey.shade50,
                                      border: Border.all(
                                        color: isSelected ? AppTheme.accentColor : Colors.grey.shade200,
                                        width: isSelected ? 3 : 2,
                                      ),
                                      boxShadow: isSelected ? [
                                        BoxShadow(color: AppTheme.accentColor.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)
                                      ] : [],
                                    ),
                                    child: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Colors.transparent,
                                      child: Text(_avatars[avatarIndex], style: const TextStyle(fontSize: 32)),
                                    ),
                                  ),
                                );
                              }),
                              
                              // 10-O'RIN: KO'PROQ TUGMASI (More)
                              GestureDetector(
                                onTap: _showAvatarPicker,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade300, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.grey.shade50,
                                    child: const Icon(Icons.apps_rounded, color: Colors.grey, size: 28),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Ismingizni yozing",
                      hintText: "Masalan: Aziza",
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sinfingizni tanlang:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3, 4].map((grade) {
                      final isSelected = _selectedGrade == grade;
                      return ChoiceChip(
                        label: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text("$grade-sinf"),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedGrade = grade);
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "4 xonali maxfiy parol (PIN)",
                      hintText: "Masalan: 1234",
                      prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _secretController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _register(),
                    decoration: const InputDecoration(
                      labelText: "Maxfiy savol: Eng yoqtirgan hayvon qaysi?",
                      hintText: "Masalan: Mushuk",
                      prefixIcon: Icon(Icons.pets, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text("Ro'yxatdan O'tish"),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

