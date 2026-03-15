import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/aptitude/controller/aptitude_controller.dart';

/// Aptitude Quiz Screen – light theme.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AptitudeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Aptitude Quiz',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            if (!controller.quizStarted.value) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: controller.resetQuiz,
              tooltip: 'New Quiz',
            );
          }),
        ],
      ),
      body: Obx(() => controller.quizSubmitted.value
          ? _buildResultUI(controller)
          : controller.quizStarted.value
              ? _buildQuizUI(controller)
              : _buildSetupUI(controller)),
    );
  }

  Widget _buildSetupUI(AptitudeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      size: 48, color: Color(0xFFFF6B35)),
                ),
                const SizedBox(height: 12),
                const Text('Aptitude Quiz',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Test your skills',
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Topic
          const Text('Select Topic',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.topics.map((topic) {
                final isSelected =
                    controller.selectedTopic.value == topic['id'];
                return InkWell(
                  onTap: () =>
                      controller.selectedTopic.value = topic['id']!,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF6B35)
                              : Colors.grey.shade300),
                    ),
                    child: Text(topic['name']!,
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Difficulty
          const Text('Difficulty',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                {'id': 'easy', 'label': 'Easy', 'color': const Color(0xFF10B981)},
                {'id': 'medium', 'label': 'Medium', 'color': const Color(0xFFFF6B35)},
                {'id': 'hard', 'label': 'Hard', 'color': const Color(0xFFEF4444)},
              ].map((d) {
                final isSelected =
                    controller.selectedDifficulty.value == d['id'];
                final color = d['color'] as Color;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => controller.selectedDifficulty.value =
                          d['id'] as String,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected ? color : Colors.grey.shade300),
                        ),
                        child: Text(d['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Question Count
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                    'Questions: ${controller.questionCount.value}',
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w500))),
                Obx(() => Slider(
                      value: controller.questionCount.value.toDouble(),
                      min: 3,
                      max: 15,
                      divisions: 12,
                      activeColor: const Color(0xFFFF6B35),
                      label: '${controller.questionCount.value}',
                      onChanged: (v) =>
                          controller.questionCount.value = v.round(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.generateQuiz,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(controller.isLoading.value
                  ? 'Generating...'
                  : 'Start Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizUI(AptitudeController controller) {
    return Obx(() {
      final q = controller.questions[controller.currentIndex.value];
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (controller.currentIndex.value + 1) /
                    controller.questions.length,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFFFF6B35),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${controller.currentIndex.value + 1} of ${controller.questions.length}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(q.question,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),

            ...q.options.entries.map((entry) {
              final isSelected = q.userAnswer == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => controller.selectAnswer(entry.key),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFF6B35)
                                : Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Text(entry.key,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(entry.value,
                              style: const TextStyle(
                                  color: Color(0xFF1A1A2E), fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            Row(
              children: [
                if (controller.currentIndex.value > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previousQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (controller.currentIndex.value > 0)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.currentIndex.value <
                            controller.questions.length - 1
                        ? controller.nextQuestion
                        : controller.isLoading.value
                            ? null
                            : controller.submitQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.currentIndex.value <
                              controller.questions.length - 1
                          ? const Color(0xFF4A90D9)
                          : const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(controller.currentIndex.value <
                            controller.questions.length - 1
                        ? 'Next'
                        : controller.isLoading.value
                            ? 'Submitting...'
                            : 'Submit Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── FIXED: Now shows detailed answer breakdown ──
  Widget _buildResultUI(AptitudeController controller) {
    return Obx(() {
      final eval = controller.evaluation.value;
      final score = eval?['score_percentage']?.toDouble() ?? 0.0;
      final answers = eval?['answers'] as List? ?? [];
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(score >= 70 ? '🏆' : '📊',
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('${score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: score >= 70
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFF6B35),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Correct: ${eval?['correct'] ?? 0} / ${eval?['total_questions'] ?? 0}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score >= 70 ? 'Great job! Keep it up! 🌟' : 'Keep practicing! You will improve! 💪',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── ANSWER BREAKDOWN ──
            if (answers.isNotEmpty) ...[
              const Text('📋 Answer Breakdown',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...answers.asMap().entries.map((entry) {
                final idx = entry.key;
                final ans = entry.value;
                final isCorrect = ans['is_correct'] == true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : const Color(0xFFEF4444).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question number + status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 16,
                                  color: isCorrect
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCorrect ? 'Correct ✅' : 'Wrong ❌',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text('Q${idx + 1}',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Question text
                      Text(
                        ans['question']?.toString() ?? 'Question ${idx + 1}',
                        style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),

                      // User's answer
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Answer: ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E))),
                          Expanded(
                            child: Text(
                              ans['user_answer']?.toString() ?? 'Not answered',
                              style: TextStyle(
                                fontSize: 13,
                                color: isCorrect
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Correct answer (always show)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Correct Answer: ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E))),
                          Expanded(
                            child: Text(
                              ans['correct_answer']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Explanation
                      if (ans['explanation'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9)
                                .withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡 Explanation:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A90D9))),
                              const SizedBox(height: 4),
                              Text(
                                ans['explanation']?.toString() ?? '',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4),
                              ),
                              if (ans['explanation_hindi'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '🇮🇳 ${ans['explanation_hindi']}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.4),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],

            // ── Recommendations ──
            if (eval?['recommendations'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color:
                          const Color(0xFF4A90D9).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 Recommendations',
                        style: TextStyle(
                            color: Color(0xFF4A90D9),
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(eval!['recommendations'],
                        style: TextStyle(
                            color: Colors.grey.shade700, height: 1.5)),
                  ],
                ),
              ),
            ],

            // ── Weak Topics ──
            if (eval?['weak_topics'] is List &&
                (eval!['weak_topics'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    (eval['weak_topics'] as List).map<Widget>((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⚠️ $topic',
                        style: const TextStyle(
                            color: Color(0xFFEF4444), fontSize: 12)),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.resetQuiz,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Take Another Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      );
    });
  }
}
