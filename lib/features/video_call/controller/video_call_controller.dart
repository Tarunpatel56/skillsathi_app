import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../services/firebase_signaling_service.dart';

/// Model for a chat message during a call.
class ChatMessage {
  final String sender;
  final String text;
  final DateTime time;

  ChatMessage({required this.sender, required this.text, DateTime? time})
      : time = time ?? DateTime.now();
}

/// Model for a call history entry.
class CallHistoryEntry {
  final String id;
  final String callerName;
  final String callType; // 'incoming', 'outgoing', 'missed'
  final DateTime timestamp;
  final Duration duration;

  CallHistoryEntry({
    required this.id,
    required this.callerName,
    required this.callType,
    required this.timestamp,
    required this.duration,
  });

  String get formattedDuration {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String get formattedTime => DateFormat('dd MMM, hh:mm a').format(timestamp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'callerName': callerName,
        'callType': callType,
        'timestamp': timestamp.toIso8601String(),
        'durationSeconds': duration.inSeconds,
      };

  factory CallHistoryEntry.fromJson(Map<String, dynamic> json) =>
      CallHistoryEntry(
        id: json['id'],
        callerName: json['callerName'],
        callType: json['callType'],
        timestamp: DateTime.parse(json['timestamp']),
        duration: Duration(seconds: json['durationSeconds']),
      );
}

/// Central GetX controller for video call state & logic.
/// Now uses Firebase Realtime Database for signaling (no custom server needed).
class VideoCallController extends GetxController {
  // ── WebRTC ────────────────────────────
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  // ── Firebase Signaling ────────────────
  final FirebaseSignalingService signaling = FirebaseSignalingService();

  // ── Observable States ─────────────────
  final isInCall = false.obs;
  final isMicOn = true.obs;
  final isCameraOn = true.obs;
  final isFrontCamera = true.obs;
  final isSpeakerOn = true.obs;
  final isScreenSharing = false.obs;
  final isRecording = false.obs;
  final isHandRaised = false.obs;
  final hasRemoteStream = false.obs;

  // ── Network Quality (0-3: none, poor, fair, good) ──
  final networkQuality = 3.obs;
  Timer? _statsTimer;

  // ── Call Timer ─────────────────────────
  final callDuration = Duration.zero.obs;
  Timer? _callTimer;

  // ── In-Call Chat ──────────────────────
  final chatMessages = <ChatMessage>[].obs;
  final chatTextController = TextEditingController();

  // ── Call History ───────────────────────
  final callHistory = <CallHistoryEntry>[].obs;

  // ── Bottom Tab ────────────────────────
  final currentBottomTab = 0.obs;

  // ── PiP ───────────────────────────────
  final isPipMode = false.obs;

  // ── Recording ─────────────────────────
  MediaRecorder? _mediaRecorder;

  // ── ICE Servers (STUN + TURN for NAT traversal) ──
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  String _currentRoomId = '';
  final String _userId = const Uuid().v4();
  bool _isCreator = false;

  // ── ICE Candidate Buffering ──────────
  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _pendingCandidates = [];

  @override
  void onInit() {
    super.onInit();
    _initRenderers();
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> _dispose() async {
    _callTimer?.cancel();
    _statsTimer?.cancel();
    chatTextController.dispose();
    await _localStream?.dispose();
    await _peerConnection?.close();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    await signaling.disconnect();
  }

  // ═══════════════════════════════════════
  //  PERMISSIONS
  // ═══════════════════════════════════════
  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    return camera.isGranted && mic.isGranted;
  }

  // ═══════════════════════════════════════
  //  START / END CALL
  // ═══════════════════════════════════════
  Future<void> startCall({required String roomId, bool creator = true}) async {
    final granted = await requestPermissions();
    if (!granted) {
      Get.snackbar('Permission Denied', 'Camera & Mic permissions are required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
      return;
    }

    _currentRoomId = roomId;
    _isCreator = creator;

    // Get local media
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      },
    });

    localRenderer.srcObject = _localStream;

    // Enable speaker for remote audio output
    await Helper.setSpeakerphoneOn(true);

    // Create peer connection with TURN servers
    _peerConnection = await createPeerConnection(_iceServers);

    // Add local tracks to peer connection
    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onIceCandidate = (candidate) {
      print('🧊 Sending ICE candidate');
      signaling.sendCandidate(candidate);
    };

    // Remote track handler (unified-plan)
    _peerConnection!.onTrack = (event) {
      print('📺 onTrack: ${event.streams.length} streams, kind: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
        hasRemoteStream.value = true;
        print('📺 Remote video attached!');
      }
    };

    // Fallback: onAddStream for older WebRTC implementations
    _peerConnection!.onAddStream = (MediaStream stream) {
      print('📺 onAddStream received!');
      _remoteStream = stream;
      remoteRenderer.srcObject = stream;
      hasRemoteStream.value = true;
    };

    _peerConnection!.onIceConnectionState = (state) {
      print('🔌 ICE State: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        networkQuality.value = 3;
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        networkQuality.value = 0;
        if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _peerConnection?.restartIce();
        }
      }
    };

    // Setup Firebase signaling callbacks
    signaling.onOffer = _handleRemoteOffer;
    signaling.onAnswer = _handleRemoteAnswer;
    signaling.onCandidate = _handleRemoteCandidate;
    signaling.onRemoteHangUp = endCall;
    signaling.onChatMessage = _onRemoteChatMessage;

    // When another participant joins, the creator sends the offer
    signaling.onParticipantJoined = (data) {
      final joinedUserId = data['userId'] ?? '';
      if (joinedUserId == _userId) return; // Ignore self
      print('👋 Participant joined: ${data['userName']}');
      if (_isCreator) {
        // Creator sends offer after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () async {
          final offer = await _peerConnection!.createOffer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': true,
          });
          await _peerConnection!.setLocalDescription(offer);
          await signaling.sendOffer(offer);
          print('📤 Offer sent');
        });
      }
    };

    try {
      await signaling.joinRoom(
        roomId,
        _userId,
        userName: 'User',
        role: creator ? 'caller' : 'callee',
      );
    } catch (error) {
      await _resetFailedCallStart();
      Get.snackbar(
        'Video Call Unavailable',
        _friendlyError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isInCall.value = true;

    // Start call timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDuration.value += const Duration(seconds: 1);
    });

    // Start network quality monitoring
    _startNetworkMonitoring();
  }

  Future<void> endCall() async {
    _callTimer?.cancel();
    _statsTimer?.cancel();

    // Save to call history
    if (callDuration.value.inSeconds > 0) {
      callHistory.insert(
          0,
          CallHistoryEntry(
            id: const Uuid().v4(),
            callerName: 'Mentor',
            callType: 'outgoing',
            timestamp: DateTime.now(),
            duration: callDuration.value,
          ));
    }

    await signaling.sendHangUp();
    await signaling.disconnect();

    await _localStream?.dispose();
    _localStream = null;
    await _peerConnection?.close();
    _peerConnection = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    isInCall.value = false;
    isMicOn.value = true;
    isCameraOn.value = true;
    isFrontCamera.value = true;
    isScreenSharing.value = false;
    isRecording.value = false;
    isHandRaised.value = false;
    hasRemoteStream.value = false;
    networkQuality.value = 3;
    callDuration.value = Duration.zero;
    chatMessages.clear();
    currentBottomTab.value = 0;
    isPipMode.value = false;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();

    if (Get.isDialogOpen ?? false) Get.back();
    Get.back(); // Navigate back from call screen
  }

  // ═══════════════════════════════════════
  //  MEDIA CONTROLS
  // ═══════════════════════════════════════
  void toggleMic() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      isMicOn.value = audioTrack.enabled;
    }
  }

  void toggleCamera() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
      isCameraOn.value = videoTrack.enabled;
    }
  }

  void toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
      isFrontCamera.value = !isFrontCamera.value;
    }
  }

  // ═══════════════════════════════════════
  //  SCREEN SHARING
  // ═══════════════════════════════════════
  Future<void> toggleScreenSharing() async {
    if (isScreenSharing.value) {
      await _localStream?.dispose();
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      localRenderer.srcObject = _localStream;

      final senders = await _peerConnection?.getSenders();
      if (senders != null) {
        for (final sender in senders) {
          if (sender.track?.kind == 'video') {
            await sender.replaceTrack(_localStream!.getVideoTracks().first);
          }
        }
      }
      isScreenSharing.value = false;
    } else {
      try {
        final screenStream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': true,
        });

        localRenderer.srcObject = screenStream;

        final senders = await _peerConnection?.getSenders();
        if (senders != null) {
          for (final sender in senders) {
            if (sender.track?.kind == 'video') {
              await sender.replaceTrack(screenStream.getVideoTracks().first);
            }
          }
        }

        await _localStream?.dispose();
        _localStream = screenStream;
        isScreenSharing.value = true;
      } catch (e) {
        Get.snackbar('Screen Share', 'Failed to start screen sharing',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  // ═══════════════════════════════════════
  //  CALL RECORDING
  // ═══════════════════════════════════════
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _mediaRecorder?.stop();
      _mediaRecorder = null;
      isRecording.value = false;
      Get.snackbar('Recording', 'Recording saved!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white);
    } else {
      try {
        if (_localStream == null) return;
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        // ignore: unused_local_variable
        final filePath = '${dir.path}/call_recording_$timestamp.mp4';

        _mediaRecorder = MediaRecorder();
        isRecording.value = true;
        Get.snackbar('Recording', 'Recording started...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
      } catch (e) {
        Get.snackbar('Recording', 'Failed to start recording',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  // ═══════════════════════════════════════
  //  SNAPSHOT CAPTURE
  // ═══════════════════════════════════════
  Future<void> captureSnapshot() async {
    try {
      final track = _remoteStream?.getVideoTracks().firstOrNull ??
          _localStream?.getVideoTracks().firstOrNull;
      if (track == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // ignore: unused_local_variable
      final filePath = '${dir.path}/snapshot_$timestamp.png';

      // ignore: unused_local_variable
      final frame = await track.captureFrame();
      Get.snackbar('Snapshot', 'Screenshot captured! 📸',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade600,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Snapshot', 'Failed to capture screenshot',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ═══════════════════════════════════════
  //  HAND RAISE
  // ═══════════════════════════════════════
  void toggleHandRaise() {
    isHandRaised.value = !isHandRaised.value;
    Get.snackbar(
      isHandRaised.value ? '✋ Hand Raised' : '✋ Hand Lowered',
      isHandRaised.value
          ? 'Mentor has been notified'
          : 'You lowered your hand',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ═══════════════════════════════════════
  //  IN-CALL CHAT
  // ═══════════════════════════════════════
  void sendChatMessage() {
    final text = chatTextController.text.trim();
    if (text.isEmpty) return;

    chatMessages.add(ChatMessage(sender: 'You', text: text));
    signaling.sendChatMessage('You', text);
    chatTextController.clear();
  }

  void _onRemoteChatMessage(String sender, String message) {
    // Skip echo of own messages
    if (sender == 'You') return;
    chatMessages.add(ChatMessage(sender: sender, text: message));
  }

  // ═══════════════════════════════════════
  //  NETWORK QUALITY MONITORING
  // ═══════════════════════════════════════
  void _startNetworkMonitoring() {
    _statsTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_peerConnection == null) return;
      try {
        final stats = await _peerConnection!.getStats();
        int packetsLost = 0;
        int packetsReceived = 1;

        for (final report in stats) {
          if (report.type == 'inbound-rtp') {
            packetsLost += (report.values['packetsLost'] as int?) ?? 0;
            packetsReceived += (report.values['packetsReceived'] as int?) ?? 0;
          }
        }

        final lossRate = packetsLost / packetsReceived;
        if (lossRate > 0.1) {
          networkQuality.value = 1;
          _adjustBitrate(lowQuality: true);
        } else if (lossRate > 0.03) {
          networkQuality.value = 2;
          _adjustBitrate(lowQuality: false);
        } else {
          networkQuality.value = 3;
          _adjustBitrate(lowQuality: false);
        }
      } catch (_) {}
    });
  }

  Future<void> _adjustBitrate({required bool lowQuality}) async {
    final senders = await _peerConnection?.getSenders();
    if (senders == null) return;
    for (final sender in senders) {
      if (sender.track?.kind == 'video') {
        final params = sender.parameters;
        if (params.encodings != null && params.encodings!.isNotEmpty) {
          params.encodings![0].maxBitrate =
              lowQuality ? 250000 : 1500000;
          await sender.setParameters(params);
        }
      }
    }
  }

  // ═══════════════════════════════════════
  //  PIP MODE
  // ═══════════════════════════════════════
  void togglePipMode() {
    isPipMode.value = !isPipMode.value;
  }

  // ═══════════════════════════════════════
  //  SIGNALING HANDLERS
  // ═══════════════════════════════════════
  Future<void> _handleRemoteOffer(RTCSessionDescription sdp) async {
    print('📥 Received OFFER');
    if (_peerConnection == null) return;
    _remoteDescriptionSet = false;
    await _peerConnection!.setRemoteDescription(sdp);
    _remoteDescriptionSet = true;

    // Flush buffered candidates
    for (final c in _pendingCandidates) {
      await _peerConnection!.addCandidate(c);
    }
    _pendingCandidates.clear();

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await signaling.sendAnswer(answer);
    print('📤 Answer sent');
  }

  Future<void> _handleRemoteAnswer(RTCSessionDescription sdp) async {
    print('📥 Received ANSWER');
    if (_peerConnection == null) return;
    _remoteDescriptionSet = false;
    await _peerConnection!.setRemoteDescription(sdp);
    _remoteDescriptionSet = true;

    // Flush buffered candidates
    for (final c in _pendingCandidates) {
      await _peerConnection!.addCandidate(c);
    }
    _pendingCandidates.clear();
  }

  Future<void> _handleRemoteCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null || !_remoteDescriptionSet) {
      _pendingCandidates.add(candidate);
      return;
    }
    await _peerConnection!.addCandidate(candidate);
  }

  Future<void> _resetFailedCallStart() async {
    _callTimer?.cancel();
    _statsTimer?.cancel();
    await _localStream?.dispose();
    _localStream = null;
    await _peerConnection?.close();
    _peerConnection = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    hasRemoteStream.value = false;
    isInCall.value = false;
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Bad state: ', '');
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════
  String get formattedCallDuration {
    final d = callDuration.value;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
