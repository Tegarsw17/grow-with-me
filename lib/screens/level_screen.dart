import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grow_with_me/core/widgets/bottom_navigation.dart';
import 'package:grow_with_me/screens/quiz_screen.dart';
import 'package:grow_with_me/core/widgets/top_widget.dart';

// Level Selection Screen
class LevelSelectionScreen extends StatelessWidget {
  final String uid;
  final String subjectName;
  final String subjectId;

  const LevelSelectionScreen(
      {Key? key,
      required this.uid,
      required this.subjectName,
      required this.subjectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top section with score and name
              TopWidget(uid: uid),
              const SizedBox(height: 24),

              // Level text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4F1D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subjectName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Grid of level buttons
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('levelProgress')
                      .doc(subjectId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Handle loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Handle error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    // Get the level progress data
                    final levelProgressData =
                        snapshot.data?.data() as Map<String, dynamic>? ?? {};

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('subjects')
                          .doc(subjectId)
                          .collection('levels')
                          .snapshots(),
                      builder: (context, levelsSnapshot) {
                        // Handle loading state for levels
                        if (levelsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        // Handle error state for levels
                        if (levelsSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${levelsSnapshot.error}'),
                          );
                        }

                        // Get the levels
                        final levels = levelsSnapshot.data?.docs ?? [];

                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: levels.length,
                            itemBuilder: (context, index) {
                              // Get the level document
                              final levelDoc = levels[index];
                              final levelNumber = index + 1;
                              final levelId = levelDoc.id;

                              // Check if the level is completed
                              final isCompleted = levelProgressData[levelId]
                                      ?['isCompleted'] ??
                                  false;

                              return LevelButton(
                                levelNumber: levelNumber,
                                isCompleted: isCompleted,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizQuestionScreen(
                                        uid: uid,
                                        subjectName: subjectName,
                                        subjectId: subjectId,
                                        levelId: levelId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Bottom navigation bar
              BottomBar(
                uid: uid,
                currentScreen: 'subjects',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int levelNumber;
  final bool isCompleted; // New parameter to check completion status
  final VoidCallback onTap;

  const LevelButton({
    Key? key,
    required this.levelNumber,
    required this.isCompleted,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF9AAD9C)
                : const Color(0xFFD4F1D8)
                    .withOpacity(0.8), // Change color based on completion
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              levelNumber.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comic Sans MS',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
