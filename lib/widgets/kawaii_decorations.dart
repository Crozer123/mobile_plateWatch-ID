import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';

/// Latar belakang Warm Strawberry Milk dengan pola grid buku tulis + polka dots halus (3.5% opacity).
class KawaiiBackground extends StatelessWidget {
  final Widget child;
  const KawaiiBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: CustomPaint(
        painter: _KawaiiPatternPainter(),
        child: child,
      ),
    );
  }
}

class _KawaiiPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const step = 32.0;
    final gridPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.032)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.045);
    var row = 0;
    for (double y = 16; y < size.height; y += step) {
      final offsetX = (row % 2 == 0) ? 16.0 : 32.0;
      for (double x = offsetX; x < size.width; x += step * 2) {
        canvas.drawCircle(Offset(x, y), 2.0, dotPaint);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _KawaiiPatternPainter oldDelegate) => false;
}

/// Stiker catatan tulisan tangan miring ringan (aksen scrapbook).
class StickerTag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color borderColor;
  final Color textColor;
  final double angle;

  const StickerTag(
    this.text, {
    super.key,
    this.bg = AppColors.butter,
    this.borderColor = AppColors.butterShadow,
    this.textColor = AppColors.butterInk,
    this.angle = -0.04,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [BoxShadow(color: borderColor, offset: const Offset(0, 2), blurRadius: 0)],
        ),
        child: Text(text, style: AppTheme.sticker(size: 13.5, color: textColor)),
      ),
    );
  }
}

/// Ornamen garis membulat bintang 4 sudut (✦).
class KawaiiSparkle extends StatelessWidget {
  final double size;
  final Color color;
  const KawaiiSparkle({super.key, this.size = 18, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SparklePainter(color)),
      );
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.45;
    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx, cy, cx + r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + r)
      ..quadraticBezierTo(cx, cy, cx - r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - r)
      ..close();

    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.color != color;
}

/// Ornamen pita imut bergaris membulat.
class KawaiiBow extends StatelessWidget {
  final double size;
  final Color color;
  const KawaiiBow({super.key, this.size = 24, this.color = AppColors.primaryDark});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 0.72,
        child: CustomPaint(painter: _BowPainter(color)),
      );
}

class _BowPainter extends CustomPainter {
  final Color color;
  _BowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final leftWing = Path()
      ..moveTo(cx - 2, cy)
      ..cubicTo(w * 0.12, h * 0.05, w * 0.04, h * 0.95, cx - 2, cy);
    final rightWing = Path()
      ..moveTo(cx + 2, cy)
      ..cubicTo(w * 0.88, h * 0.05, w * 0.96, h * 0.95, cx + 2, cy);

    final fill = Paint()..color = color.withValues(alpha: 0.22);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(leftWing, fill);
    canvas.drawPath(rightWing, fill);
    canvas.drawPath(leftWing, stroke);
    canvas.drawPath(rightWing, stroke);
    canvas.drawCircle(Offset(cx, cy), w * 0.11, Paint()..color = AppColors.elevated);
    canvas.drawCircle(Offset(cx, cy), w * 0.11, stroke);
  }

  @override
  bool shouldRepaint(covariant _BowPainter oldDelegate) => oldDelegate.color != color;
}

/// Ornamen awan mungil membulat untuk empty state.
class KawaiiCloud extends StatelessWidget {
  final double size;
  final Color color;
  const KawaiiCloud({super.key, this.size = 56, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * 0.65,
        child: CustomPaint(painter: _CloudPainter(color)),
      );
}

class _CloudPainter extends CustomPainter {
  final Color color;
  _CloudPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.24, h * 0.78)
      ..lineTo(w * 0.76, h * 0.78)
      ..cubicTo(w * 0.92, h * 0.78, w * 0.94, h * 0.50, w * 0.78, h * 0.48)
      ..cubicTo(w * 0.78, h * 0.20, w * 0.44, h * 0.14, w * 0.36, h * 0.34)
      ..cubicTo(w * 0.18, h * 0.28, w * 0.08, h * 0.78, w * 0.24, h * 0.78)
      ..close();

    canvas.drawPath(path, Paint()..color = AppColors.card);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Mata imut pada awan
    final eyePaint = Paint()..color = AppColors.textDark;
    canvas.drawCircle(Offset(w * 0.42, h * 0.54), 1.8, eyePaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.54), 1.8, eyePaint);
    // Pipi blush kecil
    final blushPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(w * 0.36, h * 0.60), 2.5, blushPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.60), 2.5, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => oldDelegate.color != color;
}
