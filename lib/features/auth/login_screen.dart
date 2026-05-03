import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../admin/admin_panel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    final username = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ismingiz va PIN kodingizni kiriting!")),
      );
      return;
    }

    if (username == "munisa_admin_04" && pin == "0101") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', true);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
      }
      return;
    }

    setState(() => _isLoading = true);

    final error = await _authService.loginWithUsername(
      username: username,
      pin: pin,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor));
      }
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final resetNameController = TextEditingController();
        final secretController = TextEditingController();
        bool isResetting = false;

        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Parolni Topish", style: TextStyle(color: AppTheme.primaryColor)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(
                    controller: resetNameController,
                    decoration: const InputDecoration(labelText: "Ismingizni tering"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: secretController,
                    decoration: const InputDecoration(labelText: "Sevimli hayvoningiz kim? (Maxfiy savol)"),
                  ),
                  const SizedBox(height: 10),
                  const Text("Agar to'g'ri topsangiz, biz sizning avvalgi parolingizni eslatamiz!", 
                     style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isResetting ? null : () async {
                   final n = resetNameController.text.trim();
                   final s = secretController.text.trim();
                   if(n.isEmpty || s.isEmpty) return;

                  setDialogState(() => isResetting = true);
                  final msg = await _authService.recoverPin(
                    username: n,
                    secretAnswer: s,
                  );
                  setDialogState(() => isResetting = false);
                  if(context.mounted) {
                     Navigator.pop(context);
                     // Xabarni uzunroq o'qib olinishi uchun Duration katta
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                       content: Text(msg ?? '', style: const TextStyle(fontSize: 16)), 
                       backgroundColor: msg!.contains("Muvaffaqiyatli") ? Colors.green : Colors.red,
                       duration: const Duration(seconds: 5),
                     ));
                  }
                },
                child: isResetting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Topish!"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   const Icon(Icons.rocket_launch_rounded, size: 80, color: AppTheme.accentColor),
                const SizedBox(height: 20),
                Text(
                  "Xush Kelibsiz!",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Darslarni davom ettirish uchun kiring",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Ismingiz",
                    prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                   controller: _pinController,
                   keyboardType: TextInputType.number,
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                   textInputAction: TextInputAction.done,
                   onSubmitted: (_) => _login(),
                   obscureText: true,
                   maxLength: 4,
                   decoration: const InputDecoration(
                    labelText: "4 xonali PIN kod",
                    prefixIcon: Icon(Icons.password, color: AppTheme.primaryColor),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text("Parolni unutdim", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text("Tizimga Kirish"),
                      ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hali profil yaratmadingizmi?", style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        "Yaratish",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
