import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../workshop/drawing_models.dart';

class ExhibitionScreen extends StatefulWidget {
  const ExhibitionScreen({super.key});

  @override
  State<ExhibitionScreen> createState() => _ExhibitionScreenState();
}

class _ExhibitionScreenState extends State<ExhibitionScreen> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _likeArtwork(String docId, List<dynamic> likedBy) async {
    if (currentUserId == null) return;
    try {
      final docRef = FirebaseFirestore.instance.collection('artworks').doc(docId);
      if (likedBy.contains(currentUserId)) {
        await docRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        await docRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([currentUserId])
        });
      }
    } catch(e) {
      debugPrint("Liking failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Umumiy Ko'rgazma 🌍", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('artworks').where('status', isEqualTo: 'approved').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Xatolik yuz berdi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Hozircha ko'rgazmada asarlar yo'q.", style: TextStyle(fontSize: 16)));
          }

          final publicDocs = snapshot.data!.docs.toList();
          
          // Firebase index errorning oldini olish uchun sort ni Dart'da qilamiz
          publicDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final t1 = dataA['createdAt'] as Timestamp?;
            final t2 = dataB['createdAt'] as Timestamp?;
            if (t1 == null && t2 == null) return 0;
            if (t1 == null) return 1;
            if (t2 == null) return -1;
            return t2.compareTo(t1); // descending
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            itemCount: publicDocs.length,
            itemBuilder: (ctx, index) => _buildArtworkCard(publicDocs[index]),
          );
        },
      ),
    );
  }

  Widget _buildArtworkCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String author = data['userName'] ?? "Noma'lum";
    int grade = data['grade'] ?? 1;
    int likes = data['likes'] ?? 0;
    List<dynamic> likedBy = data['likedBy'] ?? [];
    bool isLiked = currentUserId != null && likedBy.contains(currentUserId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.primaries[author.length % Colors.primaries.length],
                  child: Text(author[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("$grade - sinf o'quvchisi", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ARTWORK KANVASI QISMI
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
                  )
                ),
             ),
          ),
          
          // LIKE TUGMASI QISMI
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ActionChip(
                  avatar: Icon(isLiked ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.orange),
                  label: Text("$likes ta Yulduzcha", style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: isLiked ? Colors.orange.shade100 : Colors.orange.shade50,
                  side: BorderSide.none,
                  onPressed: () => _likeArtwork(doc.id, likedBy),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.grey), 
                  onPressed: () {
                    Share.share("Texno Bilim ilovasida $author ning ajoyib ishlari bilan tanishing! Ilovani hoziroq yuklab oling.");
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArtworkRenderer(Map<String, dynamic> data) {
    List<DrawingPoint?> points = [];
    if(data['pointsData'] != null) {
      List<dynamic> rawPoints = jsonDecode(data['pointsData']);
      for(var p in rawPoints) {
         if(p['isNull'] == true) {
           points.add(null);
         } else {
           points.add(DrawingPoint(
             Offset(p['dx'].toDouble(), p['dy'].toDouble()),
             Paint()..color = Color(p['color'])..strokeWidth = p['width'].toDouble()..strokeCap = StrokeCap.round,
           ));
         }
      }
    }
    
    List<StickerNode> stickers = [];
    if(data['stickersData'] != null) {
      List<dynamic> rawStickers = jsonDecode(data['stickersData']);
      for(var s in rawStickers) {
         stickers.add(StickerNode(
           emoji: s['emoji'],
           offset: Offset(s['dx'].toDouble(), s['dy'].toDouble()),
           scale: s['scale'].toDouble(),
           rotation: s['rotation'].toDouble(),
         ));
      }
    }

    String? base64img = data['imageBase64'];

    return Stack(
      children: [
        if (base64img != null)
           Positioned.fill(
             child: Opacity(opacity: 0.9, child: Image.memory(base64Decode(base64img), fit: BoxFit.contain)),
           ),
           
        CustomPaint(
          painter: DrawingPainter(pointsList: points),
          child: Container(),
        ),
        
        ...stickers.map((s) => Positioned(
           left: s.offset.dx,
           top: s.offset.dy,
           child: Transform.rotate(
              angle: s.rotation,
              child: Transform.scale(
                scale: s.scale,
                child: Text(s.emoji, style: const TextStyle(fontSize: 50, decoration: TextDecoration.none)),
              ),
           )
        ))
      ],
    );
  }
}
