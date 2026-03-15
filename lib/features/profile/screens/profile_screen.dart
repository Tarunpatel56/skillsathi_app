import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Profile Screen – User info, stats, settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Avatar + Name ────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF4A90D9).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('T',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Tarun',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('EduSarthi Learner',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBadge('🔥 1', 'Streak'),
                      const SizedBox(width: 20),
                      _StatBadge('📚 3', 'Lessons'),
                      const SizedBox(width: 20),
                      _StatBadge('🏆 0', 'Quizzes'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Progress Section ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Learning Progress',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 16),
                  _ProgressRow(
                      'English', 0.3, const Color(0xFF4A90D9), Icons.menu_book_rounded),
                  const SizedBox(height: 14),
                  _ProgressRow(
                      'Interview', 0.1, const Color(0xFF10B981), Icons.work_rounded),
                  const SizedBox(height: 14),
                  _ProgressRow(
                      'Aptitude', 0.2, const Color(0xFFFF6B35), Icons.quiz_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Settings ─────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    title: 'App Language',
                    subtitle: 'English',
                    color: const Color(0xFF4A90D9),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _SettingsTile(
                    icon: Icons.wifi_rounded,
                    title: 'API Server',
                    subtitle: 'Connected',
                    color: const Color(0xFF10B981),
                    onTap: () => _showApiDialog(),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About EduSarthi',
                    subtitle: 'v1.0.0',
                    color: Colors.grey.shade600,
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _SettingsTile(
                    icon: Icons.share_rounded,
                    title: 'Share App',
                    subtitle: 'Tell your friends',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showApiDialog() {
    Get.snackbar(
      'API Status',
      'Backend server is running on port 8000',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;
  final IconData icon;
  const _ProgressRow(this.label, this.progress, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text('${(progress * 100).toInt()}%',
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withValues(alpha: 0.15),
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
