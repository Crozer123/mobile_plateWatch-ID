import 'package:flutter/material.dart';
import '../core/scan_status.dart';
import '../models/parking_record.dart';
import '../widgets/result_scaffold.dart';
import '../widgets/scan_images_row.dart';
import '../widgets/staff_confirmation_sheet.dart';

/// Halaman konfirmasi petugas jika diperlukan pengecekan manual.
class StaffConfirmScreen extends StatelessWidget {
  final ParkingRecord record;
  final String imagePath;
  final bool isEntry;
  final int maxAttempt;
  const StaffConfirmScreen({
    super.key,
    required this.record,
    required this.imagePath,
    required this.isEntry,
    required this.maxAttempt,
  });

  @override
  Widget build(BuildContext context) {
    return ResultScaffold(
      isEntry: isEntry,
      children: [
        ScanImagesRow(
          path: imagePath,
          boxes: record.boxes,
          faceText: '$maxAttempt\u00d7 Belum Terbaca',
          faceOk: false,
          faceFailedMark: true,
          plateText: record.hasPlate ? 'Plat Terbaca' : 'Plat Belum Terbaca',
          plateOk: record.hasPlate,
        ),
        const SizedBox(height: 14),
        StaffConfirmationSheet(
          plate: record.hasPlate ? record.plateNumber : 'sepeda ini',
          failed: maxAttempt,
          maxAttempt: maxAttempt,
          isEntry: isEntry,
          onOpen: () => Navigator.pop(context, true),
          onKeep: () => Navigator.pop(context, false),
        ),
      ],
    );
  }
}
