import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grow_with_me/core/widgets/bottom_navigation.dart';
import 'package:grow_with_me/core/widgets/top_widget.dart';
import 'package:grow_with_me/screens/level_screen.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  const HomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentImagePath = 'images/cactus-default.png';

  @override
  void initState() {
    super.initState();
    _fetchEquippedImage();
  }

  Future<void> _fetchEquippedImage() async {
    try {
      // Get the user's inventory document
      DocumentSnapshot inventoryDoc = await FirebaseFirestore.instance
          .collection('inventory')
          .doc(widget.uid)
          .get();

      // Check if the document exists and has items
      if (inventoryDoc.exists) {
        Map<String, dynamic>? items = inventoryDoc.get('items');

        if (items != null) {
          // Find the first equipped item
          String? equippedImageId = items.keys.firstWhere(
            (imageId) => items[imageId]['equiped'] == true,
            orElse: () => '',
          );

          if (equippedImageId.isNotEmpty) {
            // Fetch the image content from the store collection
            DocumentSnapshot storeDoc = await FirebaseFirestore.instance
                .collection('store')
                .doc(equippedImageId)
                .get();

            if (storeDoc.exists) {
              setState(() {
                _currentImagePath = 'images/${storeDoc.get('name')}';
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching equipped image: $e');
      // Fallback to default image if there's an error
      setState(() {
        _currentImagePath = 'images/cactus-default.png';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TopWidget(uid: widget.uid),
              Expanded(
                child: Center(
                  child: Image.asset(
                    _currentImagePath,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 280,
                      child: Text(
                        '"Jangan Menyerah Coba Sekali Lagi"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BottomBar(
                uid: widget.uid,
                currentScreen: 'home',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any controllers or listeners if added
    super.dispose();
  }
}
