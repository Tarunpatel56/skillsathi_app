import 'package:get/get.dart';
import 'package:edusarthi_app/core/api_service.dart';
import 'package:edusarthi_app/core/constants.dart';

/// GetX controller for the English learning module.
class EnglishController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final chatMessages = <Map<String, String>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final chatLanguage = 'both'.obs; // both / english / hindi

  // ── Chat with AI Teacher ──────────────────
  Future<void> sendMessage(String message, {String level = 'intermediate'}) async {
    chatMessages.add({'role': 'user', 'content': message});
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _api.postApi(
        AppConstants.englishChat,
        {
          'message': message,
          'level': level,
          'language': chatLanguage.value,
        },
      );
      chatMessages.add({
        'role': 'assistant',
        'content': response['response'] ?? 'No response',
      });
    } catch (e) {
      errorMessage.value = e.toString();
      chatMessages.add({
        'role': 'assistant',
        'content': 'Sorry, something went wrong. Please try again. 😔',
      });
    }

    isLoading.value = false;
  }

  // ── Grammar Check ─────────────────────────
  Future<Map<String, dynamic>?> checkGrammar(String text) async {
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.englishGrammar,
        {'text': text},
      );
      isLoading.value = false;
      return response['data'] as Map<String, dynamic>?;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  // ── Vocabulary ────────────────────────────
  Future<dynamic> getVocabulary({int count = 5, String level = 'intermediate'}) async {
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.englishVocabulary,
        {'count': count, 'level': level},
      );
      isLoading.value = false;
      return response['data'];
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  // ── Translate ─────────────────────────────
  Future<String?> translate(String text, {String from = 'hindi', String to = 'english'}) async {
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.englishTranslate,
        {'text': text, 'source_lang': from, 'target_lang': to},
      );
      isLoading.value = false;
      return response['response'] as String?;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  // ── Check Sentence ────────────────────────
  Future<Map<String, dynamic>?> checkSentence(String sentence, {String topic = 'general', String level = 'beginner'}) async {
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.englishCheckSentence,
        {'sentence': sentence, 'topic': topic, 'level': level},
      );
      isLoading.value = false;
      return response['data'] as Map<String, dynamic>?;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  // ── Lesson Test ───────────────────────────
  Future<Map<String, dynamic>?> generateLessonTest(String level, int day, {bool isRetry = false}) async {
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        '${AppConstants.englishLessonTest}/$level/$day?is_retry=$isRetry',
        {},
      );
      isLoading.value = false;
      return response['data'] as Map<String, dynamic>?;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  // ── Submit Test ───────────────────────────
  Future<Map<String, dynamic>?> submitTest(List<Map<String, dynamic>> testData, String level, int day) async {
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.englishEvaluateTest,
        {'test_data': testData, 'level': level, 'day': day},
      );
      isLoading.value = false;
      return response['evaluation'] as Map<String, dynamic>?;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  // ── Send chat message and return reply (for voice practice) ──
  Future<String?> sendChatMessage(String message, {String level = 'intermediate'}) async {
    isLoading.value = true;
    try {
      final response = await _api.postApi(
        AppConstants.englishChat,
        {'message': message, 'level': level, 'language': chatLanguage.value},
      );
      isLoading.value = false;
      return response['response'] as String?;
    } catch (e) {
      isLoading.value = false;
      return null;
    }
  }

  // ── Clear Chat ────────────────────────────
  void clearChat() {
    chatMessages.clear();
    errorMessage.value = null;
  }

  // ── Toggle Chat Language ──────────────────
  void toggleLanguage() {
    if (chatLanguage.value == 'both') {
      chatLanguage.value = 'english';
    } else if (chatLanguage.value == 'english') {
      chatLanguage.value = 'hindi';
    } else {
      chatLanguage.value = 'both';
    }
  }
}
