import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/classroom_controller.dart';

/// Participants panel widget.
class ParticipantsPanel extends StatelessWidget {
  const ParticipantsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ClassroomController>();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_rounded,
                    color: Color(0xFF4A90D9), size: 22),
                const SizedBox(width: 10),
                const Text('Participants',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${ctrl.participants.length}',
                        style: const TextStyle(
                            color: Color(0xFF4A90D9),
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    )),
              ],
            ),
          ),

          // ── Teacher: Mute All Button ──
          Obx(() => ctrl.isTeacher.value
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: ctrl.muteAllStudents,
                      icon: const Icon(Icons.volume_off_rounded, size: 18),
                      label: const Text('Mute All Students'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // ── Participant List ──
          Expanded(
            child: Obx(() {
              if (ctrl.participants.isEmpty) {
                return Center(
                  child: Text('No participants yet',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4))),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ctrl.participants.length,
                itemBuilder: (_, i) {
                  final p = ctrl.participants[i];
                  return _ParticipantTile(
                    participant: p,
                    isTeacherView: ctrl.isTeacher.value,
                    onMute: () => ctrl.muteStudent(p.userId),
                    onRemove: () => ctrl.removeStudent(p.userId),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;
  final bool isTeacherView;
  final VoidCallback onMute;
  final VoidCallback onRemove;

  const _ParticipantTile({
    required this.participant,
    required this.isTeacherView,
    required this.onMute,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isTeacherRole = participant.role == 'teacher';
    final roleColor =
        isTeacherRole ? const Color(0xFF10B981) : const Color(0xFF4A90D9);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: participant.isHandRaised
            ? Border.all(color: const Color(0xFFFBBF24), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.name.isNotEmpty
                    ? participant.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: roleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(participant.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    if (isTeacherRole) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('HOST',
                            style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      participant.isMuted
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      color: participant.isMuted
                          ? const Color(0xFFEF4444)
                          : Colors.white38,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      participant.isCameraOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      color: participant.isCameraOn
                          ? Colors.white38
                          : const Color(0xFFEF4444),
                      size: 14,
                    ),
                    if (participant.isHandRaised) ...[
                      const SizedBox(width: 8),
                      const Text('✋', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Teacher actions
          if (isTeacherView && !isTeacherRole) ...[
            IconButton(
              icon: const Icon(Icons.mic_off_rounded,
                  color: Color(0xFFFBBF24), size: 20),
              onPressed: onMute,
              tooltip: 'Mute',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.person_remove_rounded,
                  color: Color(0xFFEF4444), size: 20),
              onPressed: onRemove,
              tooltip: 'Remove',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ],
      ),
    );
  }
}
