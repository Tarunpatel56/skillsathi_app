import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Callback types for signaling events.
typedef OnOfferCallback = void Function(RTCSessionDescription sdp);
typedef OnAnswerCallback = void Function(RTCSessionDescription sdp);
typedef OnCandidateCallback = void Function(RTCIceCandidate candidate);
typedef OnRemoteHangUpCallback = void Function();
typedef OnChatMessageCallback = void Function(String sender, String message);
typedef OnWhiteboardDataCallback = void Function(Map<String, dynamic> data);

// Classroom-specific callbacks
typedef OnParticipantCallback = void Function(Map<String, dynamic> participant);
typedef OnMuteCallback = void Function(String targetUserId);
typedef OnHandRaiseCallback = void Function(String userId, bool raised);
typedef OnNotesSharedCallback = void Function(String fileName, String fileUrl);
typedef OnClassEndedCallback = void Function();

/// WebSocket-based signaling service for WebRTC + Classroom events.
/// Buffers messages until the WebSocket is actually connected.
class SignalingService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isReady = false; // true only after first message received or ready event

  // Message buffer for messages sent before connection is ready
  final List<Map<String, dynamic>> _messageBuffer = [];

  // ── WebRTC Callbacks ─────────────────
  OnOfferCallback? onOffer;
  OnAnswerCallback? onAnswer;
  OnCandidateCallback? onCandidate;
  OnRemoteHangUpCallback? onRemoteHangUp;
  OnChatMessageCallback? onChatMessage;
  OnWhiteboardDataCallback? onWhiteboardData;

  // ── Classroom Callbacks ──────────────
  OnParticipantCallback? onParticipantJoined;
  OnParticipantCallback? onParticipantLeft;
  OnMuteCallback? onMuteStudent;
  OnMuteCallback? onMuteAll;
  OnHandRaiseCallback? onHandRaise;
  OnNotesSharedCallback? onNotesShared;
  OnClassEndedCallback? onClassEnded;

  bool get isConnected => _isConnected;

  /// Connect to the signaling server.
  /// Messages sent via _send() will be buffered until connection is ready.
  void connect(String serverUrl) {
    try {
      print('🔌 [Signaling] Connecting to: $serverUrl');
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;
      _isReady = false;

      _channel!.stream.listen(
        (message) {
          // Mark as ready on first received message (connection confirmed)
          if (!_isReady) {
            _isReady = true;
            print('✅ [Signaling] WebSocket ready (first message received)');
          }
          _handleMessage(message);
        },
        onDone: () {
          _isConnected = false;
          _isReady = false;
          print('🔴 [Signaling] Connection closed');
        },
        onError: (error) {
          _isConnected = false;
          _isReady = false;
          print('❌ [Signaling] Error: $error');
        },
      );

      // WebSocketChannel.connect() is async but returns immediately.
      // We mark as ready after a small delay to let the handshake complete,
      // then flush any buffered messages.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isConnected && !_isReady) {
          _isReady = true;
          print('✅ [Signaling] WebSocket ready (timeout-based)');
          _flushBuffer();
        }
      });

      print('📡 [Signaling] Channel created, waiting for ready...');
    } catch (e) {
      _isConnected = false;
      _isReady = false;
      print('❌ [Signaling] Failed to connect: $e');
    }
  }

  /// Disconnect from signaling server.
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _isReady = false;
    _messageBuffer.clear();
  }

  /// Flush buffered messages after connection is ready.
  void _flushBuffer() {
    if (_messageBuffer.isNotEmpty) {
      print('📤 [Signaling] Flushing ${_messageBuffer.length} buffered messages');
      for (final msg in _messageBuffer) {
        _sendDirect(msg);
      }
      _messageBuffer.clear();
    }
  }

  /// Join a room.
  void joinRoom(String roomId, String userId, {String? userName, String? role}) {
    print('🚨 [Signaling] Joining room: $roomId as ${role ?? "student"} (${userName ?? "User"})');
    _send({
      'type': 'join',
      'roomId': roomId,
      'userId': userId,
      'userName': userName ?? 'User',
      'role': role ?? 'student',
    });
  }

  /// Leave a room.
  void leaveRoom(String roomId, String userId) {
    _send({
      'type': 'leave',
      'roomId': roomId,
      'userId': userId,
    });
  }

  /// Send SDP offer.
  void sendOffer(RTCSessionDescription sdp) {
    _send({
      'type': 'offer',
      'sdp': sdp.sdp,
      'sdpType': sdp.type,
    });
  }

  /// Send SDP answer.
  void sendAnswer(RTCSessionDescription sdp) {
    _send({
      'type': 'answer',
      'sdp': sdp.sdp,
      'sdpType': sdp.type,
    });
  }

  /// Send ICE candidate.
  void sendCandidate(RTCIceCandidate candidate) {
    _send({
      'type': 'candidate',
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  /// Send hang up signal.
  void sendHangUp() {
    _send({'type': 'hangup'});
  }

  /// Send chat message.
  void sendChatMessage(String sender, String message) {
    _send({
      'type': 'chat',
      'sender': sender,
      'message': message,
    });
  }

  /// Send whiteboard data.
  void sendWhiteboardData(Map<String, dynamic> data) {
    _send({
      'type': 'whiteboard',
      'data': data,
    });
  }

  // ═══════════════════════════════════════
  //  CLASSROOM EVENTS
  // ═══════════════════════════════════════

  /// Mute a specific student.
  void sendMuteStudent(String targetUserId) {
    _send({
      'type': 'mute_student',
      'targetUserId': targetUserId,
    });
  }

  /// Mute all students.
  void sendMuteAll() {
    _send({'type': 'mute_all'});
  }

  /// Send hand raise status.
  void sendHandRaise(String userId, bool raised) {
    _send({
      'type': 'hand_raise',
      'userId': userId,
      'raised': raised,
    });
  }

  /// Share notes with class.
  void sendNotesShared(String fileName, String fileUrl) {
    _send({
      'type': 'notes_shared',
      'fileName': fileName,
      'fileUrl': fileUrl,
    });
  }

  /// End class for everyone.
  void sendClassEnded() {
    _send({'type': 'class_ended'});
  }

  /// Handle incoming WebSocket messages.
  void _handleMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final msgType = msg['type'];
      print('📨 [Signaling] Received: $msgType');
      switch (msg['type']) {
        case 'offer':
          print('📨 [Signaling] ★ OFFER received!');
          onOffer?.call(RTCSessionDescription(msg['sdp'], msg['sdpType']));
          break;
        case 'answer':
          print('📨 [Signaling] ★ ANSWER received!');
          onAnswer?.call(RTCSessionDescription(msg['sdp'], msg['sdpType']));
          break;
        case 'candidate':
          print('📨 [Signaling] ★ ICE CANDIDATE received!');
          onCandidate?.call(RTCIceCandidate(
            msg['candidate'],
            msg['sdpMid'],
            msg['sdpMLineIndex'],
          ));
          break;
        case 'hangup':
          onRemoteHangUp?.call();
          break;
        case 'chat':
          onChatMessage?.call(msg['sender'] ?? '', msg['message'] ?? '');
          break;
        case 'whiteboard':
          onWhiteboardData?.call(msg['data'] ?? {});
          break;
        // ── Classroom events ──
        case 'participant_joined':
          print('📨 [Signaling] ★ PARTICIPANT JOINED: ${msg['userName']} (${msg['role']})');
          onParticipantJoined?.call(msg);
          break;
        case 'participant_left':
          onParticipantLeft?.call(msg);
          break;
        case 'mute_student':
          onMuteStudent?.call(msg['targetUserId'] ?? '');
          break;
        case 'mute_all':
          onMuteAll?.call('');
          break;
        case 'hand_raise':
          onHandRaise?.call(msg['userId'] ?? '', msg['raised'] ?? false);
          break;
        case 'notes_shared':
          onNotesShared?.call(msg['fileName'] ?? '', msg['fileUrl'] ?? '');
          break;
        case 'class_ended':
          onClassEnded?.call();
          break;
      }
    } catch (e) {
      print('❌ [Signaling] Error handling message: $e');
    }
  }

  /// Send a JSON message. Buffers if not ready yet.
  void _send(Map<String, dynamic> data) {
    if (_isConnected && _isReady && _channel != null) {
      _sendDirect(data);
    } else if (_isConnected) {
      // Buffer the message — connection not ready yet
      print('⏳ [Signaling] Buffering message: ${data['type']} (not ready yet)');
      _messageBuffer.add(data);
    } else {
      print('⚠️ [Signaling] Cannot send (not connected): ${data['type']}');
    }
  }

  /// Directly send without buffering.
  void _sendDirect(Map<String, dynamic> data) {
    try {
      _channel!.sink.add(jsonEncode(data));
      print('📤 [Signaling] Sent: ${data['type']}');
    } catch (e) {
      print('❌ [Signaling] Send error: $e');
    }
  }
}
