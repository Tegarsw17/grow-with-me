import 'package:flutter/material.dart';
import 'package:grow_with_me/core/widgets/bottom_navigation.dart';
import 'package:grow_with_me/core/widgets/top_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeScreen extends StatefulWidget {
  final String uid;
  const WardrobeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _inventoryStream;
  late DocumentReference<Map<String, dynamic>> _inventoryRef;

  @override
  void initState() {
    super.initState();
    _inventoryRef = FirebaseFirestore.instance
        .collection('inventory')
        .doc(widget.uid) as DocumentReference<Map<String, dynamic>>;
    _initInventoryStream();
  }

  Future<void> _initInventoryStream() async {
    _inventoryStream = _inventoryRef.snapshots();
  }

  Future<void> _handleGunakan(String imageId) async {
    try {
      // Update the 'equiped' field for the current item to true
      await _inventoryRef.update({
        'items.$imageId.equiped': true,
      });

      // Update the 'equiped' field for all other items to false
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _inventoryRef.get();
      Map<String, dynamic> updatedItems = {};
      if (snapshot.data() != null) {
        (snapshot.data()!['items'] as Map<String, dynamic>)
            .forEach((key, value) {
          if (key != imageId) {
            updatedItems['items.$key.equiped'] = false;
          }
        });
      }
      await _inventoryRef.update(updatedItems);
    } catch (e) {
      // Handle error
      print('Error updating inventory: $e');
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _inventoryStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return const Text('Error loading data');
                        }
                        if (snapshot.hasData && snapshot.data!.data() != null) {
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.4,
                              viewportFraction: 0.8,
                            ),
                            items: (snapshot.data!.data()!['items']
                                    as Map<String, dynamic>)
                                .keys
                                .map((imageId) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Image.asset(
                                        'images/${snapshot.data!.data()!['items'][imageId]['name']}',
                                        fit: BoxFit.contain,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.5),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${snapshot.data!.data()!['items'][imageId]['price'].toString()}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _handleGunakan(imageId);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Gunakan',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              BottomBar(
                uid: widget.uid,
                currentScreen: 'profile',
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
