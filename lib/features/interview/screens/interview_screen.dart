import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/interview/controller/interview_controller.dart';

/// Interview Screen – light theme.
class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterviewController>();
    final roleController = TextEditingController();
    final answerController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Interview Prep',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            if (!controller.interviewStarted.value) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: controller.resetInterview,
              tooltip: 'New Interview',
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() => controller.interviewStarted.value
            ? _buildInterviewUI(controller, answerController, roleController)
            : _buildSetupUI(controller, roleController)),
      ),
    );
  }

  Widget _buildSetupUI(
      InterviewController controller, TextEditingController roleController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.work_rounded,
                    size: 48, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 16),
              const Text('Mock Interview',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Practice with AI Interviewer',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Role Input
        TextField(
          controller: roleController,
          style: const TextStyle(color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            labelText: 'Job Role',
            labelStyle: TextStyle(color: Colors.grey.shade600),
            hintText: 'e.g. Software Engineer',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
            prefixIcon:
                const Icon(Icons.badge_outlined, color: Color(0xFF10B981)),
          ),
        ),
        const SizedBox(height: 16),

        // Experience
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                  'Experience: ${controller.experience.value} years',
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500))),
              Obx(() => Slider(
                    value: controller.experience.value.toDouble(),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    activeColor: const Color(0xFF10B981),
                    label: '${controller.experience.value}',
                    onChanged: (v) =>
                        controller.experience.value = v.round(),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interview Type
        Obx(
          () => Row(
            children: ['HR', 'Technical', 'Behavioral'].map((type) {
              final selected = controller.selectedType.value == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => controller.selectedType.value = type,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF10B981)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade300),
                      ),
                      child: Text(type,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Start Button
        Obx(
          () => ElevatedButton.icon(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.startInterview(roleController.text),
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow_rounded),
            label: Text(controller.isLoading.value
                ? 'Starting...'
                : 'Start Interview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewUI(
    InterviewController controller,
    TextEditingController answerController,
    TextEditingController roleController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_rounded,
                      color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                      'Question ${controller.history.length + 1}',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => Text(controller.currentQuestion.value ?? '',
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 15,
                      height: 1.5))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Feedback
        Obx(() {
          if (controller.feedback.value == null) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 Feedback',
                    style: TextStyle(
                        color: Color(0xFF4A90D9),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 6),
                Text(controller.feedback.value!,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                        fontSize: 13)),
              ],
            ),
          );
        }),

        // Answer
        TextField(
          controller: answerController,
          maxLines: 4,
          style: const TextStyle(color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Obx(
          () => ElevatedButton.icon(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    controller
                        .submitAnswer(
                            answerController.text, roleController.text)
                        .then((_) => answerController.clear());
                  },
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded),
            label: Text(controller.isLoading.value
                ? 'Evaluating...'
                : 'Submit Answer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
