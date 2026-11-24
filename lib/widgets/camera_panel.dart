import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';

/// Kotak kamera/foto dengan label, sudut bracket, dan status di bawahnya.
class CameraPanel extends StatelessWidget {
  final String camLabel;
  final String caption;
  final IconData icon;
  final String statusText;
  final bool ok;
  final Widget? preview;
  final Widget? overlay;
  const CameraPanel({
    super.key,
    required this.camLabel,
    required this.caption,
    required this.icon,
    required this.statusText,
    this.ok = true,
    this.preview,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.warning;
    return Column(children: [
      AspectRatio(
        aspectRatio: 1.05,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            preview ??
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E3A4C), Color(0xFF0B1C27)]),
                  ),
                  child: Icon(icon, size: 48, color: Colors.white24),
                ),
            if (overlay != null) overlay!,
            CustomPaint(painter: BracketPainter(color: ok ? Colors.white70 : AppColors.warning)),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: Text(camLabel, style: AppTheme.mono(size: 9, color: Colors.white)),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.92), borderRadius: BorderRadius.circular(10)),
                  child: Text(caption, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(statusText,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
        ]),
      ),
    ]);
  }
}

/// Preview kamera yang memenuhi kotak (cover).
class CameraView extends StatelessWidget {
  final CameraController? controller;
  final String? error;
  const CameraView({super.key, required this.controller, this.error});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    Widget child;
    if (error != null) {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ),
      );
    } else if (c == null || !c.value.isInitialized) {
      child = const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54));
    } else {
      final size = c.value.previewSize!;
      child = ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: size.height, height: size.width, child: CameraPreview(c)),
        ),
      );
    }
    return Container(color: const Color(0xFF0B1C27), child: child);
  }
}

class BracketPainter extends CustomPainter {
  final Color color;
  final double inset;
  final double len;
  BracketPainter({required this.color, this.inset = 22, this.len = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final m = inset, l = len;
    final r = Rect.fromLTRB(m, m + 8, size.width - m, size.height - m - 8);
    final corners = [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ];
    for (final c in corners) {
      canvas.drawLine(c.$1, c.$1 + Offset(l * c.$2, 0), p);
      canvas.drawLine(c.$1, c.$1 + Offset(0, l * c.$3), p);
    }
  }

  @override
  bool shouldRepaint(covariant BracketPainter old) => old.color != color || old.inset != inset || old.len != len;
}
