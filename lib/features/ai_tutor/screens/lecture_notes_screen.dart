import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ai_tutor_controller.dart';

/// Screen for extracting key points from lecture transcripts using Gemini AI.
class LectureNotesScreen extends StatefulWidget {
  const LectureNotesScreen({super.key});

  @override
  State<LectureNotesScreen> createState() => _LectureNotesScreenState();
}

class _LectureNotesScreenState extends State<LectureNotesScreen> {
  final ctrl = Get.find<AiTutorController>();
  final transcriptCtrl = TextEditingController();

  @override
  void dispose() {
    transcriptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('📝 Lecture Notes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded,
                      color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paste your lecture transcript and AI will extract key points, definitions & practice questions.',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Transcript Input ──
            TextField(
              controller: transcriptCtrl,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Lecture Transcript',
                hintText: 'Paste your lecture transcript here...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // ── Extract Button ──
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: ctrl.isLoading.value
                        ? null
                        : () {
                            if (transcriptCtrl.text.trim().isEmpty) {
                              Get.snackbar(
                                  'Empty', 'Please paste a transcript',
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            ctrl.extractLectureNotes(
                                transcriptCtrl.text.trim());
                          },
                    icon: ctrl.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(ctrl.isLoading.value
                        ? 'Extracting...'
                        : 'Extract Key Points'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // ── Results ──
            Obx(() {
              final data = ctrl.lectureResult.value;
              if (data == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Points
                  if (data['key_points'] != null) ...[
                    _SectionHeader(
                        icon: Icons.star_rounded,
                        title: 'Key Points',
                        color: const Color(0xFFFF6B35)),
                    const SizedBox(height: 10),
                    ...List.generate(
                      (data['key_points'] as List).length,
                      (i) => _BulletItem(
                        text: data['key_points'][i].toString(),
                        index: i + 1,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Definitions
                  if (data['definitions'] != null) ...[
                    _SectionHeader(
                        icon: Icons.menu_book_rounded,
                        title: 'Definitions',
                        color: const Color(0xFF4A90D9)),
                    const SizedBox(height: 10),
                    ...List.generate(
                      (data['definitions'] as List).length,
                      (i) {
                        final def = data['definitions'][i];
                        return _DefinitionCard(
                          term: def['term']?.toString() ?? '',
                          definition: def['definition']?.toString() ?? '',
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Practice Questions
                  if (data['practice_questions'] != null) ...[
                    _SectionHeader(
                        icon: Icons.quiz_rounded,
                        title: 'Practice Questions',
                        color: const Color(0xFF8B5CF6)),
                    const SizedBox(height: 10),
                    ...List.generate(
                      (data['practice_questions'] as List).length,
                      (i) => _BulletItem(
                        text: data['practice_questions'][i].toString(),
                        index: i + 1,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                color: color, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final int index;
  final Color color;

  const _BulletItem({
    required this.text,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$index',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                      height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefinitionCard extends StatelessWidget {
  final String term;
  final String definition;

  const _DefinitionCard({required this.term, required this.definition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(term,
                style: const TextStyle(
                    color: Color(0xFF4A90D9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(definition,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4)),
          ],
        ),
      ),
    );
  }
}
