import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ai_tutor_controller.dart';

/// Screen for generating and taking MCQ quizzes using Gemini AI.
class McqQuizScreen extends StatefulWidget {
  const McqQuizScreen({super.key});

  @override
  State<McqQuizScreen> createState() => _McqQuizScreenState();
}

class _McqQuizScreenState extends State<McqQuizScreen> {
  final ctrl = Get.find<AiTutorController>();
  final topicCtrl = TextEditingController();
  final countCtrl = TextEditingController(text: '5');

  @override
  void dispose() {
    topicCtrl.dispose();
    countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('🧠 MCQ Quiz',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          if (ctrl.mcqResult.value != null &&
              ctrl.mcqResult.value!['questions'] != null) {
            return _buildQuiz();
          }
          return _buildInput();
        }),
      ),
    );
  }

  Widget _buildInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: Color(0xFFFF6B35), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter any topic and AI will generate MCQs for you to practice!',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        TextField(
          controller: topicCtrl,
          decoration: InputDecoration(
            labelText: 'Topic',
            hintText: 'e.g., Flutter Hooks, Java OOP, World War II',
            prefixIcon: const Icon(Icons.topic_rounded),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: countCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of Questions',
            hintText: '5',
            prefixIcon: const Icon(Icons.format_list_numbered_rounded),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 18),

        Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: ctrl.isLoading.value
                    ? null
                    : () {
                        if (topicCtrl.text.trim().isEmpty) {
                          Get.snackbar('Empty', 'Please enter a topic',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        final count =
                            int.tryParse(countCtrl.text.trim()) ?? 5;
                        ctrl.generateMCQs(topicCtrl.text.trim(), count: count);
                      },
                icon: ctrl.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(ctrl.isLoading.value
                    ? 'Generating...'
                    : 'Generate MCQs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildQuiz() {
    final questions =
        ctrl.mcqResult.value!['questions'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${questions.length} Questions',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            TextButton.icon(
              onPressed: () {
                ctrl.mcqResult.value = null;
                ctrl.selectedAnswers.clear();
                ctrl.showResults.value = false;
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('New Quiz'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Questions
        ...List.generate(questions.length, (i) {
          final q = questions[i];
          final options = q['options'] as List? ?? [];
          final correctAnswer = q['correct_answer']?.toString() ?? '';

          return Obx(() {
            final selected = ctrl.selectedAnswers[i];
            final showResult = ctrl.showResults.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q['question']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Options
                  ...List.generate(options.length, (j) {
                    final optText = options[j].toString();
                    final optLetter = String.fromCharCode(65 + j); // A, B, C, D
                    final isSelected = selected == optLetter;
                    final isCorrect = correctAnswer == optLetter;

                    Color bgColor = Colors.grey.shade50;
                    Color borderColor = Colors.grey.shade200;
                    if (showResult && isSelected && isCorrect) {
                      bgColor = Colors.green.shade50;
                      borderColor = Colors.green.shade400;
                    } else if (showResult && isSelected && !isCorrect) {
                      bgColor = Colors.red.shade50;
                      borderColor = Colors.red.shade400;
                    } else if (showResult && isCorrect) {
                      bgColor = Colors.green.shade50;
                      borderColor = Colors.green.shade300;
                    } else if (isSelected) {
                      bgColor = const Color(0xFFFF6B35).withValues(alpha: 0.08);
                      borderColor = const Color(0xFFFF6B35);
                    }

                    return GestureDetector(
                      onTap: showResult
                          ? null
                          : () => ctrl.selectAnswer(i, optLetter),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF6B35)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(optLetter,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(optText,
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 14)),
                            ),
                            if (showResult && isCorrect)
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.green, size: 20),
                            if (showResult && isSelected && !isCorrect)
                              const Icon(Icons.cancel_rounded,
                                  color: Colors.red, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          });
        }),
        const SizedBox(height: 8),

        // Submit / Score
        Obx(() {
          if (ctrl.showResults.value) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ctrl.score >= (questions.length / 2)
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    ctrl.score >= (questions.length / 2) ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: ${ctrl.score}/${questions.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.score >= (questions.length / 2)
                        ? 'Great job! Keep learning! 🚀'
                        : 'Keep practicing, you\'ll get better! 📚',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: ctrl.selectedAnswers.length == questions.length
                  ? () => ctrl.showResults.value = true
                  : null,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                  'Submit (${ctrl.selectedAnswers.length}/${questions.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
