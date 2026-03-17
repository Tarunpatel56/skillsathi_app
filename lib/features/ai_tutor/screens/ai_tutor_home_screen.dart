import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'image_analysis_screen.dart';
import 'lecture_notes_screen.dart';
import 'mcq_quiz_screen.dart';
import 'roadmap_screen.dart';

/// AI Tutor Home Screen — Gemini-powered learning tools.
class AiTutorHomeScreen extends StatelessWidget {
  const AiTutorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Tutor 🤖',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Hero Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'AI-Powered Learning',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Powered by Google Gemini ✨\nScan questions, generate quizzes, and more!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Feature Cards ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose a Tool',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),

              _TutorFeatureCard(
                title: '📸 Image Analysis',
                subtitle:
                    'Take a photo of any question or diagram — AI explains it step by step',
                gradientColors: const [Color(0xFF4A90D9), Color(0xFF357ABD)],
                icon: Icons.image_search_rounded,
                onTap: () => Get.to(() => const ImageAnalysisScreen()),
              ),
              const SizedBox(height: 14),

              _TutorFeatureCard(
                title: '📝 Lecture Notes',
                subtitle:
                    'Paste a lecture transcript — get key points, definitions & practice questions',
                gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                icon: Icons.description_rounded,
                onTap: () => Get.to(() => const LectureNotesScreen()),
              ),
              const SizedBox(height: 14),

              _TutorFeatureCard(
                title: '🧠 MCQ Quiz',
                subtitle:
                    'Enter any topic — AI generates interactive MCQs with instant scoring',
                gradientColors: const [Color(0xFFFF6B35), Color(0xFFE55D2B)],
                icon: Icons.quiz_rounded,
                onTap: () => Get.to(() => const McqQuizScreen()),
              ),
              const SizedBox(height: 14),

              _TutorFeatureCard(
                title: '🗺️ Learning Roadmap',
                subtitle:
                    'Enter your career goal — get a 30-day learning plan with daily tasks',
                gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                icon: Icons.map_rounded,
                onTap: () => Get.to(() => const RoadmapScreen()),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onTap;

  const _TutorFeatureCard({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
