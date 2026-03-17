import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../controller/video_call_controller.dart';
import '../widgets/network_quality_indicator.dart';
import '../widgets/in_call_chat.dart';
import '../widgets/whiteboard_widget.dart';

/// Full-screen video call screen with custom bottom navigation bar.
class VideoCallScreen extends StatelessWidget {
  final String roomId;
  final bool creator;

  const VideoCallScreen({
    super.key,
    this.roomId = 'default-room',
    this.creator = true,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VideoCallController>();

    // Auto-start call when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ctrl.isInCall.value) {
        ctrl.startCall(roomId: roomId, creator: creator);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // ── Video Views ────────────────
          _VideoViews(ctrl: ctrl),

          // ── Top Bar (Timer, Quality, PiP) ──
          _TopBar(ctrl: ctrl),

          // ── Poor Connection Banner ──
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: PoorConnectionBanner(),
          ),

          // ── Recording Indicator ──
          Positioned(
            top: 100,
            left: 16,
            child: Obx(() => ctrl.isRecording.value
                ? _RecordingIndicator()
                : const SizedBox.shrink()),
          ),

          // ── Hand Raise Indicator ──
          Positioned(
            top: 140,
            right: 16,
            child: Obx(() => ctrl.isHandRaised.value
                ? _HandRaiseIndicator()
                : const SizedBox.shrink()),
          ),

          // ── Bottom Section (Tab Content + Nav Bar) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomSection(ctrl: ctrl),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  VIDEO VIEWS
// ═══════════════════════════════════════════════
class _VideoViews extends StatelessWidget {
  final VideoCallController ctrl;
  const _VideoViews({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!ctrl.isInCall.value) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4A90D9)),
              SizedBox(height: 16),
              Text('Connecting...',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        );
      }

      return Stack(
        children: [
          // Remote Video (full screen)
          SizedBox.expand(
            child: ctrl.remoteRenderer.srcObject != null
                ? RTCVideoView(ctrl.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Color(0xFF4A90D9), size: 64),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Waiting for participant...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Local Video (PiP overlay — draggable)
          Obx(() => Positioned(
                right: 16,
                top: ctrl.isPipMode.value ? 60 : 120,
                child: GestureDetector(
                  onDoubleTap: () {
                    // TODO: Swap local/remote views
                  },
                  child: Container(
                    width: ctrl.isPipMode.value ? 90 : 120,
                    height: ctrl.isPipMode.value ? 120 : 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF4A90D9), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ctrl.isCameraOn.value
                          ? RTCVideoView(ctrl.localRenderer,
                              mirror: ctrl.isFrontCamera.value,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover)
                          : Container(
                              color: const Color(0xFF2A2A3E),
                              child: const Center(
                                child: Icon(Icons.videocam_off_rounded,
                                    color: Colors.white38, size: 32),
                              ),
                            ),
                    ),
                  ),
                ),
              )),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final VideoCallController ctrl;
  const _TopBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back / Minimize
            _CircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => ctrl.endCall(),
            ),
            const SizedBox(width: 12),

            // Call Timer
            Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ctrl.isRecording.value
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ctrl.formattedCallDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                )),

            const Spacer(),

            // Network Quality
            const NetworkQualityIndicator(),

            const SizedBox(width: 8),

            // PiP Button
            _CircleButton(
              icon: Icons.picture_in_picture_alt_rounded,
              onTap: ctrl.togglePipMode,
            ),

            const SizedBox(width: 8),

            // Camera Switch
            _CircleButton(
              icon: Icons.cameraswitch_rounded,
              onTap: () => ctrl.switchCamera(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circle button for top bar.
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  BOTTOM SECTION (Tab Content + Navigation Bar)
// ═══════════════════════════════════════════════
class _BottomSection extends StatelessWidget {
  final VideoCallController ctrl;
  const _BottomSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = ctrl.currentBottomTab.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tab Content Area ──
          if (tab == 0) _ControlsTab(ctrl: ctrl),
          if (tab == 1)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: const InCallChat(),
            ),
          if (tab == 2)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: const WhiteboardWidget(),
            ),
          if (tab == 3) _MoreTab(ctrl: ctrl),

          // ── Navigation Bar ──
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              top: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF12121F),
              border: Border(
                top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.gamepad_outlined,
                  activeIcon: Icons.gamepad_rounded,
                  label: 'Controls',
                  isActive: tab == 0,
                  onTap: () => ctrl.currentBottomTab.value = 0,
                ),
                _NavBarItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isActive: tab == 1,
                  onTap: () => ctrl.currentBottomTab.value = 1,
                  badge: ctrl.chatMessages.length,
                ),
                _NavBarItem(
                  icon: Icons.draw_outlined,
                  activeIcon: Icons.draw_rounded,
                  label: 'Whiteboard',
                  isActive: tab == 2,
                  onTap: () => ctrl.currentBottomTab.value = 2,
                ),
                _NavBarItem(
                  icon: Icons.more_horiz_rounded,
                  activeIcon: Icons.more_horiz_rounded,
                  label: 'More',
                  isActive: tab == 3,
                  onTap: () => ctrl.currentBottomTab.value = 3,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════
//  TAB 0: CONTROLS
// ═══════════════════════════════════════════════
class _ControlsTab extends StatelessWidget {
  final VideoCallController ctrl;
  const _ControlsTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Primary Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: ctrl.isMicOn.value
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    label: ctrl.isMicOn.value ? 'Mute' : 'Unmute',
                    isActive: !ctrl.isMicOn.value,
                    activeColor: const Color(0xFFEF4444),
                    onTap: ctrl.toggleMic,
                  ),
                  _ControlButton(
                    icon: ctrl.isCameraOn.value
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    label: ctrl.isCameraOn.value ? 'Cam Off' : 'Cam On',
                    isActive: !ctrl.isCameraOn.value,
                    activeColor: const Color(0xFFEF4444),
                    onTap: ctrl.toggleCamera,
                  ),
                  _ControlButton(
                    icon: ctrl.isSpeakerOn.value
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    label: ctrl.isSpeakerOn.value ? 'Speaker' : 'Earpiece',
                    isActive: false,
                    onTap: ctrl.toggleSpeaker,
                  ),
                  _EndCallButton(onTap: () => ctrl.endCall()),
                ],
              ),
              const SizedBox(height: 12),

              // ── Secondary Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: Icons.screen_share_rounded,
                    label: ctrl.isScreenSharing.value ? 'Stop Share' : 'Share',
                    isActive: ctrl.isScreenSharing.value,
                    activeColor: const Color(0xFF4A90D9),
                    onTap: () => ctrl.toggleScreenSharing(),
                  ),
                  _ControlButton(
                    icon: Icons.fiber_manual_record_rounded,
                    label: ctrl.isRecording.value ? 'Stop Rec' : 'Record',
                    isActive: ctrl.isRecording.value,
                    activeColor: const Color(0xFFEF4444),
                    onTap: () => ctrl.toggleRecording(),
                  ),
                  _ControlButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Snapshot',
                    isActive: false,
                    onTap: () => ctrl.captureSnapshot(),
                  ),
                  _ControlButton(
                    icon: Icons.cameraswitch_rounded,
                    label: 'Flip Cam',
                    isActive: false,
                    onTap: () => ctrl.switchCamera(),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

// ═══════════════════════════════════════════════
//  TAB 3: MORE
// ═══════════════════════════════════════════════
class _MoreTab extends StatelessWidget {
  final VideoCallController ctrl;
  const _MoreTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12121F).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MoreOption(
                icon: Icons.back_hand_rounded,
                label: ctrl.isHandRaised.value
                    ? 'Lower Hand ✋'
                    : 'Raise Hand ✋',
                subtitle: 'Notify mentor you have a question',
                color: const Color(0xFFFBBF24),
                isActive: ctrl.isHandRaised.value,
                onTap: ctrl.toggleHandRaise,
              ),
              const SizedBox(height: 10),
              _MoreOption(
                icon: Icons.picture_in_picture_alt_rounded,
                label: 'Picture-in-Picture',
                subtitle: 'Minimize call to a floating window',
                color: const Color(0xFF8B5CF6),
                isActive: ctrl.isPipMode.value,
                onTap: ctrl.togglePipMode,
              ),
              const SizedBox(height: 10),
              _MoreOption(
                icon: Icons.info_outline_rounded,
                label: 'Call Info',
                subtitle:
                    'Duration: ${ctrl.formattedCallDuration} • Quality: ${ctrl.networkQuality.value >= 3 ? "Good" : ctrl.networkQuality.value == 2 ? "Fair" : "Poor"}',
                color: const Color(0xFF4A90D9),
                isActive: false,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _MoreOption(
                icon: Icons.history_rounded,
                label: 'Call History',
                subtitle: 'View past calls',
                color: const Color(0xFF10B981),
                isActive: false,
                onTap: () => Get.to(() => const CallHistoryScreenInMore()),
              ),
            ],
          )),
    );
  }
}

/// Call history accessible from the "More" tab.
class CallHistoryScreenInMore extends StatelessWidget {
  const CallHistoryScreenInMore({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VideoCallController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Call History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF12121F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.callHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded,
                    color: Colors.white.withValues(alpha: 0.2), size: 56),
                const SizedBox(height: 12),
                Text(
                  'No call history yet',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 16),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.callHistory.length,
          itemBuilder: (_, i) {
            final entry = ctrl.callHistory[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam_rounded,
                      color: Color(0xFF4A90D9), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.callerName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        Text(
                          '${entry.formattedTime} • ${entry.formattedDuration}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════

/// Control button for the controls tab.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? const Color(0xFF4A90D9))
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              border: isActive
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Red end call button.
class _EndCallButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EndCallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66EF4444),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.call_end_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text('End',
              style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Nav bar item for the custom bottom bar.
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badge;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4A90D9).withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive
                        ? const Color(0xFF4A90D9)
                        : Colors.white.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ),
                // Badge
                if (badge > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF4A90D9)
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "More" tab option row.
class _MoreOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _MoreOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: color.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12)),
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle_rounded,
                  color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Recording indicator blinker.
class _RecordingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
          SizedBox(width: 4),
          Text('REC',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Hand raise indicator.
class _HandRaiseIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✋', style: TextStyle(fontSize: 14)),
          SizedBox(width: 4),
          Text('Hand Raised',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
