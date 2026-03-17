import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ai_tutor_controller.dart';

/// Screen for generating a 30-day learning roadmap using Gemini AI.
class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final ctrl = Get.find<AiTutorController>();
  final goalCtrl = TextEditingController();

  @override
  void dispose() {
    goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('🗺️ Learning Roadmap',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Banner ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded,
                      color: Color(0xFF8B5CF6), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enter your career goal and get a personalized 30-day learning plan!',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Goal Input ──
            TextField(
              controller: goalCtrl,
              decoration: InputDecoration(
                labelText: 'Career Goal',
                hintText: 'e.g., Backend Developer, Data Scientist',
                prefixIcon: const Icon(Icons.flag_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // ── Generate Button ──
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: ctrl.isLoading.value
                        ? null
                        : () {
                            if (goalCtrl.text.trim().isEmpty) {
                              Get.snackbar(
                                  'Empty', 'Please enter a career goal',
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            ctrl.generateRoadmap(goalCtrl.text.trim());
                          },
                    icon: ctrl.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(ctrl.isLoading.value
                        ? 'Generating...'
                        : 'Generate Roadmap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            const SizedBox(height: 24),

            // ── Roadmap Results ──
            Obx(() {
              final data = ctrl.roadmapResult.value;
              if (data == null) return const SizedBox.shrink();

              final weeks = data['weeks'] as List? ?? [];
              final goal = data['goal']?.toString() ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Goal Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('🎯',
                            style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text('Goal: $goal',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            '${data['total_days'] ?? 30}-Day Learning Plan',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weeks
                  ...List.generate(weeks.length, (wi) {
                    final week = weeks[wi];
                    final weekNum = week['week'] ?? (wi + 1);
                    final theme = week['theme']?.toString() ?? '';
                    final days = week['days'] as List? ?? [];
                    final project =
                        week['weekend_project']?.toString() ?? '';

                    final weekColors = [
                      const Color(0xFF4A90D9),
                      const Color(0xFF10B981),
                      const Color(0xFFFF6B35),
                      const Color(0xFF8B5CF6),
                      const Color(0xFFEF4444),
                    ];
                    final color = weekColors[wi % weekColors.length];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('W$weekNum',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ),
                          title: Text('Week $weekNum',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1A1A2E))),
                          subtitle: Text(theme,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ...List.generate(days.length, (di) {
                                    final day = days[di];
                                    final dayNum =
                                        day['day']?.toString() ?? '';
                                    final topic =
                                        day['topic']?.toString() ?? '';
                                    final tasks =
                                        day['tasks'] as List? ?? [];

                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: color
                                            .withValues(alpha: 0.04),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: color
                                                .withValues(alpha: 0.1)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(6),
                                                ),
                                                child: Text('Day $dayNum',
                                                    style:
                                                        const TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(topic,
                                                    style:
                                                        const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF1A1A2E))),
                                              ),
                                            ],
                                          ),
                                          if (tasks.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            ...tasks.map((t) => Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .only(
                                                          bottom: 3,
                                                          left: 4),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('• ',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade600)),
                                                      Expanded(
                                                        child: Text(
                                                            t.toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontSize:
                                                                    13,
                                                                height:
                                                                    1.3)),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                  // Weekend Project
                                  if (project.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 14),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors
                                                .amber.shade200),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('🛠️',
                                              style: TextStyle(
                                                  fontSize: 18)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                const Text(
                                                    'Weekend Project',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                        fontSize: 13,
                                                        color: Color(
                                                            0xFF1A1A2E))),
                                                const SizedBox(
                                                    height: 4),
                                                Text(project,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                        fontSize: 13,
                                                        height: 1.3)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
