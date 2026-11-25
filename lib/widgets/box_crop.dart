import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/bounding_box.dart';

/// Memotong bagian foto sesuai bounding box (mis. hanya wajah / hanya plat) bergaya stiker polaroid.
class BoxCrop extends StatefulWidget {
  final String path;
  final List<BoundingBox> boxes;
  final List<String> labelKeys;
  final String? caption;
  final double aspectRatio;
  final double padding;
  const BoxCrop({
    super.key,
    required this.path,
    required this.boxes,
    required this.labelKeys,
    this.caption,
    this.aspectRatio = 1,
    this.padding = 0.35,
  });

  @override
  State<BoxCrop> createState() => _BoxCropState();
}

class _BoxCropState extends State<BoxCrop> {
  ui.Image? _img;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final img = await decodeImageFromList(await File(widget.path).readAsBytes());
      if (mounted) setState(() => _img = img);
    } catch (_) {}
  }

  Rect _srcRect(ui.Image img) {
    final iw = img.width.toDouble(), ih = img.height.toDouble();
    BoundingBox? best;
    for (final b in widget.boxes) {
      final l = b.label.toLowerCase();
      if (widget.labelKeys.any(l.contains) && (best == null || b.confidence > best.confidence)) best = b;
    }
    if (best == null) return Rect.fromLTWH(0, 0, iw, ih);
    var x1 = best.x1, y1 = best.y1, x2 = best.x2, y2 = best.y2;
    if (x2 <= 1 && y2 <= 1) {
      x1 *= iw;
      x2 *= iw;
      y1 *= ih;
      y2 *= ih;
    }
    final w = (x2 - x1).abs(), h = (y2 - y1).abs();
    final r = Rect.fromLTRB(x1 - w * widget.padding, y1 - h * widget.padding, x2 + w * widget.padding, y2 + h * widget.padding);
    return r.intersect(Rect.fromLTWH(0, 0, iw, ih));
  }

  @override
  Widget build(BuildContext context) {
    final img = _img;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cameraBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 3), blurRadius: 0)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          if (img != null) CustomPaint(painter: _CropPainter(img, _srcRect(img), widget.aspectRatio)),
          if (widget.caption != null)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(
                    widget.caption!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final ui.Image img;
  final Rect rect;
  final double aspect;
  _CropPainter(this.img, this.rect, this.aspect);

  @override
  void paint(Canvas canvas, Size size) {
    final iw = img.width.toDouble(), ih = img.height.toDouble();
    var w = rect.width, h = rect.height;
    if (w / h > aspect) {
      h = w / aspect;
    } else {
      w = h * aspect;
    }
    if (w > iw) {
      w = iw;
      h = w / aspect;
    }
    if (h > ih) {
      h = ih;
      w = h * aspect;
    }
    final l = (rect.center.dx - w / 2).clamp(0.0, iw - w).toDouble();
    final t = (rect.center.dy - h / 2).clamp(0.0, ih - h).toDouble();
    canvas.drawImageRect(img, Rect.fromLTWH(l, t, w, h), Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(covariant _CropPainter old) => old.img != img || old.rect != rect;
}
