import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/bounding_box.dart';

/// Menggambar bounding box hasil deteksi di atas foto.
/// Koordinat boleh piksel (butuh [imageSize]) atau ternormalisasi 0..1.
/// Foto diasumsikan ditampilkan dengan BoxFit.cover.
class BBoxPointer extends StatelessWidget {
  final List<BoundingBox> boxes;
  final Size? imageSize;
  const BBoxPointer({super.key, required this.boxes, this.imageSize});

  @override
  Widget build(BuildContext context) {
    if (boxes.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(child: CustomPaint(size: Size.infinite, painter: _BoxPainter(boxes, imageSize)));
  }
}

class _BoxPainter extends CustomPainter {
  final List<BoundingBox> boxes;
  final Size? img;
  _BoxPainter(this.boxes, this.img);

  Color _color(String label) {
    final l = label.toLowerCase();
    if (l.contains('face') || l.contains('wajah')) return AppColors.pink;
    if (l.contains('plate') || l.contains('plat')) return const Color(0xFF4FC3F7);
    return AppColors.warning;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in boxes) {
      var x1 = b.x1, y1 = b.y1, x2 = b.x2, y2 = b.y2;
      final normalized = x2 <= 1.0 && y2 <= 1.0;
      Rect r;
      if (img != null) {
        if (normalized) {
          x1 *= img!.width;
          x2 *= img!.width;
          y1 *= img!.height;
          y2 *= img!.height;
        }
        final scale = math.max(size.width / img!.width, size.height / img!.height);
        final dx = (size.width - img!.width * scale) / 2;
        final dy = (size.height - img!.height * scale) / 2;
        r = Rect.fromLTRB(x1 * scale + dx, y1 * scale + dy, x2 * scale + dx, y2 * scale + dy);
      } else if (normalized) {
        r = Rect.fromLTRB(x1 * size.width, y1 * size.height, x2 * size.width, y2 * size.height);
      } else {
        continue; // piksel tanpa ukuran gambar -> tidak bisa dipetakan
      }

      final color = _color(b.label);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      final conf = b.confidence <= 1 ? b.confidence * 100 : b.confidence;
      final tp = TextPainter(
        text: TextSpan(
          text: '${b.label} ${conf.round()}%',
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelRect = Rect.fromLTWH(r.left, math.max(0, r.top - tp.height - 4), tp.width + 8, tp.height + 4);
      canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(4)), Paint()..color = color);
      tp.paint(canvas, labelRect.topLeft + const Offset(4, 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxPainter old) => old.boxes != boxes || old.img != img;
}
