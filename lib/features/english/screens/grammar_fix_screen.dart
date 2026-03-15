import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';

/// Grammar Fix Screen – light theme.
class GrammarFixScreen extends StatelessWidget {
  const GrammarFixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnglishController>();
    final textController = TextEditingController();
    final result = Rxn<Map<String, dynamic>>();

    Future<void> checkGrammar() async {
      if (textController.text.trim().isEmpty) return;
      final res = await controller.checkGrammar(textController.text.trim());
      result.value = res;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Grammar Check',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: textController,
              maxLines: 5,
              style: const TextStyle(color: Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                hintText: 'Paste or type your text here...',
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
            ),
            const SizedBox(height: 16),
            Obx(() {
              return ElevatedButton.icon(
                onPressed:
                    controller.isLoading.value ? null : checkGrammar,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.spellcheck_rounded),
                label: Text(controller.isLoading.value
                    ? 'Checking...'
                    : 'Check Grammar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Obx(() {
              final r = result.value;
              if (r == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _resultCard(
                    'Corrected Text',
                    r['corrected']?.toString() ?? 'N/A',
                    Icons.check_circle_outline,
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  if (r['errors'] is List)
                    ...(r['errors'] as List).map((error) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('❌ ${error['mistake'] ?? ''}',
                                style: const TextStyle(
                                    color: Color(0xFFEF4444), fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('✅ ${error['correction'] ?? ''}',
                                style: const TextStyle(
                                    color: Color(0xFF10B981), fontSize: 14)),
                            if (error['rule'] != null) ...[
                              const SizedBox(height: 4),
                              Text('📖 ${error['rule']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                            ],
                          ],
                        ),
                      );
                    }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                  color: Color(0xFF1A1A2E), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
