import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/video_call_controller.dart';

/// Network quality signal bars overlay widget.
class NetworkQualityIndicator extends StatelessWidget {
  const NetworkQualityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VideoCallController>();

    return Obx(() {
      final quality = ctrl.networkQuality.value;
      final color = quality >= 3
          ? const Color(0xFF10B981)
          : quality == 2
              ? const Color(0xFFFBBF24)
              : const Color(0xFFEF4444);
      final label = quality >= 3
          ? 'Good'
          : quality == 2
              ? 'Fair'
              : 'Poor';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Signal bars
            ...List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 4,
                height: 8.0 + (i * 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < quality ? color : Colors.white24,
                ),
              );
            }),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Show warning for poor connection
            if (quality <= 1) ...[
              const SizedBox(width: 4),
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444), size: 14),
            ],
          ],
        ),
      );
    });
  }
}

/// Poor connection banner.
class PoorConnectionBanner extends StatelessWidget {
  const PoorConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VideoCallController>();

    return Obx(() {
      if (ctrl.networkQuality.value > 1) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: const Color(0xFFEF4444).withValues(alpha: 0.9),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Poor Connection – Video quality reduced',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
