import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A drawing stroke with color and width.
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });
}

/// Whiteboard controller using GetX.
class WhiteboardController extends GetxController {
  final strokes = <DrawingStroke>[].obs;
  final undoneStrokes = <DrawingStroke>[].obs;
  DrawingStroke? _currentStroke;

  final selectedColor = const Color(0xFF4A90D9).obs;
  final strokeSize = 3.0.obs;
  final isEraserMode = false.obs;
  final showColorPicker = false.obs;

  final List<Color> availableColors = [
    const Color(0xFF4A90D9), // Blue
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Green
    const Color(0xFFFBBF24), // Yellow
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFFF6B35), // Orange
    const Color(0xFFEC4899), // Pink
    const Color(0xFFFFFFFF), // White
    const Color(0xFF6B7280), // Gray
    const Color(0xFF000000), // Black
  ];

  void startStroke(Offset point) {
    undoneStrokes.clear();
    _currentStroke = DrawingStroke(
      points: [point],
      color: isEraserMode.value ? Colors.transparent : selectedColor.value,
      strokeWidth: isEraserMode.value ? strokeSize.value * 4 : strokeSize.value,
      isEraser: isEraserMode.value,
    );
    strokes.add(_currentStroke!);
  }

  void addPoint(Offset point) {
    if (_currentStroke != null) {
      _currentStroke!.points.add(point);
      strokes.refresh();
    }
  }

  void endStroke() {
    _currentStroke = null;
  }

  void undo() {
    if (strokes.isNotEmpty) {
      undoneStrokes.add(strokes.removeLast());
    }
  }

  void redo() {
    if (undoneStrokes.isNotEmpty) {
      strokes.add(undoneStrokes.removeLast());
    }
  }

  void clearAll() {
    strokes.clear();
    undoneStrokes.clear();
  }

  void toggleEraser() {
    isEraserMode.value = !isEraserMode.value;
  }

  void selectColor(Color color) {
    selectedColor.value = color;
    isEraserMode.value = false;
    showColorPicker.value = false;
  }
}

/// Virtual Whiteboard widget for in-call drawing.
class WhiteboardWidget extends StatelessWidget {
  const WhiteboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WhiteboardController());

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.draw_rounded, color: Color(0xFF4A90D9), size: 22),
                SizedBox(width: 10),
                Text(
                  'Virtual Whiteboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ── Canvas ─────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onPanStart: (d) => ctrl.startStroke(d.localPosition),
                  onPanUpdate: (d) => ctrl.addPoint(d.localPosition),
                  onPanEnd: (_) => ctrl.endStroke(),
                  child: Obx(() => CustomPaint(
                        painter: _WhiteboardPainter(
                          strokes: ctrl.strokes.toList(),
                        ),
                        size: Size.infinite,
                      )),
                ),
              ),
            ),
          ),

          // ── Toolbar ─────────────────
          _WhiteboardToolbar(ctrl: ctrl),
        ],
      ),
    );
  }
}

/// Toolbar for whiteboard drawing tools.
class _WhiteboardToolbar extends StatelessWidget {
  final WhiteboardController ctrl;

  const _WhiteboardToolbar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        children: [
          // ── Color Picker (expandable) ──
          Obx(() => ctrl.showColorPicker.value
              ? Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ctrl.availableColors.map((color) {
                      final isSelected = ctrl.selectedColor.value == color;
                      return GestureDetector(
                        onTap: () => ctrl.selectColor(color),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink()),

          // ── Brush size slider ──
          Obx(() => Row(
                children: [
                  const Icon(Icons.circle, color: Colors.white24, size: 10),
                  Expanded(
                    child: Slider(
                      value: ctrl.strokeSize.value,
                      min: 1,
                      max: 20,
                      activeColor: ctrl.selectedColor.value,
                      inactiveColor: Colors.white.withValues(alpha: 0.1),
                      onChanged: (v) => ctrl.strokeSize.value = v,
                    ),
                  ),
                  const Icon(Icons.circle, color: Colors.white24, size: 20),
                ],
              )),

          // ── Tool Buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(
                icon: Icons.palette_rounded,
                label: 'Color',
                isActive: false,
                activeColor: const Color(0xFF4A90D9),
                onTap: () =>
                    ctrl.showColorPicker.value = !ctrl.showColorPicker.value,
              ),
              Obx(() => _ToolButton(
                    icon: ctrl.isEraserMode.value
                        ? Icons.edit_rounded
                        : Icons.auto_fix_high_rounded,
                    label: ctrl.isEraserMode.value ? 'Draw' : 'Eraser',
                    isActive: ctrl.isEraserMode.value,
                    activeColor: const Color(0xFFFBBF24),
                    onTap: ctrl.toggleEraser,
                  )),
              _ToolButton(
                icon: Icons.undo_rounded,
                label: 'Undo',
                isActive: false,
                activeColor: const Color(0xFF8B5CF6),
                onTap: ctrl.undo,
              ),
              _ToolButton(
                icon: Icons.redo_rounded,
                label: 'Redo',
                isActive: false,
                activeColor: const Color(0xFF8B5CF6),
                onTap: ctrl.redo,
              ),
              _ToolButton(
                icon: Icons.delete_outline_rounded,
                label: 'Clear',
                isActive: false,
                activeColor: const Color(0xFFEF4444),
                onTap: ctrl.clearAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual tool button.
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: activeColor, width: 1.5)
                  : null,
            ),
            child: Icon(icon,
                color: isActive ? activeColor : Colors.white70, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isActive ? activeColor : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Custom painter for whiteboard strokes.
class _WhiteboardPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  _WhiteboardPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke;

      if (stroke.isEraser) {
        paint.blendMode = ui.BlendMode.clear;
      } else {
        paint.color = stroke.color;
      }

      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

      for (int i = 1; i < stroke.points.length; i++) {
        final p0 = stroke.points[i - 1];
        final p1 = stroke.points[i];
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) => true;
}
