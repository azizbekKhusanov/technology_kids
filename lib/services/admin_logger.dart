import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> log({
    required String actionType,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operatorName = prefs.getString('adminFullName') ?? 'Munisa Raximova';
      final operatorUser = prefs.getString('adminUsername') ?? 'munisa_admin_04';

      await _firestore.collection('admin_logs').add({
        'actionType': actionType,
        'description': description,
        'operatorName': operatorName,
        'operatorUser': operatorUser,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Fail silently or print in debug
      print("AdminLogger Error: $e");
    }
  }
}
