import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/core/api_service.dart';
import 'package:edusarthi_app/core/constants.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';
import 'package:edusarthi_app/features/english/screens/lesson_test_screen.dart';

/// Day-wise Lesson Screen – Verbs, Sentences, Grammar, Vocabulary, Practice, Test.
class LessonScreen extends StatefulWidget {
  final int day;
  final String level;

  const LessonScreen({super.key, required this.day, required this.level});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int get day => widget.day;
  String get level => widget.level;

  final isLoading = true.obs;
  final lessonData = Rxn<Map<String, dynamic>>();
  final errorMsg = RxnString();
  final sentenceController = TextEditingController();
  final sentenceResult = Rxn<Map<String, dynamic>>();
  final checkingStatement = false.obs;

  late final ApiService api;
  late final EnglishController englishController;

  @override
  void initState() {
    super.initState();
    api = Get.find<ApiService>();
    englishController = Get.find<EnglishController>();
    fetchLesson();
  }

  @override
  void dispose() {
    sentenceController.dispose();
    super.dispose();
  }

  Future<void> fetchLesson() async {
    isLoading.value = true;
    errorMsg.value = null;
    try {
      final response = await api.postApi(
        '${AppConstants.englishLesson}/$level/$day',
        {'level': level, 'day': day},
      );
      lessonData.value = response;
    } catch (e) {
      errorMsg.value = e.toString();
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Day $day – ${level[0].toUpperCase()}${level.substring(1)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (_, val, __) => Transform.rotate(
                    angle: val * 6.28,
                    child: const Text('📚', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Color(0xFF4A90D9)),
                const SizedBox(height: 16),
                const Text('Preparing your lesson with AI... ✨\nAI आपका पाठ तैयार कर रहा है...',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              ],
            ),
          );
        }

        if (errorMsg.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('😔', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                   Text('Lesson could not load (पाठ लोड नहीं हो सका)',
                       style: TextStyle(
                           color: Colors.grey.shade700,
                           fontSize: 16,
                           fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(errorMsg.value!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: fetchLesson,
                    icon: const Icon(Icons.refresh_rounded),
                     label: const Text('Try Again 🔄'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = lessonData.value;
        if (data == null) return const SizedBox.shrink();

        final hasNext = data['has_next'] == true;
        final totalLessons = data['total_lessons'] ?? 20;
        final topicEmoji = data['topic_emoji'] ?? '📖';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title Card ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF6C63FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(topicEmoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'] ?? 'Day $day Lesson',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('Lesson $day / $totalLessons',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (data['fun_fact'] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('🎯 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(data['fun_fact'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Verbs Section ──────────────
              if (data['verbs'] is List) ...[
                _SectionHeader('📝 Verbs (क्रियाएँ)', const Color(0xFF4A90D9)),
                const SizedBox(height: 8),
                ...(data['verbs'] as List).map((verb) => _VerbCard(verb)),
                const SizedBox(height: 20),
              ],

              // ── Sentences Section ──────────
              if (data['sentences'] is List) ...[
                _SectionHeader('💬 Sentences (वाक्य)', const Color(0xFF10B981)),
                const SizedBox(height: 8),
                ...(data['sentences'] as List).map((s) => _SentenceCard(s)),
                const SizedBox(height: 20),
              ],

              // ── Grammar Rules ──────────────
              if (data['grammar_rules'] is List) ...[
                _SectionHeader('📖 Grammar Rules (व्याकरण)', const Color(0xFF8B5CF6)),
                const SizedBox(height: 8),
                ...(data['grammar_rules'] as List).map((rule) => _GrammarCard(rule)),
                const SizedBox(height: 20),
              ],

              // ── Vocabulary ─────────────────
              if (data['vocabulary'] is List) ...[
                _SectionHeader('🔤 Vocabulary (शब्दावली)', const Color(0xFFFF6B35)),
                const SizedBox(height: 8),
                ...(data['vocabulary'] as List).map((word) => _VocabCard(word)),
                const SizedBox(height: 20),
              ],

              // ── Practice Tip ───────────────
              if (data['practice_tip'] != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4A90D9).withValues(alpha: 0.1),
                        const Color(0xFF10B981).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Practice Tip 🌟',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A90D9),
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(data['practice_tip'],
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // ── ✏️ Sentence Practice Section ──────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('✏️', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Hindi → English Translation Practice',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1A1A2E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Translate the Hindi sentence into English and AI will check it ✨\nहिंदी वाक्य को अंग्रेजी में अनुवाद करें',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sentenceController,
                      maxLines: 2,
                      style: const TextStyle(color: Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Type your English translation here...\nयहाँ अपना अंग्रेजी अनुवाद लिखें...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: checkingStatement.value
                            ? null
                            : () async {
                                if (sentenceController.text.trim().isEmpty) return;
                                checkingStatement.value = true;
                                final result = await englishController.checkSentence(
                                  sentenceController.text.trim(),
                                  topic: data['title'] ?? 'general',
                                  level: level,
                                );
                                sentenceResult.value = result;
                                checkingStatement.value = false;
                              },
                        icon: checkingStatement.value
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(checkingStatement.value ? 'Checking...' : 'Check Translation ✅'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )),

                    // Sentence check result
                    Obx(() {
                      final res = sentenceResult.value;
                      if (res == null) return const SizedBox.shrink();
                      final isCorrect = res['is_correct'] == true;
                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
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
                                Text(isCorrect ? '🎉' : '🔧',
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isCorrect ? 'Excellent! Correct! ✅ (बहुत बढ़िया!)' : 'Needs correction 📝 (सुधार ज़रूरी है)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCorrect
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                                if (res['score'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('${res['score']}/10',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            if (res['corrected'] != null && !isCorrect) ...[
                              const SizedBox(height: 8),
                              Text('✅ Correct: ${res['corrected']}',
                                  style: const TextStyle(
                                      color: Color(0xFF10B981), fontSize: 13)),
                            ],
                            if (res['feedback_hindi'] != null) ...[
                              const SizedBox(height: 8),
                              Text(res['feedback_hindi'],
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      height: 1.4)),
                            ],
                            if (res['feedback_english'] != null) ...[
                              const SizedBox(height: 4),
                              Text(res['feedback_english'],
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ],
                            if (res['better_version'] != null) ...[
                              const SizedBox(height: 8),
                              Text('💡 Better version: ${res['better_version']}',
                                  style: const TextStyle(
                                      color: Color(0xFF4A90D9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 📝 Take Test Button ──────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.15),
                      const Color(0xFF10B981).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    const Text('Lesson Complete? Take the Test!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Text('You must pass the test to proceed to next lesson 💪\nआगे बढ़ने के लिए टेस्ट पास करना ज़रूरी है',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => LessonTestScreen(
                              day: day,
                              level: level,
                              topic: data['title'] ?? 'Lesson $day',
                            )),
                        icon: const Icon(Icons.quiz_rounded),
                        label: const Text('Start Test 📝'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Next Lesson Button ─────────
              if (hasNext)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.off(() => LessonScreen(day: day + 1, level: level));
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text('Next Lesson → Day ${day + 1} 🚀'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(title,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}

class _VerbCard extends StatelessWidget {
  final dynamic verb;
  const _VerbCard(this.verb);

  @override
  Widget build(BuildContext context) {
    if (verb is! Map) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔵 ', style: TextStyle(fontSize: 16)),
              Text(verb['word'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4A90D9))),
              if (verb['hindi'] != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${verb['hindi']}',
                      style: TextStyle(
                          color: Colors.amber.shade800, fontSize: 12)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (verb['present'] != null) _tenseRow('Present', verb['present']),
          if (verb['past'] != null) _tenseRow('Past', verb['past']),
          if (verb['future'] != null) _tenseRow('Future', verb['future']),
          if (verb['example'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(verb['example'],
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ],
          if (verb['example_hindi'] != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(verb['example_hindi'],
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tenseRow(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text('$label:',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF1A1A2E), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _SentenceCard extends StatelessWidget {
  final dynamic sentence;
  const _SentenceCard(this.sentence);

  @override
  Widget build(BuildContext context) {
    if (sentence is! Map) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🗣️ ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(sentence['english'] ?? '',
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          if (sentence['hindi'] != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text('→ ${sentence['hindi']}',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
            ),
          ],
          if (sentence['pronunciation'] != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text('🔊 ${sentence['pronunciation']}',
                  style: TextStyle(
                      color: Colors.blue.shade300,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrammarCard extends StatelessWidget {
  final dynamic rule;
  const _GrammarCard(this.rule);

  @override
  Widget build(BuildContext context) {
    if (rule is! Map) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📌 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(rule['rule'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF8B5CF6))),
              ),
            ],
          ),
          if (rule['explanation'] != null) ...[
            const SizedBox(height: 8),
            Text(rule['explanation'],
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4)),
          ],
          if (rule['explanation_hindi'] != null) ...[
            const SizedBox(height: 4),
            Text('🇮🇳 ${rule['explanation_hindi']}',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
          ],
          if (rule['example'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('✏️ ${rule['example']}',
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
            ),
          ],
          if (rule['tip'] != null) ...[
            const SizedBox(height: 6),
            Text(rule['tip'],
                style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

class _VocabCard extends StatelessWidget {
  final dynamic word;
  const _VocabCard(this.word);

  @override
  Widget build(BuildContext context) {
    if (word is! Map) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('📗', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word['word'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                if (word['meaning'] != null)
                  Text(word['meaning'],
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                if (word['hindi_meaning'] != null)
                  Text('🇮🇳 ${word['hindi_meaning']}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                if (word['example_sentence'] != null) ...[
                  const SizedBox(height: 4),
                  Text('💡 ${word['example_sentence']}',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
