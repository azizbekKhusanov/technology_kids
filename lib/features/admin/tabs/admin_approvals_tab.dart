import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../../services/admin_logger.dart';
import '../../workshop/drawing_models.dart';

class AdminApprovalsTab extends StatefulWidget {
  const AdminApprovalsTab({super.key});

  @override
  State<AdminApprovalsTab> createState() => _AdminApprovalsTabState();
}

class _AdminApprovalsTabState extends State<AdminApprovalsTab> {

  void _updateStatus(String docId, String newStatus) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('artworks').doc(docId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final author = data?['userName'] ?? "Noma'lum O'quvchi";
      final title = data?['title'] ?? "Mening ijodiy ishim";
      final statusLabel = newStatus == 'approved' ? "tasdiqladi" : "rad etdi";

      await FirebaseFirestore.instance.collection('artworks').doc(docId).update({
        'status': newStatus
      });

      await AdminLogger.log(
        actionType: newStatus == 'approved' ? 'artwork_approved' : 'artwork_rejected',
        description: "$author'ning '$title' nomli rasmini $statusLabel",
      );
    } catch(e) {
      debugPrint("Moderatsiya o'zgartirishda xato: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Faqat pending holatdagilarni tinglaymiz
      stream: FirebaseFirestore.instance.collection('artworks').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Xato: ${snapshot.error}"));
        
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
           return const Center(child: Text("Tekshirish uchun yangi ishlar yo'q! Barchasi tasdiqlangan.", style: TextStyle(color: Colors.grey, fontSize: 16)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          itemCount: docs.length,
          itemBuilder: (ctx, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            String author = data['userName'] ?? "Noma'lum O'quvchi";
            int grade = data['grade'] ?? 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                   ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.pending_actions, color: Colors.white)),
                    title: Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("$grade-sinf - Tasdiqlashingizni kutmoqda"),
                  ),
                  
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: data['bgColor'] != null ? Color(data['bgColor']) : Colors.white,
                    child: ClipRRect(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 1.2,
                          child: _buildArtworkRenderer(data),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
                            icon: const Icon(Icons.close),
                            label: const Text("Rad etish"),
                            onPressed: () => _updateStatus(doc.id, 'rejected'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            icon: const Icon(Icons.check),
                            label: const Text("Tasdiqlash"),
                            onPressed: () => _updateStatus(doc.id, 'approved'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArtworkRenderer(Map<String, dynamic> data) {
    List<DrawingPoint?> points = [];
    if(data['pointsData'] != null) {
      List<dynamic> rawPoints = jsonDecode(data['pointsData']);
      for(var p in rawPoints) {
         if(p['isNull'] == true) { points.add(null); } 
         else { points.add(DrawingPoint(Offset(p['dx'].toDouble(), p['dy'].toDouble()), Paint()..color = Color(p['color'])..strokeWidth = p['width'].toDouble()..strokeCap = StrokeCap.round));}
      }
    }
    
    List<StickerNode> stickers = [];
    if(data['stickersData'] != null) {
      List<dynamic> rawStickers = jsonDecode(data['stickersData']);
      for(var s in rawStickers) { stickers.add(StickerNode(emoji: s['emoji'], offset: Offset(s['dx'].toDouble(), s['dy'].toDouble()), scale: s['scale'].toDouble(), rotation: s['rotation'].toDouble()));}
    }

    String? base64img = data['imageBase64'];

    return Stack(
      children: [
        if (base64img != null) Positioned.fill(child: Opacity(opacity: 0.9, child: Image.memory(base64Decode(base64img), fit: BoxFit.contain))),
        CustomPaint(painter: DrawingPainter(pointsList: points), child: Container()),
        ...stickers.map((s) => Positioned(left: s.offset.dx, top: s.offset.dy, child: Transform.rotate(angle: s.rotation, child: Transform.scale(scale: s.scale, child: Text(s.emoji, style: const TextStyle(fontSize: 50, decoration: TextDecoration.none))))))
      ],
    );
  }
}
