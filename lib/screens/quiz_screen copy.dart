import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String subjectId;
  final String levelId;

  const QuizQuestionScreen(
      {Key? key, required this.subjectId, required this.levelId})
      : super(key: key);

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int? selectedAnswerIndex;
  bool? isCorrect;
  late Future<QuizQuestion> _quizQuestion;

  @override
  void initState() {
    super.initState();
    _quizQuestion = loadQuizData();
  }

  Future<QuizQuestion> loadQuizData() async {
    try {
      // Fetch quiz from Firestore using the provided subject and level IDs
      DocumentSnapshot quizDoc = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('levels')
          .doc(widget.levelId)
          .get();

      return QuizQuestion.fromFirestore(quizDoc);
    } catch (e) {
      print('Error loading quiz data: $e');
      rethrow;
    }
  }

  void _handleAnswerSelection(int index) {
    // Fetch the correct answer from the loaded question
    _quizQuestion.then((question) {
      setState(() {
        selectedAnswerIndex = index;
        isCorrect = index == question.correctAnswer;
      });

      if (isCorrect == true) {
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
                  Navigator.of(context).pop();
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

  Color _getAnswerColor(int index) {
    if (selectedAnswerIndex == index) {
      return isCorrect == true ? Colors.green : Colors.red;
    }
    return const Color(0xffbD4F1D8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffbF9FAED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<QuizQuestion>(
            future: _quizQuestion,
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

              final question = snapshot.data!;

              return Column(
                children: [
                  // Top section with score and title (unchanged)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 110,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xF876BE80),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            '250',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 110,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xF876BE80),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Rahmad',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Question container
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffbD4F1D8),
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
                          _buildAnswerOption(option, index),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // Bottom navigation bar (unchanged)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {},
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF76BE80),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.black,
                              size: 24,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String text, int index) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: selectedAnswerIndex == null
              ? () => _handleAnswerSelection(index)
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAnswerColor(index),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example of how to navigate to this screen
class NavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizQuestionScreen(
                subjectId: 'your_subject_id', levelId: 'your_level_id'),
          ),
        );
      },
      child: Text('Start Quiz'),
    );
  }
}
