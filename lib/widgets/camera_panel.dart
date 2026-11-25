import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';

/// Kotak kamera/foto dengan sudut bracket bulat dan status pastel harmonis.
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
    final fg = ok ? AppColors.success : AppColors.warning;
    final bg = ok ? AppColors.successBg : AppColors.warningBg;
    final br = ok ? AppColors.successBorder : AppColors.warningBorder;
    return Column(children: [
      AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            preview ??
                Container(
                  color: AppColors.cameraBg,
                  child: Icon(icon, size: 48, color: AppColors.border.withValues(alpha: .35)),
                ),
            if (overlay != null) overlay!,
            CustomPaint(painter: BracketPainter(color: ok ? AppColors.elevated : AppColors.peach)),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cameraSurface.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(camLabel, style: AppTheme.mono(size: 9, color: Colors.white)),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(caption, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: br, width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, size: 14, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(statusText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
          ),
        ]),
      ),
    ]);
  }
}

/// Preview kamera yang memenuhi bingkai (backing cokelat hangat).
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
          padding: const EdgeInsets.all(16),
          child: Text(error!, textAlign: TextAlign.center, style: AppTheme.body(size: 12.5, color: AppColors.card)),
        ),
      );
    } else if (c == null || !c.value.isInitialized) {
      child = const Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary));
    } else {
      final size = c.value.previewSize!;
      child = ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: size.height, height: size.width, child: CameraPreview(c)),
        ),
      );
    }
    return Container(color: AppColors.cameraBg, child: child);
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
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
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
