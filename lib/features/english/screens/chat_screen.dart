import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';
import 'package:edusarthi_app/features/english/widgets/chat_bubble.dart';

/// AI English Teacher Chat – Bilingual support (Hindi + English).
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnglishController>();
    final textController = TextEditingController();
    final scrollController = ScrollController();

    void scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    void sendMessage() {
      final text = textController.text.trim();
      if (text.isEmpty) return;
      textController.clear();
      controller.sendMessage(text);
      scrollToBottom();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🤖 ', style: TextStyle(fontSize: 22)),
            Text('AI English Teacher',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
        actions: [
          // Language toggle
          Obx(() {
            final lang = controller.chatLanguage.value;
            final emoji = lang == 'both'
                ? '🌏'
                : lang == 'hindi'
                    ? '🇮🇳'
                    : '🇬🇧';
            final label = lang == 'both'
                ? 'Both'
                : lang == 'hindi'
                    ? 'हिंदी'
                    : 'EN';
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text('$emoji $label', style: const TextStyle(fontSize: 13)),
                onPressed: () => controller.toggleLanguage(),
                backgroundColor: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: controller.clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggested prompts (show when chat is empty)
          Obx(() {
            if (controller.chatMessages.isNotEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('👋 Hello! I am your English teacher! (नमस्ते!)',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text(
                    'Ask anything in Hindi or English 🌟\nहिंदी या अंग्रेजी में कुछ भी पूछें! I will help you learn English easily!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _SuggestedPrompt('Teach me English 📚', textController, sendMessage),
                      _SuggestedPrompt('What is tense? ⏳', textController, sendMessage),
                      _SuggestedPrompt('How to greet in English? 👋', textController, sendMessage),
                      _SuggestedPrompt('Grammar rules 📖', textController, sendMessage),
                      _SuggestedPrompt('Daily use sentences 🗣️', textController, sendMessage),
                      _SuggestedPrompt('Translate: मैं स्कूल जाता हूँ 🌐', textController, sendMessage),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Chat messages
          Expanded(
            child: Obx(() {
              scrollToBottom();
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = controller.chatMessages[index];
                  return ChatBubble(
                    message: msg['content'] ?? '',
                    isUser: msg['role'] == 'user',
                  );
                },
              );
            }),
          ),

          // Loading indicator
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF4A90D9)),
                  ),
                  const SizedBox(width: 10),
                  Text('AI is thinking... 🤔 (AI सोच रहा है...)',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            );
          }),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    onSubmitted: (_) => sendMessage(),
                    style: const TextStyle(color: Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Type in Hindi or English... ✏️',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: controller.isLoading.value
                            ? Colors.grey.shade300
                            : const Color(0xFF4A90D9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        onPressed:
                            controller.isLoading.value ? null : sendMessage,
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
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

class _SuggestedPrompt extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final VoidCallback onSend;

  const _SuggestedPrompt(this.text, this.controller, this.onSend);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.text = text;
        onSend();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.2)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF4A90D9),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}
