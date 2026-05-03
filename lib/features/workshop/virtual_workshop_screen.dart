import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'drawing_models.dart';

class VirtualWorkshopScreen extends StatefulWidget {
  const VirtualWorkshopScreen({super.key});

  @override
  State<VirtualWorkshopScreen> createState() => _VirtualWorkshopScreenState();
}

class _VirtualWorkshopScreenState extends State<VirtualWorkshopScreen> {
  // Elements
  List<DrawingPoint?> points = [];
  List<StickerNode> stickers = [];
  Color canvasBackgroundColor = Colors.white;
  
  // Undo/Redo Tracking
  List<String> actionHistory = []; 
  List<String> redoActionHistory = [];
  List<List<DrawingPoint?>> undoneStrokes = [];
  List<StickerNode> undoneStickers = [];

  // Tools
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  String? activeSticker; 
  String _activeTool = "Qalam"; // Qalam, Fon, Stiker
  
  // States
  bool isUploading = false;
  String? _base64Image;
  int _activeTab = 0; // 0: Ranglar (Qalam, Fon), 1: Stikerlar
  
  final ImagePicker _picker = ImagePicker();

  final List<Color> colors = [
    Colors.black, Colors.red, Colors.blue, Colors.green, Colors.yellow, 
    Colors.purple, Colors.orange, Colors.cyan, Colors.teal, Colors.pink, Colors.white
  ];

  final List<String> availableStickers = [
    // Tabiat
    "🌸", "🌻", "🌲", "🍀", "🍎", "🍓", "🍉",
    // Hayvonlar
    "🐶", "🐱", "🐰", "🦊", "🐻", "🐼", "🦁", "🐢", "🦋",
    // Koinot va Boshqa
    "⭐", "🌟", "🌙", "☀️", "🚀", "🛸", "🌍",
    // Transport va Buyumlar
    "🚗", "✈️", "🚢", "🎈", "🎁", "🎨", "⚽",
    // Qahramonlar
    "🤖", "👽", "👻", "🦄", "👑"
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint("Xatolik: $e");
    }
  }

  void _clearRedo() {
    redoActionHistory.clear();
    undoneStrokes.clear();
    undoneStickers.clear();
  }

  void _undo() {
    setState(() {
      if (actionHistory.isEmpty) return;
      String lastAction = actionHistory.removeLast();
      redoActionHistory.add(lastAction);
      
      if (lastAction == 'sticker') {
        undoneStickers.add(stickers.removeLast());
      } else if (lastAction == 'stroke') {
        List<DrawingPoint?> removedStroke = [];
        if (points.isNotEmpty && points.last == null) removedStroke.add(points.removeLast());
        while (points.isNotEmpty && points.last != null) removedStroke.insert(0, points.removeLast());
        undoneStrokes.add(removedStroke);
      } else if (lastAction == 'background') {
        // Fon rangini hozircha undo qilinishi oddiy oq rangga qaytaradi
        canvasBackgroundColor = Colors.white;
      }
    });
  }

  void _redo() {
    setState(() {
      if (redoActionHistory.isEmpty) return;
      String lastUndo = redoActionHistory.removeLast();
      actionHistory.add(lastUndo);
      
      if (lastUndo == 'sticker') {
        stickers.add(undoneStickers.removeLast());
      } else if (lastUndo == 'stroke') {
        points.addAll(undoneStrokes.removeLast());
      }
    });
  }

  void _submitArtwork() async {
    if (points.isEmpty && _base64Image == null && stickers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avval chizing, rasm yuklang yoki stiker qo'ying!")));
      return;
    }

    setState(() => isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User mavjud emas");

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final username = userDoc.data()?['username'] ?? "Noma'lum O'quvchi";
      final grade = userDoc.data()?['grade'] ?? 1;

      List<Map<String, dynamic>> serializedPoints = [];
      for (var p in points) {
        if (p != null) {
          serializedPoints.add({'dx': p.offset.dx, 'dy': p.offset.dy, 'color': p.paint.color.value, 'width': p.paint.strokeWidth});
        } else {
          serializedPoints.add({'isNull': true});
        }
      }
      
      List<Map<String, dynamic>> serializedStickers = [];
      for (var s in stickers) {
        serializedStickers.add({
          'dx': s.offset.dx, 'dy': s.offset.dy, 'emoji': s.emoji, 
          'scale': s.scale, 'rotation': s.rotation
        });
      }

      await FirebaseFirestore.instance.collection('artworks').add({
        'userId': user.uid,
        'userName': username,
        'grade': grade,
        'bgColor': canvasBackgroundColor.value,
        'pointsData': jsonEncode(serializedPoints),
        'stickersData': jsonEncode(serializedStickers),
        'imageBase64': _base64Image,
        'status': 'pending', 
        'likes': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 30), SizedBox(width: 10), Text("Ajoyib! 🎉")]),
            content: const Text("Sizning ijodiy ishingiz O'qituvchiga yuborildi. Barcha o'quvchilar Ko'rgazma bo'limida uni ko'ra oladilar!"),
            actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("Zo'r, qaytish!"))],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Afsuski nimadir xato: $e")));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  void _clearBoard() {
    setState(() {
      points.clear();
      stickers.clear();
      _base64Image = null;
      canvasBackgroundColor = Colors.white;
      _clearRedo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Virtual Ustaxona 🎨", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(icon: const Icon(Icons.undo_rounded, color: Colors.blueAccent), onPressed: actionHistory.isEmpty ? null : _undo),
          IconButton(icon: const Icon(Icons.redo_rounded, color: Colors.blueAccent), onPressed: redoActionHistory.isEmpty ? null : _redo),
          IconButton(icon: const Icon(Icons.add_photo_alternate, color: Colors.deepPurple), onPressed: _pickImage),
          IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.red), onPressed: _clearBoard),
        ],
      ),
      body: Column(
        children: [
          // CANVAS QISMI
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: canvasBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 20)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Fon yoki rasm
                    if (_base64Image != null)
                      Positioned.fill(
                        child: Opacity(opacity: 0.9, child: Image.memory(base64Decode(_base64Image!), fit: BoxFit.contain)),
                      ),
                    
                    // Asosiy chizadigan joy (GestureDetector panellari bilan eng orqada turadi)
                    Positioned.fill(
                      child: GestureDetector(
                        onTapDown: (details) {
                          if (_activeTool == "Fon") {
                             setState(() {
                               canvasBackgroundColor = selectedColor;
                               actionHistory.add('background');
                             });
                             return;
                          }
                          
                          if (_activeTool == "Stiker" && activeSticker != null) {
                            _clearRedo();
                            setState(() {
                              stickers.add(StickerNode(
                                emoji: activeSticker!,
                                offset: Offset(details.localPosition.dx - 25, details.localPosition.dy - 25) // Markazroqqa tushishi uchun
                              ));
                              actionHistory.add('sticker');
                              activeSticker = null; // Avto-chiqish qoidasi!
                              _activeTool = "Qalam"; // Asosiy holatga qaytish
                              _activeTab = 0;
                            });
                          } else if (_activeTool == "Qalam") {
                            _clearRedo();
                            setState(() {
                              points.add(DrawingPoint(
                                details.localPosition,
                                Paint()..strokeCap = StrokeCap.round..isAntiAlias = true..color = selectedColor..strokeWidth = strokeWidth,
                              ));
                            });
                          }
                        },
                        onPanUpdate: (details) {
                          if (_activeTool != "Qalam") return;
                          setState(() {
                            points.add(DrawingPoint(
                              details.localPosition,
                              Paint()..strokeCap = StrokeCap.round..color = selectedColor..strokeWidth = strokeWidth,
                            ));
                          });
                        },
                        onPanEnd: (details) {
                          if (_activeTool != "Qalam") return;
                          setState(() {
                            points.add(null);
                            actionHistory.add('stroke');
                          });
                        },
                        child: CustomPaint(
                          painter: DrawingPainter(pointsList: points),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),

                    // Obyektlashtirilgan stikerlar (Scale & Rotate & Drag imkoni)
                    ...List.generate(stickers.length, (i) {
                      final s = stickers[i];
                      return Positioned(
                        left: s.offset.dx,
                        top: s.offset.dy,
                        child: GestureDetector(
                          onScaleStart: (details) {
                            setState(() {
                              s.initialScale = s.scale;
                              s.initialRotation = s.rotation;
                            });
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              // Surish, kattalashtirish va burish bittada ishlaydi
                              s.offset += details.focalPointDelta;
                              s.scale = s.initialScale * details.scale;
                              s.rotation = s.initialRotation + details.rotation;
                            });
                          },
                          child: Transform.rotate(
                            angle: s.rotation,
                            child: Transform.scale(
                              scale: s.scale,
                              child: Text(s.emoji, style: const TextStyle(fontSize: 50, decoration: TextDecoration.none)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // PASTKI BOSHQARUV PANELI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildToolsTab("Qalam", Icons.brush, "Qalam"),
                      _buildToolsTab("Fon", Icons.format_paint_rounded, "Fon"),
                      _buildToolsTab("Stiker", Icons.emoji_emotions, "Stiker"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    height: 50,
                    child: _activeTool == "Stiker" ? _buildStickersList() : _buildColorsList(),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUploading ? Colors.grey : AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: isUploading ? null : _submitArtwork,
                      icon: isUploading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.send_rounded, color: Colors.white),
                      label: Text(
                        isUploading ? "Yuborilmoqda..." : "Yaratilgan ishlarni ulashish", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsTab(String modeName, IconData icon, String activeValue) {
    bool isSel = _activeTool == activeValue;
    return GestureDetector(
      onTap: () => setState(() {
        _activeTool = activeValue;
        if (activeValue == "Stiker") _activeTab = 1; else _activeTab = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSel ? Colors.blue : Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text(modeName, style: TextStyle(color: isSel ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: colors.map((color) {
          bool isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () => setState(() => selectedColor = color),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade300, width: isSelected ? 3 : 1),
                boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)] : [],
              ),
              child: color == Colors.white ? const Icon(Icons.cleaning_services, size: 18, color: Colors.grey) : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickersList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: availableStickers.map((emoji) {
          bool isSelected = activeSticker == emoji;
          return GestureDetector(
            onTap: () => setState(() => activeSticker = emoji),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
