import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/bounding_box.dart';
import 'box_crop.dart';

/// Dua gambar hasil scan (wajah & plat) dipotong dari 1 foto, dengan status pastel harmonis.
class ScanImagesRow extends StatelessWidget {
  final String path;
  final List<BoundingBox> boxes;
  final String faceText;
  final bool faceOk;
  final String plateText;
  final bool plateOk;
  final bool faceFailedMark;
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
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.danger, width: 3),
                    ),
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
    final fg = ok ? AppColors.success : AppColors.danger;
    final bg = ok ? AppColors.successBg : AppColors.dangerBg;
    final br = ok ? AppColors.successBorder : AppColors.dangerBorder;
    return Container(
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
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg))),
      ]),
    );
  }
}
