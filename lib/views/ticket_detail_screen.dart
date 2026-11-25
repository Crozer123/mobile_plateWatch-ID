import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/bounding_box.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/kawaii_decorations.dart';
import '../widgets/result_cards.dart';
import '../widgets/snapshot_thumb.dart';

class TicketDetailScreen extends StatelessWidget {
  final ParkingSession session;
  const TicketDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final rejected = s.status == SessionStatus.rejected;
    final d = s.duration;
    final match = s.faceMatch;
    final plateDiff = s.mismatchType == 'PLATE_MISMATCH' || s.mismatchType == 'FACE_AND_PLATE_MISMATCH';
    final exitPlateText = (s.detectedPlate != null && s.detectedPlate!.isNotEmpty) ? s.detectedPlate! : s.plate;
    String pct(double? v) => v == null ? '-' : '${((v <= 1 ? v * 100 : v)).toStringAsFixed(1)}%';

    return Scaffold(
      body: KawaiiBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), children: [
            Row(children: [
              SquishyTap(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 2), blurRadius: 0)],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                ),
              ),
              Expanded(
                child: Column(children: [
                  Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                  Text('Detail Pengecekan', style: AppTheme.heading(size: 19, color: AppColors.textDark)),
                ]),
              ),
              const StickerTag('Terekam Rapi'),
            ]),
            const SizedBox(height: 12),
            const Row(children: [
              Expanded(
                child: Pill(
                  'Cek Wajah & Plat Otomatis',
                  bg: AppColors.peach,
                  fg: AppColors.peachInk,
                  borderColor: AppColors.peachShadow,
                  icon: Icons.verified_user_outlined,
                ),
              ),
              SizedBox(width: 8),
              Pill(
                'Arsip Pos 01',
                bg: AppColors.successBg,
                fg: AppColors.success,
                borderColor: AppColors.successBorder,
              ),
            ]),
            const SizedBox(height: 12),

            // Identifikasi
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Identifikasi Sepeda', style: AppTheme.heading(size: 14.5, color: AppColors.textDark)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: PlateBox(s.plate)),
                  const SizedBox(width: 10),
                  rejected
                      ? const Pill('Alarm', bg: AppColors.dangerBg, fg: AppColors.danger, borderColor: AppColors.dangerBorder, icon: Icons.notifications_active_rounded)
                      : const Pill('Cocok ✨', bg: AppColors.successBg, fg: AppColors.success, borderColor: AppColors.successBorder, icon: Icons.check_circle_outline_rounded),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Text('Kode #${s.id}', style: AppTheme.mono(size: 11.5, color: AppColors.textMuted)),
                  const Spacer(),
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text('Pos Pengecekan Utama', style: AppTheme.body(size: 11.5, color: AppColors.textMuted, height: 1.2)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),

            // Biometrik Wajah
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.face_retouching_natural, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Perbandingan Wajah', style: AppTheme.heading(size: 14.5, color: AppColors.textDark))),
                  Pill(
                    s.mismatchType == 'PLATE_MISMATCH'
                        ? 'Wajah Cocok'
                        : rejected
                            ? 'Tidak Cocok'
                            : 'Cocok',
                    bg: (rejected && s.mismatchType != 'PLATE_MISMATCH') ? AppColors.dangerBg : AppColors.successBg,
                    fg: (rejected && s.mismatchType != 'PLATE_MISMATCH') ? AppColors.danger : AppColors.success,
                    borderColor: (rejected && s.mismatchType != 'PLATE_MISMATCH') ? AppColors.dangerBorder : AppColors.successBorder,
                  ),
                ]),
                const SizedBox(height: 12),
                Stack(alignment: Alignment.center, children: [
                  Row(children: [
                    Expanded(
                      child: SnapshotThumb(
                        path: s.entryImage,
                        boxes: s.entryBoxes,
                        imageSize: s.entrySize,
                        height: 130,
                        tag: 'MASUK',
                        caption: s.entryKnown ? 'Masuk ${ParkingStore.hhmm(s.entryTime)}' : 'Foto Masuk',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SnapshotThumb(
                        path: s.exitImage,
                        boxes: s.exitBoxes,
                        imageSize: s.exitSize,
                        height: 130,
                        tag: 'KELUAR',
                        caption: s.exitTime == null ? 'Foto Keluar' : 'Keluar ${ParkingStore.hhmm(s.exitTime!)}',
                      ),
                    ),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: (rejected && s.mismatchType != 'PLATE_MISMATCH') ? AppColors.dangerBorder : AppColors.successBorder,
                        width: 2,
                      ),
                      boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 2), blurRadius: 0)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: (rejected && s.mismatchType != 'PLATE_MISMATCH') ? AppColors.danger : AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        match == null ? '- Cocok' : '${((match <= 1 ? match * 100 : match)).round()}% Cocok',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: (rejected && s.mismatchType != 'PLATE_MISMATCH') ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Text('AI FaceMatch (Segmentasi Fokus Wajah + SFace)',
                    style: AppTheme.body(size: 11.5, color: AppColors.textMuted, height: 1.3)),
              ]),
            ),
            const SizedBox(height: 12),

            // Verifikasi Plat Nomor
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.pin_outlined, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Text('Verifikasi Plat Nomor (ANPR)', style: AppTheme.heading(size: 14.5, color: AppColors.textDark)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _anprCol('Deteksi Masuk', s.plate, pct(s.entryPlateScore), s.entryImage, s.entryBoxes, s.entrySize)),
                  const SizedBox(width: 10),
                  Expanded(child: _anprCol('Deteksi Keluar', exitPlateText, pct(s.exitPlateScore), s.exitImage, s.exitBoxes, s.exitSize)),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: plateDiff ? AppColors.dangerBg : AppColors.successBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: plateDiff ? AppColors.dangerBorder : AppColors.successBorder, width: 1.5),
                  ),
                  child: Row(children: [
                    Icon(
                      plateDiff ? Icons.error_rounded : Icons.check_circle_rounded,
                      size: 18,
                      color: plateDiff ? AppColors.danger : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plateDiff ? 'Plat Nomor Berbeda ($exitPlateText != ${s.plate})' : 'Plat Identik, Cocok!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: plateDiff ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // Detail Waktu Pengecekan (Tanpa Tarif)
            AppCard(
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Detail Waktu Pengecekan', style: AppTheme.heading(size: 14.5, color: AppColors.textDark))),
                  const Pill('Sepeda Motor', bg: AppColors.peach, fg: AppColors.peachInk, borderColor: AppColors.peachShadow),
                ]),
                const SizedBox(height: 12),
                _timeRow(AppColors.primary, 'Waktu Masuk', s.entryKnown ? ParkingStore.dateTime(s.entryTime) : '-'),
                const SizedBox(height: 8),
                _timeRow(AppColors.primaryDark, 'Waktu Keluar', s.exitTime == null ? '-' : ParkingStore.dateTime(s.exitTime!)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.timer_outlined, size: 18, color: AppColors.primaryDark),
                    const SizedBox(width: 8),
                    Text('Durasi di Dalam', style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.2)),
                    const Spacer(),
                    Text(d == null ? '-' : ParkingStore.durationLong(d),
                        style: AppTheme.heading(size: 14, color: AppColors.textDark)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // Kesimpulan
            AppCard(
              color: rejected ? AppColors.dangerBg : AppColors.successBg,
              borderColor: rejected ? AppColors.dangerBorder : AppColors.successBorder,
              shadowColor: rejected ? AppColors.dangerBorder : AppColors.successBorder,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: rejected ? AppColors.danger : AppColors.success,
                  child: Icon(rejected ? Icons.close_rounded : Icons.check_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      rejected ? 'Terdeteksi Tidak Cocok (Alarm)' : 'Yeay! Verifikasi Masuk & Keluar Cocok',
                      style: AppTheme.heading(size: 14.5, color: rejected ? AppColors.danger : AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.note ?? 'Pengendara dan plat nomor sesuai antara catatan masuk dan keluar.',
                      style: AppTheme.body(size: 12, color: rejected ? AppColors.danger : AppColors.success, height: 1.45),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _anprCol(String title, String plate, String acc, String? path, List<BoundingBox> boxes, Size? size) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapshotThumb(path: path, boxes: boxes, imageSize: size, height: 84),
          const SizedBox(height: 8),
          Text(title, style: AppTheme.body(size: 11, color: AppColors.textMuted, height: 1.2)),
          const SizedBox(height: 2),
          Text(plate, style: AppTheme.mono(size: 15, w: FontWeight.w800, color: AppColors.textDark)),
          Text('Akurasi $acc', style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _timeRow(Color dot, String label, String value) => Row(children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.2)),
        const Spacer(),
        Text(value, style: AppTheme.body(size: 12.5, w: FontWeight.w700, color: AppColors.textDark, height: 1.2)),
      ]);
}
