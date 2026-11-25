import 'dart:io';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/bounding_box.dart';
import 'bbox_pointer.dart';

/// Thumbnail foto hasil scan (bingkai hangat dengan bounding box + label waktu).
class SnapshotThumb extends StatelessWidget {
  final String? path;
  final List<BoundingBox> boxes;
  final Size? imageSize;
  final String? caption;
  final String? tag;
  final double height;
  final Color? borderColor;
  const SnapshotThumb({
    super.key,
    required this.path,
    this.boxes = const [],
    this.imageSize,
    this.caption,
    this.tag,
    this.height = 120,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = path;
    final has = p != null && File(p).existsSync();
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border, width: 2),
        color: AppColors.cameraBg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        if (has)
          Image.file(File(p), fit: BoxFit.cover)
        else
          Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.border.withValues(alpha: .45), size: 30)),
        if (has) BBoxPointer(boxes: boxes, imageSize: imageSize),
        if (tag != null)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cameraSurface.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(tag!, style: AppTheme.mono(size: 8.5, color: Colors.white)),
            ),
          ),
        if (caption != null)
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: Text(
                caption!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
          ),
      ]),
    );
  }
}
