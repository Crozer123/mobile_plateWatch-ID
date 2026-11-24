import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/bounding_box.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
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
    String pct(double? v) => v == null ? '-' : '${((v <= 1 ? v * 100 : v)).toStringAsFixed(1)}%';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 28), children: [
          Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(
              child: Column(children: [
                Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                const Text('Detail Tiket', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
            ),
            const SizedBox(width: 48),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Expanded(child: Pill('Sistem Verifikasi Multi-Faktor Terkunci', bg: AppColors.card, fg: AppColors.primaryDark, icon: Icons.verified_user_outlined)),
            const SizedBox(width: 8),
            const Pill('Terekam Resmi', bg: AppColors.successBg, fg: AppColors.success),
          ]),
          const SizedBox(height: 12),

          // Identifikasi
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('IDENTIFIKASI KENDARAAN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: .4)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: PlateBox(s.plate)),
                const SizedBox(width: 10),
                rejected
                    ? const Pill('Ditolak', bg: Color(0xFFFFE0E0), fg: AppColors.danger, icon: Icons.error_outline_rounded)
                    : const Pill('Selesai', bg: AppColors.card, fg: AppColors.primaryDark, icon: Icons.check_circle_outline_rounded),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Text('# ID Sesi #${s.id}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                const Spacer(),
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 3),
                const Text('Pos Gerbang Utama', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // Biometrik
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.face_retouching_natural, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('Perbandingan Biometrik Wajah', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                Pill(rejected ? 'Tidak Cocok' : 'High Match',
                    bg: rejected ? const Color(0xFFFFE0E0) : AppColors.card, fg: rejected ? AppColors.danger : AppColors.primaryDark),
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
                      tag: 'CAM-IN-01',
                      caption: s.entryKnown ? 'Snapshot Masuk ${ParkingStore.hhmm(s.entryTime)}' : 'Snapshot Masuk',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SnapshotThumb(
                      path: s.exitImage,
                      boxes: s.exitBoxes,
                      imageSize: s.exitSize,
                      height: 130,
                      tag: 'CAM-OUT-02',
                      caption: s.exitTime == null ? 'Snapshot Keluar' : 'Snapshot Keluar ${ParkingStore.hhmm(s.exitTime!)}',
                    ),
                  ),
                ]),
                Pill(match == null ? '- Cocok' : '${((match <= 1 ? match * 100 : match)).round()}% Cocok',
                    bg: Colors.white, fg: rejected ? AppColors.danger : AppColors.success, icon: Icons.verified_rounded),
              ]),
              const SizedBox(height: 10),
              const Text('AI FaceMatch (Algoritma Verifikasi Otomatis)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ),
          const SizedBox(height: 12),

          // ANPR
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.pin_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Verifikasi Plat Nomor (ANPR)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _anprCol('Deteksi Masuk', s.plate, pct(s.entryPlateScore), s.entryImage, s.entryBoxes, s.entrySize)),
                const SizedBox(width: 10),
                Expanded(child: _anprCol('Deteksi Keluar', s.plate, pct(s.exitPlateScore), s.exitImage, s.exitBoxes, s.exitSize)),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card.withOpacity(.7), borderRadius: BorderRadius.circular(14)),
                child: const Row(children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(child: Text('Plat Identik, Cocok', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
                  Pill('Bebas Pelanggaran', bg: Colors.white, fg: AppColors.primaryDark),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Waktu & tarif
          AppCard(
            child: Column(children: [
              const Row(children: [
                Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Detail Waktu & Tarif', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                Pill('Motor R2', bg: Color(0xFFFFD6E3), fg: AppColors.pinkDark),
              ]),
              const SizedBox(height: 12),
              _timeRow(AppColors.primary, 'Waktu Masuk', s.entryKnown ? ParkingStore.dateTime(s.entryTime) : '-'),
              const SizedBox(height: 8),
              _timeRow(AppColors.pink, 'Waktu Keluar', s.exitTime == null ? '-' : ParkingStore.dateTime(s.exitTime!)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card.withOpacity(.7), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Durasi Parkir', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  const Spacer(),
                  Text(d == null ? '-' : ParkingStore.durationLong(d), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ]),
              ),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('TARIF TERBAYAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                const Spacer(),
                Text(d == null || rejected ? '-' : ParkingStore.tariffFor(d),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              ]),
              const SizedBox(height: 2),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('Lunas otomatis via E-Wallet', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Kesimpulan
          AppCard(
            color: rejected ? const Color(0xFFFFE3E3) : AppColors.card,
            borderColor: rejected ? AppColors.danger.withOpacity(.3) : AppColors.border,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: rejected ? AppColors.danger : AppColors.primary,
                child: Icon(rejected ? Icons.close_rounded : Icons.check_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rejected ? 'Kendaraan Ditolak' : 'Kendaraan Terverifikasi Sah',
                      style: TextStyle(fontWeight: FontWeight.w800, color: rejected ? AppColors.danger : AppColors.primaryDark)),
                  const SizedBox(height: 4),
                  Text(
                    s.note ??
                        (s.manual
                            ? 'Portal dibuka manual oleh petugas.'
                            : 'Kendaraan dan pengemudi sesuai data pos masuk dan telah keluar dari area parkir dengan tertib.'),
                    style: const TextStyle(fontSize: 12, height: 1.45),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur cetak bukti belum tersedia')),
              ),
              icon: const Icon(Icons.print_outlined),
              label: const Text('Cetak Bukti Transaksi'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _anprCol(String title, String plate, String acc, String? path, List<BoundingBox> boxes, Size? size) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapshotThumb(path: path, boxes: boxes, imageSize: size, height: 80),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(plate, style: AppTheme.mono(size: 15, w: FontWeight.w800)),
          Text('Akurasi $acc', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _timeRow(Color dot, String label, String value) => Row(children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
      ]);
}
