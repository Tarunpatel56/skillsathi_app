import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Callback types for signaling events.
typedef OnOfferCallback = void Function(RTCSessionDescription sdp);
typedef OnAnswerCallback = void Function(RTCSessionDescription sdp);
typedef OnCandidateCallback = void Function(RTCIceCandidate candidate);
typedef OnRemoteHangUpCallback = void Function();
typedef OnChatMessageCallback = void Function(String sender, String message);
typedef OnParticipantCallback = void Function(Map<String, dynamic> participant);
typedef OnMuteCallback = void Function(String targetUserId);
typedef OnHandRaiseCallback = void Function(String userId, bool raised);
typedef OnNotesSharedCallback = void Function(String fileName, String fileUrl);
typedef OnClassEndedCallback = void Function();

/// Firebase Realtime Database–based signaling service for WebRTC.
///
/// Room structure in Firebase:
/// ```
/// rooms/
///   {roomId}/
///     offer/          → SDP offer  { sdp, sdpType, from }
///     answer/         → SDP answer { sdp, sdpType, from }
///     candidates/
///       {pushId}/     → ICE candidate { candidate, sdpMid, sdpMLineIndex, from }
///     participants/
///       {userId}/     → { userName, role, joinedAt }
///     chat/
///       {pushId}/     → { sender, message, timestamp }
///     events/
///       {pushId}/     → { type, ... }
/// ```
class FirebaseSignalingService {
  DatabaseReference? _roomRef;
  String _roomId = '';
  String _userId = '';

  // ── Subscriptions ─────────────────────
  final List<StreamSubscription> _subscriptions = [];

  // ── WebRTC Callbacks ──────────────────
  OnOfferCallback? onOffer;
  OnAnswerCallback? onAnswer;
  OnCandidateCallback? onCandidate;
  OnRemoteHangUpCallback? onRemoteHangUp;
  OnChatMessageCallback? onChatMessage;

  // ── Classroom Callbacks ───────────────
  OnParticipantCallback? onParticipantJoined;
  OnParticipantCallback? onParticipantLeft;
  OnMuteCallback? onMuteStudent;
  OnMuteCallback? onMuteAll;
  OnHandRaiseCallback? onHandRaise;
  OnNotesSharedCallback? onNotesShared;
  OnClassEndedCallback? onClassEnded;

  bool get isConnected => _roomRef != null;

  // ═══════════════════════════════════════
  //  JOIN ROOM
  // ═══════════════════════════════════════
  Future<void> joinRoom(
    String roomId,
    String userId, {
    String? userName,
    String? role,
  }) async {
    _roomId = roomId;
    _userId = userId;
    _roomRef = _databaseRoot().child('rooms').child(roomId);

    print('🔌 [Firebase] Joining room: $roomId as ${role ?? "student"}');

    // Register self in participants
    await _roomRef!.child('participants').child(userId).set({
      'userName': userName ?? 'User',
      'role': role ?? 'student',
      'joinedAt': ServerValue.timestamp,
    });

    // Auto-remove on disconnect
    _roomRef!.child('participants').child(userId).onDisconnect().remove();

    // Start listening for signaling messages
    _listenForOffer();
    _listenForAnswer();
    _listenForCandidates();
    _listenForParticipants();
    _listenForChat();
    _listenForEvents();

    print('✅ [Firebase] Joined room $roomId');
  }

  // ═══════════════════════════════════════
  //  SEND: Offer / Answer / Candidate
  // ═══════════════════════════════════════

  Future<void> sendOffer(RTCSessionDescription sdp) async {
    if (_roomRef == null) return;
    await _roomRef!.child('offer').set({
      'sdp': sdp.sdp,
      'sdpType': sdp.type,
      'from': _userId,
    });
    print('📤 [Firebase] Offer sent');
  }

  Future<void> sendAnswer(RTCSessionDescription sdp) async {
    if (_roomRef == null) return;
    await _roomRef!.child('answer').set({
      'sdp': sdp.sdp,
      'sdpType': sdp.type,
      'from': _userId,
    });
    print('📤 [Firebase] Answer sent');
  }

  Future<void> sendCandidate(RTCIceCandidate candidate) async {
    if (_roomRef == null) return;
    await _roomRef!.child('candidates').push().set({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
      'from': _userId,
    });
  }

  Future<void> sendHangUp() async {
    if (_roomRef == null) return;
    await _roomRef!.child('events').push().set({
      'type': 'hangup',
      'from': _userId,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ═══════════════════════════════════════
  //  SEND: Chat
  // ═══════════════════════════════════════
  Future<void> sendChatMessage(String sender, String message) async {
    if (_roomRef == null) return;
    await _roomRef!.child('chat').push().set({
      'sender': sender,
      'message': message,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ═══════════════════════════════════════
  //  SEND: Classroom Events
  // ═══════════════════════════════════════
  Future<void> sendMuteStudent(String targetUserId) async {
    if (_roomRef == null) return;
    await _roomRef!.child('events').push().set({
      'type': 'mute_student',
      'targetUserId': targetUserId,
      'from': _userId,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> sendMuteAll() async {
    if (_roomRef == null) return;
    await _roomRef!.child('events').push().set({
      'type': 'mute_all',
      'from': _userId,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> sendHandRaise(String userId, bool raised) async {
    if (_roomRef == null) return;
    await _roomRef!.child('events').push().set({
      'type': 'hand_raise',
      'userId': userId,
      'raised': raised,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> sendNotesShared(String fileName, String fileUrl) async {
    if (_roomRef == null) return;
    await _roomRef!.child('events').push().set({
      'type': 'notes_shared',
      'fileName': fileName,
      'fileUrl': fileUrl,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> sendClassEnded() async {
    if (_roomRef == null) return;
    await _roomRef!.child('events').push().set({
      'type': 'class_ended',
      'from': _userId,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ═══════════════════════════════════════
  //  LISTENERS
  // ═══════════════════════════════════════

  void _listenForOffer() {
    final sub = _roomRef!.child('offer').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      // Don't process our own offer
      if (map['from'] == _userId) return;
      print('📥 [Firebase] Offer received');
      onOffer?.call(RTCSessionDescription(map['sdp'], map['sdpType']));
    });
    _subscriptions.add(sub);
  }

  void _listenForAnswer() {
    final sub = _roomRef!.child('answer').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      // Don't process our own answer
      if (map['from'] == _userId) return;
      print('📥 [Firebase] Answer received');
      onAnswer?.call(RTCSessionDescription(map['sdp'], map['sdpType']));
    });
    _subscriptions.add(sub);
  }

  void _listenForCandidates() {
    final sub = _roomRef!.child('candidates').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      // Don't process our own candidates
      if (map['from'] == _userId) return;
      onCandidate?.call(RTCIceCandidate(
        map['candidate'],
        map['sdpMid'],
        map['sdpMLineIndex'],
      ));
    });
    _subscriptions.add(sub);
  }

  void _listenForParticipants() {
    // Participant joined
    final joinSub =
        _roomRef!.child('participants').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      map['userId'] = event.snapshot.key;
      print(
          '📥 [Firebase] Participant joined: ${map['userName']} (${map['role']})');
      onParticipantJoined?.call(map);
    });
    _subscriptions.add(joinSub);

    // Participant left
    final leaveSub =
        _roomRef!.child('participants').onChildRemoved.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      map['userId'] = event.snapshot.key;
      print('📥 [Firebase] Participant left: ${map['userName']}');
      onParticipantLeft?.call(map);
    });
    _subscriptions.add(leaveSub);
  }

  void _listenForChat() {
    final sub = _roomRef!.child('chat').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      // The sender name check prevents echo — we already add our own messages locally
      onChatMessage?.call(map['sender'] ?? '', map['message'] ?? '');
    });
    _subscriptions.add(sub);
  }

  void _listenForEvents() {
    final sub = _roomRef!.child('events').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final map = Map<String, dynamic>.from(data as Map);
      // Don't process our own events
      if (map['from'] == _userId) return;

      switch (map['type']) {
        case 'hangup':
          print('📥 [Firebase] Remote hangup');
          onRemoteHangUp?.call();
          break;
        case 'mute_student':
          onMuteStudent?.call(map['targetUserId'] ?? '');
          break;
        case 'mute_all':
          onMuteAll?.call('');
          break;
        case 'hand_raise':
          onHandRaise?.call(map['userId'] ?? '', map['raised'] ?? false);
          break;
        case 'notes_shared':
          onNotesShared?.call(map['fileName'] ?? '', map['fileUrl'] ?? '');
          break;
        case 'class_ended':
          onClassEnded?.call();
          break;
      }
    });
    _subscriptions.add(sub);
  }

  // ═══════════════════════════════════════
  //  LEAVE ROOM / CLEANUP
  // ═══════════════════════════════════════
  Future<void> leaveRoom() async {
    if (_roomRef == null) return;

    // Remove self from participants
    await _roomRef!.child('participants').child(_userId).remove();

    print('📤 [Firebase] Left room $_roomId');
  }

  Future<void> disconnect() async {
    // Cancel all listeners
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    await leaveRoom();
    _roomRef = null;
    _roomId = '';
    _userId = '';
    print('🔴 [Firebase] Disconnected');
  }

  /// Clean up the entire room data (call when teacher ends class).
  Future<void> deleteRoom() async {
    if (_roomRef == null) return;
    await _roomRef!.remove();
    print('🗑️ [Firebase] Room $_roomId deleted');
  }

  DatabaseReference _databaseRoot() {
    try {
      return FirebaseDatabase.instance.ref();
    } catch (error) {
      throw StateError(
        'Firebase Realtime Database is not configured for this platform. '
        'Run the Android/iOS build or add desktop Firebase config before using live class features.',
      );
    }
  }
}
