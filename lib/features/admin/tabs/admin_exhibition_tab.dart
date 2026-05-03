import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../workshop/drawing_models.dart';
import 'admin_approvals_tab.dart'; // import approvals body

class AdminExhibitionTab extends StatefulWidget {
  final int initialTabIndex;
  const AdminExhibitionTab({super.key, this.initialTabIndex = 0});

  @override
  State<AdminExhibitionTab> createState() => _AdminExhibitionTabState();
}

class _AdminExhibitionTabState extends State<AdminExhibitionTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: "Tasdiqlash (Kutilyapti)", icon: Icon(Icons.pending_actions)),
              Tab(text: "Umumiy Ko'rgazma", icon: Icon(Icons.public)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const AdminApprovalsTab(),
              const _AdminGlobalExhibitionList(),
            ],
          ),
        ),
      ],
    );
  }
}

// Global ko'rgazmani ko'rsatish
class _AdminGlobalExhibitionList extends StatelessWidget {
  const _AdminGlobalExhibitionList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('artworks').where('status', isEqualTo: 'approved').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Xatolik: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Ko'rgazmada asarlar yo'q."));

        final publicDocs = snapshot.data!.docs.toList();
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
          itemBuilder: (ctx, index) => _AdminArtworkCard(publicDocs[index]),
        );
      },
    );
  }
}

class _AdminArtworkCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _AdminArtworkCard(this.doc);

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    String author = data['userName'] ?? "Noma'lum";
    int grade = data['grade'] ?? 1;
    int likes = data['likes'] ?? 0;
    
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
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Asarni o'chirish",
                  onPressed: () => _deleteArtwork(context, doc.id),
                )
              ],
            ),
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
                  )
                ),
             ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Text("$likes ta yulduzcha", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _deleteArtwork(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish", style: TextStyle(color: Colors.red)),
        content: const Text("Haqiqatan ham bu asarni ko'rgazmadan o'chirasizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Yo'q")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('artworks').doc(docId).delete();
            },
            child: const Text("O'chirish"),
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
        if (base64img != null) Positioned.fill(child: Opacity(opacity: 0.9, child: Image.memory(base64Decode(base64img), fit: BoxFit.contain))),
        CustomPaint(painter: DrawingPainter(pointsList: points), child: Container()),
        ...stickers.map((s) => Positioned(
           left: s.offset.dx, top: s.offset.dy,
           child: Transform.rotate(angle: s.rotation, child: Transform.scale(scale: s.scale, child: Text(s.emoji, style: const TextStyle(fontSize: 50, decoration: TextDecoration.none))))
        ))
      ],
    );
  }
}
