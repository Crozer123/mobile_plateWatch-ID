import 'package:flutter/material.dart';
import '../core/app_colors.dart';
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

/// Halaman "Masuk Berhasil" / "Keluar Cocok" - muncul setelah scan berhasil.
class ScanSuccessScreen extends StatefulWidget {
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
  State<ScanSuccessScreen> createState() => _ScanSuccessScreenState();
}

class _ScanSuccessScreenState extends State<ScanSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final s = widget.session;
    final entry = widget.isEntry;
    final f = r.faceScore;
    final pct = f == null ? null : (f * 100).round();
    final faceText = entry
        ? (pct == null ? 'Wajah Terbaca' : 'Wajah Terbaca ($pct%)')
        : (pct == null ? 'Wajah Cocok' : 'Skor Wajah: $pct% (Cocok)');
    final d = s?.duration;

    return ResultScaffold(
      isEntry: entry,
      children: [
        ScanImagesRow(
          path: widget.imagePath,
          boxes: r.boxes,
          faceText: faceText,
          faceOk: true,
          plateText: entry ? 'Plat Terdeteksi' : 'Plat Terdaftar',
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
            tariff: d == null ? '-' : ParkingStore.tariffFor(d),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Metode: E-Wallet Auto-Debit', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('Tiket #${s?.id ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ),
        ],
        if (s?.manual == true) ...[
          const SizedBox(height: 10),
          const Pill('Dibuka manual oleh petugas', bg: AppColors.card, fg: AppColors.primaryDark, icon: Icons.admin_panel_settings_outlined),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('FOTO HASIL SCAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            SnapshotThumb(path: widget.imagePath, boxes: r.boxes, imageSize: widget.imageSize, height: 200, tag: 'CAM-01'),
          ]),
        ),
        const SizedBox(height: 12),
        ScannerStatusBanner(phase: ScanPhase.success, isEntry: entry, attempt: 1, maxAttempt: 3, message: '', serverError: false),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Selesai, scan berikutnya'),
          ),
        ),
      ],
    );
  }
}
