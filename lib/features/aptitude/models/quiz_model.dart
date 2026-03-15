/// Quiz data model for aptitude questions.
class QuizQuestion {
  final int id;
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String explanation;
  final String topic;
  String? userAnswer;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.topic,
    this.userAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      options: Map<String, String>.from(json['options'] ?? {}),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
      topic: json['topic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correct_answer': correctAnswer,
        'user_answer': userAnswer,
      };

  bool get isCorrect => userAnswer == correctAnswer;
  bool get isAnswered => userAnswer != null;
}

/// Quiz result summary.
class QuizResult {
  final int totalQuestions;
  final int correct;
  final int wrong;
  final double scorePercentage;
  final List<String> weakTopics;
  final String recommendations;

  QuizResult({
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.scorePercentage,
    required this.weakTopics,
    required this.recommendations,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      totalQuestions: json['total_questions'] ?? 0,
      correct: json['correct'] ?? 0,
      wrong: json['wrong'] ?? 0,
      scorePercentage: (json['score_percentage'] ?? 0).toDouble(),
      weakTopics: List<String>.from(json['weak_topics'] ?? []),
      recommendations: json['recommendations'] ?? '',
    );
  }
}
