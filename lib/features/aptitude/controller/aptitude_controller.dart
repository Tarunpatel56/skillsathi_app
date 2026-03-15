import 'package:get/get.dart';
import 'package:edusarthi_app/core/api_service.dart';
import 'package:edusarthi_app/core/constants.dart';
import 'package:edusarthi_app/features/aptitude/models/quiz_model.dart';

/// GetX controller for the Aptitude Quiz module.
class AptitudeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final selectedTopic = 'math'.obs;
  final selectedDifficulty = 'medium'.obs;
  final questionCount = 5.obs;
  final isLoading = false.obs;
  final quizStarted = false.obs;
  final quizSubmitted = false.obs;
  final currentIndex = 0.obs;
  final questions = <QuizQuestion>[].obs;
  final evaluation = Rxn<Map<String, dynamic>>();

  final List<Map<String, String>> topics = [
    {'id': 'math', 'name': '🔢 Mathematics'},
    {'id': 'logic', 'name': '🧩 Logical Reasoning'},
    {'id': 'verbal', 'name': '📝 Verbal Ability'},
    {'id': 'data_interpretation', 'name': '📊 Data Interpretation'},
  ];

  // ── Generate Quiz ─────────────────────────
  Future<void> generateQuiz() async {
    isLoading.value = true;
    try {
      final response = await _api.postApi(
        AppConstants.aptitudeGenerateQuiz,
        {
          'topic': selectedTopic.value,
          'count': questionCount.value,
          'difficulty': selectedDifficulty.value,
        },
      );
      final questionsList = response['questions'] as List;
      questions.value =
          questionsList.map((q) => QuizQuestion.fromJson(q)).toList();
      quizStarted.value = true;
      currentIndex.value = 0;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Submit Quiz ───────────────────────────
  Future<void> submitQuiz() async {
    isLoading.value = true;
    try {
      final response = await _api.postApi(
        AppConstants.aptitudeSubmitQuiz,
        {
          'quiz_data': questions.map((q) => q.toJson()).toList(),
        },
      );
      evaluation.value = response['evaluation'] as Map<String, dynamic>?;
      quizSubmitted.value = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Select Answer ─────────────────────────
  void selectAnswer(String option) {
    questions[currentIndex.value].userAnswer = option;
    questions.refresh();
  }

  // ── Navigation ────────────────────────────
  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  // ── Reset Quiz ────────────────────────────
  void resetQuiz() {
    quizStarted.value = false;
    quizSubmitted.value = false;
    questions.clear();
    evaluation.value = null;
    currentIndex.value = 0;
  }
}
