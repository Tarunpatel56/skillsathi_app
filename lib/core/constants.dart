

/// SkillSathi App Constants
class AppConstants {
  AppConstants._();

  // ── App Info ───────────────────────────────
  static const String appName = 'SkillSathi';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Learn Smart, Grow Fast';

  // ── API Base URL ──────────────────────────
  // Using adb reverse: phone's localhost:8000 → PC's localhost:8000
  static String get baseUrl {
    const envUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    // adb reverse tcp:8000 tcp:8000 — maps phone's localhost to PC
    return 'http://127.0.0.1:8000/api/v1';
  }

  // ── API Endpoints ─────────────────────────
  // English Module
  static const String englishChat = '/english/chat';
  static const String englishGrammar = '/english/grammar-check';
  static const String englishVocabulary = '/english/vocabulary';
  static const String englishTranslate = '/english/translate';
  static const String englishLessons = '/english/lessons';
  static const String englishLesson = '/english/lesson';
  static const String englishLevels = '/english/levels';
  static const String englishCheckSentence = '/english/check-sentence';
  static const String englishLessonTest = '/english/lesson-test';
  static const String englishEvaluateTest = '/english/evaluate-test';

  // Interview Module
  static const String interviewStart = '/interview/start';
  static const String interviewAnswer = '/interview/answer';
  static const String interviewEvaluate = '/interview/evaluate';
  static const String interviewCommonQs = '/interview/common-questions';

  // Aptitude Module
  static const String aptitudeGenerateQuiz = '/aptitude/generate-quiz';
  static const String aptitudeSubmitQuiz = '/aptitude/submit-quiz';
  static const String aptitudeTopics = '/aptitude/topics';

  // AI Tutor Module (Gemini)
  static const String aiTutorAnalyzeImage = '/ai-tutor/analyze-image';
  static const String aiTutorLectureNotes = '/ai-tutor/lecture-notes';
  static const String aiTutorGenerateMcqs = '/ai-tutor/generate-mcqs';
  static const String aiTutorGenerateRoadmap = '/ai-tutor/generate-roadmap';

  // ── Theme Colors (Light Blue + White) ─────
  static const int primaryColorHex = 0xFF4A90D9;     // Light Blue
  static const int primaryLightHex = 0xFFE3F2FD;     // Very Light Blue
  static const int backgroundHex = 0xFFF8FAFC;       // Off-White
  static const int surfaceHex = 0xFFFFFFFF;           // White
  static const int textPrimaryHex = 0xFF1A1A2E;      // Dark Navy
  static const int textSecondaryHex = 0xFF6B7280;    // Gray
  static const int accentGreenHex = 0xFF10B981;      // Green
  static const int accentOrangeHex = 0xFFFF6B35;     // Orange
  static const int accentTealHex = 0xFF00BFA6;       // Teal
  static const int errorHex = 0xFFEF4444;            // Red

  // ── Animation Durations ───────────────────
  static const int shortAnimMs = 200;
  static const int mediumAnimMs = 400;
  static const int longAnimMs = 600;

  // ── Misc ──────────────────────────────────
  static const int maxChatHistory = 50;
  static const int quizTimePerQuestionSec = 60;
}
