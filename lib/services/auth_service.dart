import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Foydalanuvchi joriy holatini kuzatish
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Foydalanuvchini soxta email orqali ro'yxatdan o'tkazish
  Future<String?> registerWithUsername({
    required String username,
    required String pin,
    required int grade,
    required String avatar,
    required String secretAnswer,
  }) async {
    try {
      // 1. Ismni xavfsiz email prefixiga o'tkazish
      String safeName = username.toLowerCase();
      
      // Kirillcha harflar bo'lsa, lotinchaga almashtiramiz
      const cyrillicToLatin = {
        'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo', 'ж': 'zh',
        'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o',
        'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'x', 'ц': 'ts',
        'ч': 'ch', 'ш': 'sh', 'щ': 'shch', 'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
        'ў': 'o', 'қ': 'q', 'ғ': 'g', 'ҳ': 'h'
      };
      cyrillicToLatin.forEach((key, value) {
        safeName = safeName.replaceAll(key, value);
      });
      // Faqat lotin harflari va raqamlarni qoldiramiz, bo'shliqlarni olib tashlaymiz
      safeName = safeName.replaceAll(RegExp(r'[^a-z0-9]'), '');
      
      if (safeName.isEmpty) {
        safeName = "user_${DateTime.now().millisecondsSinceEpoch}";
      }

      final email = '$safeName@texnobilim.app';
      // Parolni 6 ta belgi qilish uchun orqasiga 00 xavfsizlik kodini qo'shamiz
      final password = '${pin}00';

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Ma'lumotlarni Firestore'ga saqlash
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'pin': pin, // Bolalar parolini unutsalar, uni bazadan olib ko'rsatamiz
          'grade': grade,
          'avatar': avatar,
          'secretAnswer': secretAnswer.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'student',
        });
        return null; // Xato yo'q
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Ushbu ism band! Boshqa ism tanlang yooki raqam qo'shing (masalan, Ali01).";
      } else if (e.code == 'operation-not-allowed') {
        return "Tizim xatosi: Firebase'da 'Email/Password' usuli yoqilmagan!";
      } else if (e.code == 'invalid-email') {
         return "Xatolik: Ismingiz qabul qilinmadi (mos emas).";
      } else if (e.code == 'configuration-not-found') {
        return "Firebase Authentication sozlanmagan! Firebase Console'da 'Get Started' qiling.";
      }
      return "Xatolik: kodi(${e.code}) ${e.message}";
    } catch (e) {
      return "Kutilmagan xatolik: ${e.toString()}";
    }
    return "Nomalum xatolik.";
  }

  // Tizimga kirish (Login)
  Future<String?> loginWithUsername({
    required String username,
    required String pin,
  }) async {
    try {
      final safeName = username.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      final email = '$safeName@texnobilim.app';
      final password = '${pin}00';

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Ism yoki PIN noto'g'ri!";
      }
      return "Tizimga kirishda xato: ${e.message}";
    } catch (e) {
      return "Kutilmagan xatolik.";
    }
  }

  // Parolni tiklash emas, uni "eslatish" (Maxfiy savol orqali)
  Future<String?> recoverPin({
    required String username,
    required String secretAnswer,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "Bunday ismli o'quvchi topilmadi!";
      }

      final doc = snapshot.docs.first;
      final savedAnswer = doc.data()['secretAnswer'] ?? '';

      if (savedAnswer.toString().toLowerCase() != secretAnswer.toLowerCase()) {
        return "Maxfiy savolga noto'g'ri javob berdingiz!";
      }

      final savedPin = doc.data()['pin'];
      if(savedPin != null) {
         return "Muvaffaqiyatli! Sizning PIN kodingiz: $savedPin. Endi uni unutmang!";
      } else {
         return "Kechirasiz, eski tizimda PIN saqlanmagan. Iltimos Yangi profil yarating!";
      }
      
    } catch (e) {
      return "Xatolik: ${e.toString()}";
    }
  }

  // Tizimdan chiqish
  Future<void> logout() async {
    await _auth.signOut();
  }
}
