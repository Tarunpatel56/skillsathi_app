import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../controller/classroom_controller.dart';
import '../widgets/participants_panel.dart';
import '../widgets/notes_panel.dart';

/// Student Dashboard — watch teacher video, chat, raise hand, download notes.
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ClassroomController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showLeaveDialog(ctrl);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Stack(children: [
          _StudentVideoArea(ctrl: ctrl),
          _StudentTopBar(ctrl: ctrl),
          // Debug status banner
          Positioned(top: 100, left: 16, right: 16,
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🔧 ${ctrl.debugStatus.value}',
                style: const TextStyle(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _StudentBottom(ctrl: ctrl)),
        ]),
      ),
    );
  }

  void _showLeaveDialog(ClassroomController ctrl) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Leave Class?', style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('You will be disconnected from the live class.'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Stay')),
        ElevatedButton(
          onPressed: () { Get.back(); ctrl.leaveClassroom(); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
          child: const Text('Leave'),
        ),
      ],
    ));
  }
}

class _StudentVideoArea extends StatelessWidget {
  final ClassroomController ctrl;
  const _StudentVideoArea({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(children: [
      // Teacher's video (full screen)
      SizedBox.expand(
        child: ctrl.hasRemoteStream.value
            ? RTCVideoView(ctrl.remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
            : Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)])),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: const Color(0xFF4A90D9).withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.cast_for_education_rounded, color: Color(0xFF4A90D9), size: 64)),
                  const SizedBox(height: 16),
                  const Text('Waiting for teacher...', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Room: ${ctrl.roomCode.value}', style: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 3)),
                ]))),
      ),
      // Self preview (small)
      Positioned(right: 16, bottom: 200,
        child: Container(width: 90, height: 120,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12)]),
          child: ClipRRect(borderRadius: BorderRadius.circular(12),
            child: ctrl.isCameraOn.value
                ? RTCVideoView(ctrl.localRenderer, mirror: ctrl.isFrontCamera.value, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                : Container(color: const Color(0xFF2A2A3E),
                    child: const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 24)))))),
    ]));
  }
}

class _StudentTopBar extends StatelessWidget {
  final ClassroomController ctrl;
  const _StudentTopBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent])),
        child: Row(children: [
          // Class indicator
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.school_rounded, color: Color(0xFF10B981), size: 14), SizedBox(width: 4),
              Text('IN CLASS', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
            ])),
          const SizedBox(width: 10),
          Obx(() => Text(ctrl.formattedDuration, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]))),
          const Spacer(),
          // Room code
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.meeting_room_rounded, color: Color(0xFF8B5CF6), size: 14), const SizedBox(width: 4),
              Obx(() => Text(ctrl.roomCode.value, style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2))),
            ])),
          const SizedBox(width: 8),
          // Participants
          Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.people_rounded, color: Colors.white54, size: 14), const SizedBox(width: 4),
              Text('${ctrl.participants.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]))),
        ]),
      ),
    );
  }
}

class _StudentBottom extends StatelessWidget {
  final ClassroomController ctrl;
  const _StudentBottom({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = ctrl.currentTab.value;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        if (tab == 0) _StudentControls(ctrl: ctrl),
        if (tab == 1) SizedBox(height: MediaQuery.of(context).size.height * 0.45, child: _StudentChat(ctrl: ctrl)),
        if (tab == 2) SizedBox(height: MediaQuery.of(context).size.height * 0.45, child: const ParticipantsPanel()),
        if (tab == 3) SizedBox(height: MediaQuery.of(context).size.height * 0.45, child: const NotesPanel()),
        // Nav Bar
        Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, top: 8),
          decoration: BoxDecoration(color: const Color(0xFF12121F), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavItem(icon: Icons.videocam_rounded, label: 'Controls', isActive: tab == 0, onTap: () => ctrl.currentTab.value = 0),
            _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', isActive: tab == 1, onTap: () => ctrl.currentTab.value = 1),
            _NavItem(icon: Icons.people_rounded, label: 'People', isActive: tab == 2, onTap: () => ctrl.currentTab.value = 2),
            _NavItem(icon: Icons.description_rounded, label: 'Notes', isActive: tab == 3, onTap: () => ctrl.currentTab.value = 3),
          ]),
        ),
      ]);
    });
  }
}

class _StudentControls extends StatelessWidget {
  final ClassroomController ctrl;
  const _StudentControls({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)])),
      child: Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _CtrlBtn(icon: ctrl.isMicOn.value ? Icons.mic_rounded : Icons.mic_off_rounded, label: ctrl.isMicOn.value ? 'Mute' : 'Unmute',
          isActive: !ctrl.isMicOn.value, onTap: ctrl.toggleMic),
        _CtrlBtn(icon: ctrl.isCameraOn.value ? Icons.videocam_rounded : Icons.videocam_off_rounded, label: ctrl.isCameraOn.value ? 'Cam Off' : 'Cam On',
          isActive: !ctrl.isCameraOn.value, onTap: ctrl.toggleCamera),
        _CtrlBtn(icon: ctrl.isHandRaised.value ? Icons.front_hand_rounded : Icons.front_hand_rounded, label: ctrl.isHandRaised.value ? 'Lower' : 'Raise Hand',
          isActive: ctrl.isHandRaised.value, isHand: true, onTap: ctrl.toggleHandRaise),
        // Leave
        GestureDetector(
          onTap: () => Get.dialog(AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Leave Class?'), content: const Text('You will be disconnected.'),
            actions: [TextButton(onPressed: () => Get.back(), child: const Text('Stay')),
              ElevatedButton(onPressed: () { Get.back(); ctrl.leaveClassroom(); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white), child: const Text('Leave'))])),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])),
              child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 24)),
            const SizedBox(height: 6),
            Text('Leave', style: TextStyle(color: Colors.red.shade300, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ])),
    );
  }
}

class _StudentChat extends StatelessWidget {
  final ClassroomController ctrl;
  const _StudentChat({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)))),
          child: const Row(children: [
            Icon(Icons.chat_bubble_rounded, color: Color(0xFF4A90D9), size: 22), SizedBox(width: 10),
            Text('Class Chat', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ])),
        Expanded(child: Obx(() {
          if (ctrl.chatMessages.isEmpty) return Center(child: Text('No messages yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))));
          return ListView.builder(padding: const EdgeInsets.all(12), itemCount: ctrl.chatMessages.length, itemBuilder: (_, i) {
            final msg = ctrl.chatMessages[i];
            final isMe = msg.sender == ctrl.studentName.value;
            return Padding(padding: const EdgeInsets.only(bottom: 8),
              child: Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: isMe ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (!isMe) Padding(padding: const EdgeInsets.only(bottom: 4),
                      child: Text(msg.sender, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold))),
                    Text(msg.text, style: TextStyle(color: isMe ? Colors.white : Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  ]))));
          });
        })),
        Container(padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1)))),
          child: Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
              child: TextField(controller: ctrl.chatTextController, style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(hintText: 'Ask a question...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)), border: InputBorder.none),
                onSubmitted: (_) => ctrl.sendChatMessage()))),
            const SizedBox(width: 8),
            Container(decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)])),
              child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: ctrl.sendChatMessage)),
          ])),
      ]),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon; final String label; final bool isActive; final VoidCallback onTap; final bool isHand;
  const _CtrlBtn({required this.icon, required this.label, required this.isActive, required this.onTap, this.isHand = false});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (isHand ? const Color(0xFFFBBF24) : const Color(0xFFEF4444)) : Colors.white;
    return GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: isActive ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          border: isActive ? Border.all(color: color, width: 2) : null),
        child: Icon(icon, color: color, size: 22)),
      const SizedBox(height: 5),
      Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500)),
    ]));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final bool isActive; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isActive ? const Color(0xFF8B5CF6).withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: isActive ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.5), size: 24)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.4), fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ])));
  }
}
