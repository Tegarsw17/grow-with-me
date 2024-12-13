class QuizQuestion {
  final String question;
  final List<QuizOption> options;

  QuizQuestion({
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: (json['options'] as List)
          .map((option) => QuizOption.fromJson(option))
          .toList(),
    );
  }
}

class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['isCorrect'],
    );
  }
}
