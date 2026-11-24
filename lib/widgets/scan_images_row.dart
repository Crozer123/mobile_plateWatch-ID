import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/bounding_box.dart';
import 'box_crop.dart';

/// Dua gambar hasil scan (wajah & plat) dipotong dari 1 foto, + status masing-masing.
class ScanImagesRow extends StatelessWidget {
  final String path;
  final List<BoundingBox> boxes;
  final String faceText;
  final bool faceOk;
  final String plateText;
  final bool plateOk;
  final bool faceFailedMark; // tampilkan tanda X di gambar wajah
  const ScanImagesRow({
    super.key,
    required this.path,
    required this.boxes,
    required this.faceText,
    required this.faceOk,
    required this.plateText,
    required this.plateOk,
    this.faceFailedMark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(children: [
          Stack(children: [
            BoxCrop(path: path, boxes: boxes, labelKeys: const ['face', 'wajah'], caption: 'Wajah Pengendara'),
            if (faceFailedMark)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.9), shape: BoxShape.circle, border: Border.all(color: AppColors.danger, width: 3)),
                    child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 30),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          _status(faceText, faceOk),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(children: [
          BoxCrop(path: path, boxes: boxes, labelKeys: const ['plate', 'plat'], caption: 'Plat Motor', padding: 0.15),
          const SizedBox(height: 8),
          _status(plateText, plateOk),
        ]),
      ),
    ]);
  }

  Widget _status(String text, bool ok) {
    final c = ok ? AppColors.success : AppColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      decoration: BoxDecoration(color: c.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, size: 14, color: c),
        const SizedBox(width: 5),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c))),
      ]),
    );
  }
}
