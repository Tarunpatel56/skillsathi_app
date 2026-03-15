import 'package:flutter/material.dart';

/// Animated microphone button for voice input.
class VoiceButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const VoiceButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _animController.repeat(reverse: true);
    } else {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: widget.isListening
                ? [const Color(0xFFFF6B35), const Color(0xFFFF3D00)]
                : [const Color(0xFF6C63FF), const Color(0xFF3F3D9E)],
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isListening
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF6C63FF))
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          onPressed: widget.onPressed,
          icon: Icon(
            widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 28,
          ),
          padding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
