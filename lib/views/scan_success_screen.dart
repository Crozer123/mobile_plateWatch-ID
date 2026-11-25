import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/scan_status.dart';
import '../models/parking_record.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/result_cards.dart';
import '../widgets/result_scaffold.dart';
import '../widgets/scan_images_row.dart';
import '../widgets/scanner_status_banner.dart';
import '../widgets/snapshot_thumb.dart';

/// Halaman hasil auto-capture ketika motor masuk atau keluar cocok.
class ScanSuccessScreen extends StatelessWidget {
  final ParkingRecord record;
  final ParkingSession? session;
  final String imagePath;
  final Size? imageSize;
  final bool isEntry;
  const ScanSuccessScreen({
    super.key,
    required this.record,
    required this.session,
    required this.imagePath,
    required this.imageSize,
    required this.isEntry,
  });

  @override
  Widget build(BuildContext context) {
    final r = record;
    final s = session;
    final entry = isEntry;
    final f = r.faceScore;
    final pct = f == null ? null : (f * 100).round();
    final faceText = entry
        ? (pct == null ? 'Wajah Terlihat' : 'Wajah Terlihat ($pct%)')
        : (pct == null ? 'Wajah Cocok' : 'Wajah Cocok ($pct%)');
    final d = s?.duration;

    return ResultScaffold(
      isEntry: entry,
      children: [
        ScanImagesRow(
          path: imagePath,
          boxes: r.boxes,
          faceText: faceText,
          faceOk: true,
          plateText: entry ? 'Plat Terbaca' : 'Plat Cocok',
          plateOk: true,
        ),
        const SizedBox(height: 12),
        if (entry)
          EntryResultCard(plate: r.plateNumber, entryTime: ParkingStore.hm(r.time))
        else ...[
          ExitResultCard(
            plate: r.plateNumber,
            entryTime: (s != null && s.entryKnown) ? ParkingStore.hm(s.entryTime) : '-',
            exitTime: ParkingStore.hm(r.time),
            duration: d == null ? '-' : ParkingStore.durationText(d),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Verifikasi: Wajah & Plat Cocok', style: AppTheme.body(size: 11.5, color: AppColors.textMuted, height: 1.2)),
              Text('Kode #${s?.id ?? '-'}', style: AppTheme.mono(size: 11, color: AppColors.textMuted)),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Foto Auto-Capture', style: AppTheme.heading(size: 14, color: AppColors.textDark)),
            const SizedBox(height: 10),
            SnapshotThumb(path: imagePath, boxes: r.boxes, imageSize: imageSize, height: 200, tag: 'CAM-01'),
          ]),
        ),
        const SizedBox(height: 12),
        ScannerStatusBanner(phase: ScanPhase.success, isEntry: entry, attempt: 1, maxAttempt: 3, message: '', serverError: false),
        const SizedBox(height: 16),
        SquishyButton(
          label: 'Lanjut Jaga Berikutnya ✨',
          icon: Icons.camera_alt_rounded,
          variant: SquishyVariant.primary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
