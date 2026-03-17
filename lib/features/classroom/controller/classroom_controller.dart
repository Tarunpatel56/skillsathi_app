import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../video_call/services/firebase_signaling_service.dart';
import '../../video_call/controller/video_call_controller.dart';

/// Model for a classroom participant.
class Participant {
  final String userId;
  final String name;
  final String role; // 'teacher' or 'student'
  final bool isMuted;
  final bool isCameraOn;
  final bool isHandRaised;

  Participant({
    required this.userId,
    required this.name,
    required this.role,
    this.isMuted = false,
    this.isCameraOn = true,
    this.isHandRaised = false,
  });

  Participant copyWith({
    bool? isMuted,
    bool? isCameraOn,
    bool? isHandRaised,
  }) {
    return Participant(
      userId: userId,
      name: name,
      role: role,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isHandRaised: isHandRaised ?? this.isHandRaised,
    );
  }
}

/// Model for a shared note.
class SharedNote {
  final String fileName;
  final String fileUrl;
  final DateTime sharedAt;

  SharedNote({
    required this.fileName,
    required this.fileUrl,
    DateTime? sharedAt,
  }) : sharedAt = sharedAt ?? DateTime.now();
}

/// Central controller for the Online Classroom feature.
/// Now uses Firebase Realtime Database for signaling (no custom server needed).
class ClassroomController extends GetxController {
  // ── Role & State ──────────────────────
  final isTeacher = false.obs;
  final isClassActive = false.obs;
  final roomCode = ''.obs;
  final teacherName = 'Teacher'.obs;
  final studentName = 'Student'.obs;

  // ── Participants ─────────────────────
  final participants = <Participant>[].obs;

  // ── Notes ────────────────────────────
  final sharedNotes = <SharedNote>[].obs;

  // ── Chat ─────────────────────────────
  final chatMessages = <ChatMessage>[].obs;
  final chatTextController = TextEditingController();

  // ── UI State ─────────────────────────
  final currentTab = 0.obs; // 0=Video, 1=Chat, 2=Participants, 3=Notes
  final isHandRaised = false.obs;

  // ── WebRTC ───────────────────────────
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  // ── Firebase Signaling ───────────────
  final FirebaseSignalingService signaling = FirebaseSignalingService();

  final isMicOn = true.obs;
  final isCameraOn = true.obs;
  final isFrontCamera = true.obs;
  final isSpeakerOn = true.obs;
  final isScreenSharing = false.obs;
  final networkQuality = 3.obs;
  final hasRemoteStream = false.obs;
  final debugStatus = 'Initializing...'.obs;

  // ── Call Timer ────────────────────────
  final classDuration = Duration.zero.obs;
  Timer? _classTimer;
  Timer? _statsTimer;

  final String _userId = const Uuid().v4();

  // ── ICE Candidate Buffering ──────────
  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _pendingCandidates = [];

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
    _classTimer?.cancel();
    _statsTimer?.cancel();
    chatTextController.dispose();
    await _localStream?.dispose();
    await _peerConnection?.close();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    await signaling.disconnect();
  }

  Future<void> _sendOffer() async {
    if (_peerConnection == null) {
      debugStatus.value = '❌ Cannot send offer - no peer connection';
      return;
    }
    try {
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await _peerConnection!.setLocalDescription(offer);
      await signaling.sendOffer(offer);
      debugStatus.value = '📤 Offer sent! Waiting for answer...';
      print('📤 Offer sent for classroom negotiation');
    } catch (e) {
      debugStatus.value = '❌ Offer failed: $e';
      print('❌ _sendOffer error: $e');
    }
  }

  // ═══════════════════════════════════════
  //  ROOM CODE GENERATION
  // ═══════════════════════════════════════
  String _generateRoomCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
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
  //  TEACHER: CREATE CLASSROOM
  // ═══════════════════════════════════════
  Future<void> createClassroom({String? name}) async {
    final granted = await requestPermissions();
    if (!granted) {
      Get.snackbar('Permission Denied', 'Camera & Mic permission required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
      return;
    }

    isTeacher.value = true;
    roomCode.value = _generateRoomCode();
    if (name != null && name.isNotEmpty) teacherName.value = name;
    isClassActive.value = true;

    // Get local media + create peer connection FIRST
    await _startLocalMedia();

    // Then set up Firebase signaling
    try {
      await _setupSignaling();
    } catch (error) {
      await _resetFailedClassroomStart();
      Get.snackbar(
        'Classroom Unavailable',
        _friendlyError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Start class timer
    _classTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      classDuration.value += const Duration(seconds: 1);
    });

    _startNetworkMonitoring();
    print('🎓 [TEACHER] Classroom created. Room: ${roomCode.value}');
  }

  // ═══════════════════════════════════════
  //  STUDENT: JOIN CLASSROOM
  // ═══════════════════════════════════════
  Future<bool> joinClassroom({
    required String code,
    String? name,
  }) async {
    final granted = await requestPermissions();
    if (!granted) {
      Get.snackbar('Permission Denied', 'Camera & Mic permission required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
      return false;
    }

    isTeacher.value = false;
    roomCode.value = code;
    if (name != null && name.isNotEmpty) studentName.value = name;
    isClassActive.value = true;

    // Get local media + create peer connection FIRST
    await _startLocalMedia();

    // Then set up Firebase signaling
    try {
      await _setupSignaling();
    } catch (error) {
      await _resetFailedClassroomStart();
      Get.snackbar(
        'Classroom Unavailable',
        _friendlyError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    // Start class timer
    _classTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      classDuration.value += const Duration(seconds: 1);
    });

    _startNetworkMonitoring();
    print('📖 [STUDENT] Joined classroom. Room: ${roomCode.value}');
    return true;
  }

  // ═══════════════════════════════════════
  //  SIGNALING SETUP (FIREBASE)
  // ═══════════════════════════════════════
  Future<void> _setupSignaling() async {
    // Set up callbacks BEFORE joining
    signaling.onOffer = _handleRemoteOffer;
    signaling.onAnswer = _handleRemoteAnswer;
    signaling.onCandidate = _handleRemoteCandidate;
    signaling.onChatMessage = _onRemoteChatMessage;

    // Classroom events
    signaling.onParticipantJoined = (data) {
      final p = Participant(
        userId: data['userId'] ?? '',
        name: data['userName'] ?? 'Unknown',
        role: data['role'] ?? 'student',
      );
      if (!participants.any((x) => x.userId == p.userId)) {
        participants.add(p);
        // Don't show snackbar for self
        if (p.userId != _userId) {
          Get.snackbar('${p.name} joined! 👋', 'New participant',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2));
        }
      }

      // Teacher sends offer when a new participant joins (not self)
      if (isTeacher.value && p.userId != _userId) {
        debugStatus.value = 'Student joined, preparing offer...';
        Future.delayed(const Duration(milliseconds: 1500), () {
          debugStatus.value = 'Sending offer to student...';
          _sendOffer();
        });
      } else if (!isTeacher.value && p.role == 'teacher') {
        debugStatus.value = 'Teacher found, waiting for offer...';
      }
    };

    signaling.onParticipantLeft = (data) {
      participants.removeWhere((p) => p.userId == data['userId']);
      final hasOthers = participants.any((p) => p.userId != _userId);
      if (!hasOthers) {
        _remoteStream = null;
        remoteRenderer.srcObject = null;
        hasRemoteStream.value = false;
      }
    };

    signaling.onMuteStudent = (targetId) {
      if (targetId == _userId) {
        toggleMic();
        Get.snackbar('Muted', 'Teacher has muted your microphone',
            snackPosition: SnackPosition.BOTTOM);
      }
    };

    signaling.onMuteAll = (_) {
      if (!isTeacher.value) {
        if (isMicOn.value) toggleMic();
        Get.snackbar('Muted', 'Teacher has muted all students',
            snackPosition: SnackPosition.BOTTOM);
      }
    };

    signaling.onHandRaise = (userId, raised) {
      final idx = participants.indexWhere((p) => p.userId == userId);
      if (idx != -1) {
        participants[idx] = participants[idx].copyWith(isHandRaised: raised);
      }
    };

    signaling.onNotesShared = (fileName, fileUrl) {
      sharedNotes.add(SharedNote(fileName: fileName, fileUrl: fileUrl));
      Get.snackbar('📄 Notes Shared', fileName,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
    };

    signaling.onClassEnded = () {
      Get.snackbar('Class Ended', 'The teacher has ended the class',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
      leaveClassroom();
    };

    signaling.onRemoteHangUp = () {
      Get.snackbar('Call Ended', 'Remote participant hung up',
          snackPosition: SnackPosition.BOTTOM);
    };

    // Join room via Firebase
    debugStatus.value = 'Connecting to Firebase...';
    await signaling.joinRoom(
      roomCode.value,
      _userId,
      userName: isTeacher.value ? teacherName.value : studentName.value,
      role: isTeacher.value ? 'teacher' : 'student',
    );
    debugStatus.value = 'Connected! Waiting for participants...';
  }

  // ═══════════════════════════════════════
  //  LOCAL MEDIA + PEER CONNECTION
  // ═══════════════════════════════════════
  Future<void> _startLocalMedia() async {
    // Get local camera and mic
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
    print('📹 Local media started');

    // Enable speaker for remote audio output
    await Helper.setSpeakerphoneOn(true);
    print('🔊 Speaker enabled for remote audio');

    // Create peer connection with STUN + TURN servers
    _peerConnection = await createPeerConnection(_iceServers);
    print('🔗 PeerConnection created');

    // Add all local tracks to peer connection
    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }
    print('🎤 Local tracks added (audio: ${_localStream!.getAudioTracks().length}, video: ${_localStream!.getVideoTracks().length})');

    // ICE candidate handler
    _peerConnection!.onIceCandidate = (candidate) {
      print('🧊 Sending ICE candidate');
      signaling.sendCandidate(candidate);
    };

    // Remote track handler (unified-plan)
    _peerConnection!.onTrack = (event) {
      print('📺 onTrack received: ${event.streams.length} streams, track kind: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
        hasRemoteStream.value = true;
        debugStatus.value = '✅ Remote stream received!';
        print('📺 Remote stream attached! Audio: ${_remoteStream!.getAudioTracks().length}, Video: ${_remoteStream!.getVideoTracks().length}');
      }
    };

    // Fallback: onAddStream for older WebRTC implementations
    _peerConnection!.onAddStream = (MediaStream stream) {
      print('📺 onAddStream received! Audio: ${stream.getAudioTracks().length}, Video: ${stream.getVideoTracks().length}');
      _remoteStream = stream;
      remoteRenderer.srcObject = stream;
      hasRemoteStream.value = true;
    };

    // Connection state monitoring
    _peerConnection!.onIceConnectionState = (state) {
      print('🔌 ICE Connection State: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        networkQuality.value = 3;
        debugStatus.value = '✅ ICE Connected!';
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        networkQuality.value = 0;
        debugStatus.value = '❌ ICE Disconnected/Failed';
        if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _peerConnection?.restartIce();
        }
      }
    };

    _peerConnection!.onConnectionState = (state) {
      print('🔗 Connection State: $state');
    };
  }

  // ═══════════════════════════════════════
  //  TEACHER CONTROLS
  // ═══════════════════════════════════════
  void muteStudent(String userId) {
    signaling.sendMuteStudent(userId);
    final idx = participants.indexWhere((p) => p.userId == userId);
    if (idx != -1) {
      participants[idx] = participants[idx].copyWith(isMuted: true);
    }
  }

  void muteAllStudents() {
    signaling.sendMuteAll();
    for (int i = 0; i < participants.length; i++) {
      if (participants[i].role == 'student') {
        participants[i] = participants[i].copyWith(isMuted: true);
      }
    }
    Get.snackbar('🔇 All Muted', 'All students have been muted',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  void removeStudent(String userId) {
    participants.removeWhere((p) => p.userId == userId);
  }

  void shareNotes(String fileName, String fileUrl) {
    signaling.sendNotesShared(fileName, fileUrl);
    sharedNotes.add(SharedNote(fileName: fileName, fileUrl: fileUrl));
  }

  Future<void> endClass() async {
    await signaling.sendClassEnded();
    // Clean up Firebase room data
    await signaling.deleteRoom();
    await leaveClassroom();
  }

  // ═══════════════════════════════════════
  //  STUDENT CONTROLS
  // ═══════════════════════════════════════
  void toggleHandRaise() {
    isHandRaised.value = !isHandRaised.value;
    signaling.sendHandRaise(_userId, isHandRaised.value);
    Get.snackbar(
      isHandRaised.value ? '✋ Hand Raised' : '✋ Hand Lowered',
      isHandRaised.value ? 'Teacher has been notified' : '',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ═══════════════════════════════════════
  //  MEDIA CONTROLS
  // ═══════════════════════════════════════
  void toggleMic() {
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      isMicOn.value = audioTrack.enabled;
    }
  }

  void toggleCamera() {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
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
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
      isFrontCamera.value = !isFrontCamera.value;
    }
  }

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
  //  CHAT
  // ═══════════════════════════════════════
  void sendChatMessage() {
    final text = chatTextController.text.trim();
    if (text.isEmpty) return;
    final sender = isTeacher.value ? teacherName.value : studentName.value;
    chatMessages.add(ChatMessage(sender: sender, text: text));
    signaling.sendChatMessage(sender, text);
    chatTextController.clear();
  }

  void _onRemoteChatMessage(String sender, String message) {
    // Avoid duplicating our own messages (Firebase echoes back)
    final myName = isTeacher.value ? teacherName.value : studentName.value;
    if (sender == myName) return;
    chatMessages.add(ChatMessage(sender: sender, text: message));
  }

  // ═══════════════════════════════════════
  //  LEAVE CLASSROOM
  // ═══════════════════════════════════════
  Future<void> leaveClassroom() async {
    _classTimer?.cancel();
    _statsTimer?.cancel();

    await signaling.disconnect();

    await _localStream?.dispose();
    _localStream = null;
    await _peerConnection?.close();
    _peerConnection = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    hasRemoteStream.value = false;

    isClassActive.value = false;
    isTeacher.value = false;
    isMicOn.value = true;
    isCameraOn.value = true;
    isFrontCamera.value = true;
    isScreenSharing.value = false;
    isHandRaised.value = false;
    networkQuality.value = 3;
    classDuration.value = Duration.zero;
    roomCode.value = '';
    participants.clear();
    chatMessages.clear();
    sharedNotes.clear();
    currentTab.value = 0;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();

    Get.back();
  }

  // ═══════════════════════════════════════
  //  NETWORK MONITORING
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
            packetsReceived +=
                (report.values['packetsReceived'] as int?) ?? 0;
          }
        }
        final lossRate = packetsLost / packetsReceived;
        if (lossRate > 0.1) {
          networkQuality.value = 1;
        } else if (lossRate > 0.03) {
          networkQuality.value = 2;
        } else {
          networkQuality.value = 3;
        }
      } catch (_) {}
    });
  }

  // ═══════════════════════════════════════
  //  SIGNALING HANDLERS
  // ═══════════════════════════════════════
  Future<void> _handleRemoteOffer(RTCSessionDescription sdp) async {
    print('📥 Received OFFER from remote');
    debugStatus.value = '📥 Offer received, creating answer...';
    if (_peerConnection == null) {
      debugStatus.value = '❌ PeerConnection null!';
      return;
    }
    try {
      _remoteDescriptionSet = false;
      await _peerConnection!.setRemoteDescription(sdp);
      _remoteDescriptionSet = true;

      // Apply any buffered ICE candidates
      for (final c in _pendingCandidates) {
        await _peerConnection!.addCandidate(c);
      }
      print('🧊 Applied ${_pendingCandidates.length} buffered ICE candidates');
      _pendingCandidates.clear();

      // Create and send answer
      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await _peerConnection!.setLocalDescription(answer);
      await signaling.sendAnswer(answer);
      debugStatus.value = '📤 Answer sent, waiting for ICE...';
      print('📤 Answer sent');
    } catch (e) {
      print('❌ _handleRemoteOffer error: $e');
      debugStatus.value = '❌ Offer handling failed: $e';
    }
  }

  Future<void> _handleRemoteAnswer(RTCSessionDescription sdp) async {
    print('📥 Received ANSWER from remote');
    if (_peerConnection == null) return;
    _remoteDescriptionSet = false;
    await _peerConnection!.setRemoteDescription(sdp);
    _remoteDescriptionSet = true;
    debugStatus.value = '📥 Answer received, ICE connecting...';

    // Apply any buffered ICE candidates
    for (final c in _pendingCandidates) {
      await _peerConnection!.addCandidate(c);
    }
    print('🧊 Applied ${_pendingCandidates.length} buffered ICE candidates');
    _pendingCandidates.clear();
  }

  Future<void> _handleRemoteCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null || !_remoteDescriptionSet) {
      _pendingCandidates.add(candidate);
      return;
    }
    await _peerConnection!.addCandidate(candidate);
  }

  Future<void> _resetFailedClassroomStart() async {
    _classTimer?.cancel();
    _statsTimer?.cancel();
    await _localStream?.dispose();
    _localStream = null;
    await _peerConnection?.close();
    _peerConnection = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    hasRemoteStream.value = false;
    isClassActive.value = false;
    roomCode.value = '';
    participants.clear();
    sharedNotes.clear();
    debugStatus.value = 'Live class unavailable';
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Bad state: ', '');
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════
  String get formattedDuration {
    final d = classDuration.value;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  int get studentCount =>
      participants.where((p) => p.role == 'student').length;
  int get handsRaisedCount =>
      participants.where((p) => p.isHandRaised).length;
}
