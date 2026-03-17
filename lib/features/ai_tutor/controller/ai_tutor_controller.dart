import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/core/api_service.dart';
import 'package:edusarthi_app/core/constants.dart';

/// GetX controller for the AI Tutor module (Gemini-powered).
class AiTutorController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  // ── Image Analysis ──────────────────────
  final imageAnalysisResult = RxnString();

  Future<void> analyzeImage(String base64Image, {String question = ''}) async {
    isLoading.value = true;
    errorMessage.value = null;
    imageAnalysisResult.value = null;
    try {
      final response = await _api.postApi(
        AppConstants.aiTutorAnalyzeImage,
        {
          'image_base64': base64Image,
          'question': question,
        },
      );
      imageAnalysisResult.value = response['analysis'] ?? 'No analysis available.';
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to analyze image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Lecture Notes ──────────────────────
  final lectureResult = Rxn<Map<String, dynamic>>();

  Future<void> extractLectureNotes(String transcript) async {
    isLoading.value = true;
    errorMessage.value = null;
    lectureResult.value = null;
    try {
      final response = await _api.postApi(
        AppConstants.aiTutorLectureNotes,
        {'transcript': transcript},
      );
      lectureResult.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to extract lecture notes',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ── MCQ Generation ────────────────────
  final mcqResult = Rxn<Map<String, dynamic>>();
  final selectedAnswers = <int, String>{}.obs;
  final showResults = false.obs;

  Future<void> generateMCQs(String topic, {int count = 5}) async {
    isLoading.value = true;
    errorMessage.value = null;
    mcqResult.value = null;
    selectedAnswers.clear();
    showResults.value = false;
    try {
      final response = await _api.postApi(
        AppConstants.aiTutorGenerateMcqs,
        {'topic': topic, 'count': count},
      );
      mcqResult.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to generate MCQs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(int questionIndex, String answer) {
    selectedAnswers[questionIndex] = answer;
  }

  int get score {
    if (mcqResult.value == null) return 0;
    final questions = mcqResult.value!['questions'] as List? ?? [];
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correct_answer']) {
        correct++;
      }
    }
    return correct;
  }

  // ── Roadmap Generation ────────────────
  final roadmapResult = Rxn<Map<String, dynamic>>();

  Future<void> generateRoadmap(String goal) async {
    isLoading.value = true;
    errorMessage.value = null;
    roadmapResult.value = null;
    try {
      final response = await _api.postApi(
        AppConstants.aiTutorGenerateRoadmap,
        {'goal': goal},
      );
      roadmapResult.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to generate roadmap',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Reset ─────────────────────────────
  void resetAll() {
    imageAnalysisResult.value = null;
    lectureResult.value = null;
    mcqResult.value = null;
    roadmapResult.value = null;
    selectedAnswers.clear();
    showResults.value = false;
    errorMessage.value = null;
  }
}
