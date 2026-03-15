import 'package:get/get.dart';
import 'package:edusarthi_app/core/api_service.dart';
import 'package:edusarthi_app/core/constants.dart';

/// GetX controller for the Interview Prep module.
class InterviewController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final selectedType = 'HR'.obs;
  final experience = 0.obs;
  final isLoading = false.obs;
  final interviewStarted = false.obs;
  final currentQuestion = RxnString();
  final feedback = RxnString();
  final history = <Map<String, String>>[].obs;

  // ── Start Interview ───────────────────────
  Future<void> startInterview(String role) async {
    if (role.trim().isEmpty) return;
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.interviewStart,
        {
          'role': role.trim(),
          'experience': experience.value,
          'interview_type': selectedType.value,
        },
      );
      interviewStarted.value = true;
      currentQuestion.value = response['question'];
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Submit Answer ─────────────────────────
  Future<void> submitAnswer(String answer, String role) async {
    if (answer.trim().isEmpty || currentQuestion.value == null) return;
    isLoading.value = true;

    try {
      final response = await _api.postApi(
        AppConstants.interviewAnswer,
        {
          'question': currentQuestion.value,
          'answer': answer.trim(),
          'role': role.trim(),
          'conversation_history': history
              .map((h) => 'Q: ${h['q']}\nA: ${h['a']}')
              .join('\n\n'),
        },
      );
      history.add({'q': currentQuestion.value!, 'a': answer.trim()});
      currentQuestion.value = response['question'];
      feedback.value = response['feedback'];
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Reset Interview ───────────────────────
  void resetInterview() {
    interviewStarted.value = false;
    currentQuestion.value = null;
    feedback.value = null;
    history.clear();
  }
}
