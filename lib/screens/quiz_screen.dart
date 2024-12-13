import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grow_with_me/models/quiz_models.dart';
import 'package:grow_with_me/screens/level_screen.dart';
import 'package:grow_with_me/core/widgets/top_widget.dart';
import 'package:grow_with_me/core/widgets/bottom_navigation.dart';

// Taruh di model==============
class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizQuestion(
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? -1,
    );
  }
}

class QuizQuestionScreen extends StatefulWidget {
  final String uid;
  final String subjectName;
  final String subjectId;
  final String levelId;

  const QuizQuestionScreen(
      {Key? key,
      required this.uid,
      required this.subjectName,
      required this.subjectId,
      required this.levelId})
      : super(key: key);

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int? selectedAnswerIndex;
  bool? isCorrect;
  late Future<Map<String, dynamic>> _quizData;

  @override
  void initState() {
    super.initState();
    _quizData = loadQuizData();
  }

  Future<Map<String, dynamic>> loadQuizData() async {
    try {
      // Fetch quiz progress from Firestore
      DocumentSnapshot levelProgressDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('levelProgress')
          .doc(widget.subjectId)
          .get();

      // Fetch quiz data from Firestore
      DocumentSnapshot quizDoc = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('levels')
          .doc(widget.levelId)
          .get();

      return {
        'question': QuizQuestion.fromFirestore(quizDoc),
        'isCompleted': levelProgressDoc.exists
            ? (levelProgressDoc.data() as Map<String, dynamic>)?[widget.levelId]
                    ?['isCompleted'] ??
                false
            : false,
        'points': quizDoc['points'] ?? 0
      };
    } catch (e) {
      print('Error loading quiz data: $e');
      rethrow;
    }
  }

  Future<void> _updateUserProgress(int points) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Reference to the user's level progress document
      DocumentReference levelProgressRef = firestore
          .collection('users')
          .doc(widget.uid)
          .collection('levelProgress')
          .doc(widget.subjectId);

      // Reference to the user's profile document
      DocumentReference userRef = firestore.collection('users').doc(widget.uid);

      // Start a batch write to perform multiple updates atomically
      WriteBatch batch = firestore.batch();

      // Update level progress
      batch.set(
          levelProgressRef,
          {
            widget.levelId: {'isCompleted': true, 'points': points}
          },
          SetOptions(merge: true));

      // Update user's total points
      batch.update(userRef, {'points': FieldValue.increment(points)});

      // Commit the batch
      await batch.commit();

      print('User progress updated successfully');
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  void _handleAnswerSelection(int index) {
    _quizData.then((data) {
      final question = data['question'] as QuizQuestion;
      final points = data['points'] as int;

      setState(() {
        selectedAnswerIndex = index;
        isCorrect = index == question.correctAnswer;
      });

      if (isCorrect == true) {
        // Update user progress with points when correct answer is selected
        _updateUserProgress(points);
        _showCorrectAnswerDialog();
      } else {
        _showWrongAnswerDialog();
      }
    });
  }

  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                'Jawaban Salah',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      setState(() {
        selectedAnswerIndex = null;
        isCorrect = null;
      });
    });
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selamat Jawaban Benar',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LevelSelectionScreen(
                          uid: widget.uid,
                          subjectId: widget.subjectId,
                          subjectName: widget.subjectName),
                    ),
                  );
                },
                child: const Text(
                  'Kembali ke Home',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getAnswerColor(int index, bool isCompleted, QuizQuestion question) {
    // If level is completed, highlight the correct answer
    if (isCompleted) {
      return index == question.correctAnswer
          ? Colors.green.shade300
          : const Color(0xFFD4F1D8).withOpacity(0.5);
    }

    // Normal answer selection logic
    if (selectedAnswerIndex == index) {
      return isCorrect == true ? Colors.green : Colors.red;
    }
    return const Color(0xFFD4F1D8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _quizData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  'Error loading quiz data: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ));
              }

              final question = snapshot.data!['question'] as QuizQuestion;
              final isCompleted = snapshot.data!['isCompleted'] as bool;

              return Column(
                children: [
                  // Top section with score and title
                  TopWidget(uid: widget.uid),
                  const SizedBox(height: 24),

                  // Question container
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4F1D8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          question.questionText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer options
                  Column(
                    children: question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return Column(
                        children: [
                          _buildAnswerOption(
                              option, index, isCompleted, question),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // Bottom navigation bar
                  BottomBar(
                    uid: widget.uid,
                    currentScreen: 'subjects',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
      String text, int index, bool isCompleted, QuizQuestion question) {
    // Convert index to corresponding letter (0 = A, 1 = B, etc.)
    String prefix = String.fromCharCode('A'.codeUnitAt(0) + index);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted
              ? null
              : (selectedAnswerIndex == null
                  ? () => _handleAnswerSelection(index)
                  : null),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAnswerColor(index, isCompleted, question),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$prefix. $text', // Add the letter prefix
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // Reduce opacity if the level is completed
                decoration: isCompleted ? TextDecoration.none : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
