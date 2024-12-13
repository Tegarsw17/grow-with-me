import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grow_with_me/core/widgets/bottom_navigation.dart';
import 'package:grow_with_me/core/widgets/top_widget.dart';
import 'package:grow_with_me/screens/level_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  final String uid;
  const SubjectSelectionScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _SubjectSelectionScreenState createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TopWidget(uid: widget.uid),

              const SizedBox(height: 32),

              // Subject list from Firebase
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('subjects')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF76BE80),
                        ),
                      );
                    }

                    final subjects = snapshot.data?.docs ?? [];

                    return ListView.separated(
                      itemCount: subjects.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final subject =
                            subjects[index].data() as Map<String, dynamic>;
                        final subjectName = subject['name'] as String;
                        final subjectId = subjects[index].id;

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4F1D8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LevelSelectionScreen(
                                      uid: widget.uid,
                                      subjectId: subjectId,
                                      subjectName: subjectName,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Text(
                                  subjectName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              BottomBar(uid: widget.uid, currentScreen: 'subjects'),
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
