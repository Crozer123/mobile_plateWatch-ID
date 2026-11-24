import 'dart:io';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/bounding_box.dart';
import 'bbox_pointer.dart';

/// Thumbnail foto hasil scan (dengan bounding box + label waktu).
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
        color: const Color(0xFF16303F),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        if (has)
          Image.file(File(p), fit: BoxFit.cover)
        else
          const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 30)),
        if (has) BBoxPointer(boxes: boxes, imageSize: imageSize),
        if (tag != null)
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: Text(tag!, style: AppTheme.mono(size: 8, color: Colors.white)),
            ),
          ),
        if (caption != null)
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.92), borderRadius: BorderRadius.circular(8)),
              child: Text(caption!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ),
          ),
      ]),
    );
  }
}
