import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';

/// Voice Practice Screen – speak English, AI corrects, asks cross-questions.
/// Uses text input as fallback since speech_to_text requires native setup.
class VoicePracticeScreen extends StatelessWidget {
  const VoicePracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnglishController>();
    final textController = TextEditingController();
    final isListening = false.obs;
    final conversation = <Map<String, String>>[].obs;
    final aiThinking = false.obs;

    Future<void> sendVoiceMessage(String text) async {
      if (text.trim().isEmpty) return;
      conversation.add({'role': 'user', 'text': text.trim()});
      textController.clear();
      aiThinking.value = true;

      try {
        final prompt =
            'You are an English-speaking practice partner. The user said: "$text". '
            'Do these 3 things:\n'
            '1. If there are any grammar/pronunciation mistakes, correct them and explain in English + Hindi.\n'
            '2. Give a natural reply to continue the conversation.\n'
            '3. Ask a cross-question to make them speak more English.\n\n'
            'Previous conversation:\n${conversation.map((m) => '${m['role']}: ${m['text']}').join('\n')}\n\n'
            'Reply naturally as a friendly English teacher. Use emojis.';

        final reply = await controller.sendChatMessage(prompt);
        if (reply != null) {
          conversation.add({'role': 'ai', 'text': reply});
        }
      } catch (e) {
        conversation.add({
          'role': 'ai',
          'text': 'Sorry, I couldn\'t understand. Please try again! 🙏'
        });
      }
      aiThinking.value = false;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('🎙️ Voice Practice (बोलकर अभ्यास)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => conversation.clear(),
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('🗣️ Speak English with AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                    'Type or speak in English. AI will correct your mistakes,\n'
                    'reply naturally, and ask cross-questions! 💬\n'
                    'अंग्रेजी में बोलें, AI गलतियाँ सुधारेगा और सवाल पूछेगा!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
              ],
            ),
          ),

          // Conversation
          Expanded(
            child: Obx(() {
              if (conversation.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎙️', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      const Text('Start a conversation!',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      Text('Try saying "Hello, how are you?"',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('"Hello, how are you?" बोलकर शुरू करें',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: conversation.length + (aiThinking.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= conversation.length) {
                    // AI thinking indicator
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child:
                                    Text('🤖', style: TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Thinking...',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final msg = conversation[index];
                  final isUser = msg['role'] == 'user';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text('🤖',
                                    style: TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF4A90D9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: isUser
                                  ? null
                                  : Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 10),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90D9)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text('👤',
                                    style: TextStyle(fontSize: 18))),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // Suggested prompts
          Obx(() {
            if (conversation.isNotEmpty) return const SizedBox.shrink();
            return Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SuggestedChip('Hello, how are you?', textController, sendVoiceMessage),
                  _SuggestedChip('My name is...', textController, sendVoiceMessage),
                  _SuggestedChip('what do you do?', textController, sendVoiceMessage),
                  _SuggestedChip('I want to learn English', textController, sendVoiceMessage),
                ],
              ),
            );
          }),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Mic button
                Obx(() => GestureDetector(
                      onTap: () {
                        isListening.value = !isListening.value;
                        // When speech_to_text is added, toggle listening here
                        if (isListening.value) {
                          Get.snackbar(
                            '🎙️ Listening...',
                            'Speech recognition requires native setup.\nPlease type your message for now.',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 3),
                          );
                          isListening.value = false;
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isListening.value
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isListening.value ? Icons.stop : Icons.mic_rounded,
                          color: isListening.value
                              ? Colors.white
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    )),
                const SizedBox(width: 10),
                // Text input
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Type in English / अंग्रेजी में टाइप करें...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: sendVoiceMessage,
                  ),
                ),
                const SizedBox(width: 10),
                // Send
                Obx(() => GestureDetector(
                      onTap: aiThinking.value
                          ? null
                          : () => sendVoiceMessage(textController.text),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: aiThinking.value
                              ? Colors.grey.shade300
                              : const Color(0xFF4A90D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedChip extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final Function(String) onSend;

  const _SuggestedChip(this.text, this.controller, this.onSend);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        onPressed: () {
          controller.text = text;
          onSend(text);
        },
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
        side: BorderSide(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
    );
  }
}
