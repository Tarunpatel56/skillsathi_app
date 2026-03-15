import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';

/// Lesson Test Screen – Test after completing a lesson.
class LessonTestScreen extends StatefulWidget {
  final int day;
  final String level;
  final String topic;
  final bool isRetry;

  const LessonTestScreen({
    super.key,
    required this.day,
    required this.level,
    required this.topic,
    this.isRetry = false,
  });

  @override
  State<LessonTestScreen> createState() => _LessonTestScreenState();
}

class _LessonTestScreenState extends State<LessonTestScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<EnglishController>();
  final testData = Rxn<Map<String, dynamic>>();
  final isLoadingTest = true.obs;
  final isSubmitting = false.obs;
  final errorMsg = RxnString();
  final testResult = Rxn<Map<String, dynamic>>();
  final currentQuestion = 0.obs;
  final userAnswers = <int, String>{}.obs;
  final answerControllers = <int, TextEditingController>{};

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadTest();
  }

  @override
  void dispose() {
    _animController.dispose();
    for (final c in answerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTest() async {
    isLoadingTest.value = true;
    errorMsg.value = null;
    try {
      final data = await controller.generateLessonTest(
        widget.level,
        widget.day,
        isRetry: widget.isRetry,
      );
      testData.value = data;
    } catch (e) {
      errorMsg.value = e.toString();
    }
    isLoadingTest.value = false;
  }

  Future<void> _submitTest() async {
    final questions = (testData.value?['questions'] as List?) ?? [];
    final submitData = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i] as Map;
      submitData.add({
        'id': q['id'],
        'question': q['question'],
        'correct_answer': q['correct_answer'],
        'user_answer': userAnswers[i] ?? '',
        'type': q['type'],
      });
    }

    isSubmitting.value = true;
    try {
      final result = await controller.submitTest(submitData, widget.level, widget.day);
      testResult.value = result;
    } catch (e) {
      errorMsg.value = e.toString();
    }
    isSubmitting.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('📝 Day ${widget.day} Test',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        // Loading state
        if (isLoadingTest.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (_, val, __) => Transform.rotate(
                    angle: val * 6.28,
                    child: const Text('📝', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Color(0xFF10B981)),
                const SizedBox(height: 16),
                Text(
                  widget.isRetry
                      ? 'Preparing new questions... ✨\nनये सवाल तैयार हो रहे हैं...'
                      : 'Preparing your test... ✨\nटेस्ट तैयार हो रहा है...',
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Error state
        if (errorMsg.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😔', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(errorMsg.value!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadTest,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry 🔄'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Result state
        if (testResult.value != null) {
          return _buildResultView();
        }

        // Test questions
        return _buildTestView();
      }),
    );
  }

  Widget _buildTestView() {
    final questions = (testData.value?['questions'] as List?) ?? [];
    if (questions.isEmpty) {
      return const Center(child: Text('No questions generated'));
    }

    return Column(
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isRetry
                        ? '🔄 Retry Test – ${widget.topic}'
                        : '📝 ${widget.topic}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E)),
                  ),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${currentQuestion.value + 1}/${questions.length}',
                          style: const TextStyle(
                              color: Color(0xFF4A90D9),
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentQuestion.value + 1) / questions.length,
                      backgroundColor: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                      color: const Color(0xFF4A90D9),
                      minHeight: 6,
                    ),
                  )),
            ],
          ),
        ),

        // Question area
        Expanded(
          child: Obx(() {
            final qIndex = currentQuestion.value;
            final q = questions[qIndex] as Map;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildQuestionCard(q, qIndex),
            );
          }),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Obx(() {
            final isLast = currentQuestion.value >= questions.length - 1;
            return Row(
              children: [
                if (currentQuestion.value > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => currentQuestion.value--,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Pichla'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90D9),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (currentQuestion.value > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting.value
                        ? null
                        : isLast
                            ? _submitTest
                            : () => currentQuestion.value++,
                    icon: isSubmitting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(isLast
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_rounded),
                    label: Text(isSubmitting.value
                        ? 'Checking...'
                        : isLast
                            ? 'Submit Test ✅'
                            : 'Agla Savaal →'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast
                          ? const Color(0xFF10B981)
                          : const Color(0xFF4A90D9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map q, int index) {
    final type = q['type'] ?? 'mcq';
    final typeLabel = type == 'fill_blank'
        ? '📝 Fill in the Blank'
        : type == 'correct_sentence'
            ? '✏️ Correct the Sentence'
            : type == 'translate'
                ? '🌐 Translate (Hindi → English)'
                : '🔘 Choose the Correct Option';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(typeLabel,
              style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),

        // Question text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Q${index + 1}. ${q['question'] ?? ''}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                      height: 1.4)),
              if (q['question_hindi'] != null) ...[
                const SizedBox(height: 8),
                Text('🇮🇳 ${q['question_hindi']}',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Answer area based on type
        if (type == 'mcq' && q['options'] is Map) ...[
          ...(q['options'] as Map).entries.map((entry) {
            return Obx(() {
              final isSelected = userAnswers[index] == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => userAnswers[index] = entry.key,
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A90D9).withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A90D9)
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
                            color: isSelected
                                ? const Color(0xFF4A90D9)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(entry.key,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(entry.value,
                              style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF4A90D9)
                                      : const Color(0xFF1A1A2E),
                                  fontSize: 14)),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF4A90D9), size: 22),
                      ],
                    ),
                  ),
                ),
              );
            });
          }),
        ] else ...[
          // Text input for fill_blank, correct_sentence, translate
          Builder(builder: (context) {
            answerControllers.putIfAbsent(index, () => TextEditingController());
            final tc = answerControllers[index]!;
            return TextField(
              controller: tc,
              onChanged: (val) => userAnswers[index] = val,
              maxLines: 2,
              style: const TextStyle(color: Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                hintText: type == 'translate'
                    ? 'Translate to English...'
                    : type == 'correct_sentence'
                        ? 'Write the correct sentence...'
                        : 'Write your answer...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4A90D9)),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildResultView() {
    final result = testResult.value!;
    final passed = result['passed'] == true;
    final score = result['score_percentage'] ?? 0;
    final answers = (result['answers'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score card
          FadeTransition(
            opacity: _animController,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (passed
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(passed ? '🎉' : '😔', style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(
                    passed ? 'Excellent! You Passed! 🏆 (बहुत बढ़िया!)' : 'Keep Practicing! 💪 (और मेहनत करो!)',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: ${score is double ? score.toStringAsFixed(0) : score}%',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniStat('✅ Correct', '${result['correct'] ?? 0}'),
                      const SizedBox(width: 24),
                      _miniStat('❌ Wrong', '${result['wrong'] ?? 0}'),
                      const SizedBox(width: 24),
                      _miniStat('📝 Total', '${result['total_questions'] ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Feedback
          if (result['feedback'] != null || result['feedback_hindi'] != null)
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
                  if (result['feedback'] != null)
                    Text(result['feedback'],
                        style: const TextStyle(
                            color: Color(0xFF1A1A2E), fontSize: 14, height: 1.4)),
                  if (result['feedback_hindi'] != null) ...[
                    const SizedBox(height: 8),
                    Text('🇮🇳 ${result['feedback_hindi']}',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Answer breakdown
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('📋 Answer Details',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E))),
          ),
          const SizedBox(height: 10),
          ...answers.map((a) {
            if (a is! Map) return const SizedBox.shrink();
            final isCorrect = a['is_correct'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF10B981).withValues(alpha: 0.05)
                    : const Color(0xFFEF4444).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(isCorrect ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(a['question'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1A1A2E))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (a['user_answer'] != null && a['user_answer'].toString().isNotEmpty)
                    Text('Your answer: ${a['user_answer']}',
                        style: TextStyle(
                            color: isCorrect
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontSize: 13)),
                  if (!isCorrect && a['correct_answer'] != null) ...[
                    const SizedBox(height: 4),
                    Text('✅ Correct: ${a['correct_answer']}',
                        style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                  if (a['explanation'] != null) ...[
                    const SizedBox(height: 8),
                    Text('📖 ${a['explanation']}',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12, height: 1.4)),
                  ],
                  if (a['explanation_hindi'] != null) ...[
                    const SizedBox(height: 4),
                    Text('🇮🇳 ${a['explanation_hindi']}',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // Action buttons
          if (!passed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.off(() => LessonTestScreen(
                        day: widget.day,
                        level: widget.level,
                        topic: widget.topic,
                        isRetry: true,
                      ));
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry with More Practice 🔄 (Double Questions!)'),
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Lesson'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A90D9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
