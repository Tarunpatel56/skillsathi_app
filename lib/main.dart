import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/core/api_service.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';
import 'package:edusarthi_app/features/interview/controller/interview_controller.dart';
import 'package:edusarthi_app/features/aptitude/controller/aptitude_controller.dart';
import 'package:edusarthi_app/features/english/screens/chat_screen.dart';
import 'package:edusarthi_app/features/english/screens/english_home_screen.dart';
import 'package:edusarthi_app/features/english/screens/grammar_fix_screen.dart';
import 'package:edusarthi_app/features/interview/screens/interview_screen.dart';
import 'package:edusarthi_app/features/aptitude/screens/quiz_screen.dart';
import 'package:edusarthi_app/features/profile/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  _initServices();
  runApp(const SkillSathiApp());
}

void _initServices() {
  Get.put(ApiService());
  Get.lazyPut(() => EnglishController(), fenix: true);
  Get.lazyPut(() => InterviewController(), fenix: true);
  Get.lazyPut(() => AptitudeController(), fenix: true);
}

class SkillSathiApp extends StatelessWidget {
  const SkillSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkillSathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorSchemeSeed: const Color(0xFF4A90D9),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF4A90D9).withValues(alpha: 0.12),
          surfaceTintColor: Colors.white,
          elevation: 3,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home Screen with bottom navigation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;

    final screens = const [
      DashboardScreen(),
      EnglishHomeScreen(),
      InterviewScreen(),
      QuizScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: currentIndex.value,
          onDestinationSelected: (i) => currentIndex.value = i,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF4A90D9)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon:
                  Icon(Icons.menu_book_rounded, color: Color(0xFF4A90D9)),
              label: 'English',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon:
                  Icon(Icons.work_rounded, color: Color(0xFF4A90D9)),
              label: 'Interview',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon:
                  Icon(Icons.quiz_rounded, color: Color(0xFF4A90D9)),
              label: 'Aptitude',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon:
                  Icon(Icons.person_rounded, color: Color(0xFF4A90D9)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Header ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back! 👋',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SkillSathi',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF4A90D9)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Learn Smart, Grow Fast 🚀',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ── Daily Streak Card ──────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔥 Daily Streak',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                        SizedBox(height: 6),
                        Text('1 Day',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Keep learning today!',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    Spacer(),
                    Text('🎯', style: TextStyle(fontSize: 48)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Skill Progress ─────────────
              const Text('Your Progress',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SkillChip('English', 0.3, const Color(0xFF4A90D9)),
                  const SizedBox(width: 10),
                  _SkillChip('Interview', 0.1, const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  _SkillChip('Aptitude', 0.2, const Color(0xFFFF6B35)),
                ],
              ),
              const SizedBox(height: 28),

              // ── Feature Cards ──────────────
              const Text('Start Learning',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _FeatureCard(
                title: 'English Learning',
                subtitle: 'Lessons, Grammar, Vocabulary, AI Chat',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF4A90D9),
                onTap: () => Get.to(() => const EnglishHomeScreen()),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                title: 'Interview Prep',
                subtitle:
                    'Mock Interviews, Answer Evaluation, Common Questions',
                icon: Icons.work_rounded,
                color: const Color(0xFF10B981),
                onTap: () => Get.to(() => const InterviewScreen()),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                title: 'Aptitude Quizzes',
                subtitle: 'Math, Logic, Verbal, Data Interpretation',
                icon: Icons.quiz_rounded,
                color: const Color(0xFFFF6B35),
                onTap: () => Get.to(() => const QuizScreen()),
              ),
              const SizedBox(height: 24),

              // ── Quick Actions ──────────────
              const Text('Quick Actions',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickAction(
                    label: 'AI Chat',
                    icon: Icons.chat_rounded,
                    color: const Color(0xFF4A90D9),
                    onTap: () => Get.to(() => const ChatScreen()),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'Grammar\nCheck',
                    icon: Icons.spellcheck_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Get.to(() => const GrammarFixScreen()),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'Quick\nQuiz',
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFFF6B35),
                    onTap: () => Get.to(() => const QuizScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skill progress chip
class _SkillChip extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _SkillChip(this.label, this.progress, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              width: 44,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: color.withValues(alpha: 0.15),
                    color: color,
                  ),
                  Center(
                    child: Text('${(progress * 100).toInt()}%',
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature card for dashboard.
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
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
                          color: Colors.grey.shade600, fontSize: 13)),
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

/// Quick action button.
class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}
