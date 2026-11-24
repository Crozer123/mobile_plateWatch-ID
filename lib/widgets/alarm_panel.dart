import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/bounding_box.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'app_card.dart';
import 'snapshot_thumb.dart';

/// Tampilan alarm saat wajah keluar TIDAK cocok dengan saat masuk.
/// Portal terkunci total, tombol buka manual dinonaktifkan.
class AlarmPanel extends StatelessWidget {
  final ParkingSession? registered;
  final String? currentImage;
  final List<BoundingBox> currentBoxes;
  final Size? currentSize;
  final DateTime time;
  final VoidCallback onCallSecurity;
  final VoidCallback onDismiss;
  const AlarmPanel({
    super.key,
    required this.registered,
    required this.currentImage,
    required this.currentBoxes,
    required this.currentSize,
    required this.time,
    required this.onCallSecurity,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final reg = registered;
    return Column(children: [
      AppCard(
        color: const Color(0xFFFFE3E3),
        borderColor: AppColors.danger.withOpacity(.35),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(radius: 20, backgroundColor: AppColors.danger, child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Alarm Aktif!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.danger)),
              SizedBox(height: 3),
              Text('Wajah pengendara tidak sama dengan saat kendaraan masuk.',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF8A2A2A))),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        color: AppColors.card,
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.lock_rounded, color: AppColors.primary, size: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Portal Terkunci Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              SizedBox(height: 3),
              Text('Portal terkunci, tidak bisa terbuka otomatis. Tombol buka manual dinonaktifkan.',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textMuted)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.compare_rounded, size: 18, color: AppColors.danger),
            SizedBox(width: 8),
            Expanded(child: Text('Komparasi Snapshot Wajah', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
            Pill('Selisih Signifikan', bg: Color(0xFFFFE0E0), fg: AppColors.danger),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Column(children: [
                SnapshotThumb(
                  path: reg?.entryImage,
                  boxes: reg?.entryBoxes ?? const [],
                  imageSize: reg?.entrySize,
                  height: 130,
                  caption: reg == null ? 'Tidak tersimpan' : '${ParkingStore.hhmmss(reg.entryTime)} Masuk',
                ),
                const SizedBox(height: 6),
                const Text('Pengendara Terdaftar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(children: [
                SnapshotThumb(
                  path: currentImage,
                  boxes: currentBoxes,
                  imageSize: currentSize,
                  height: 130,
                  borderColor: AppColors.danger,
                  caption: '${ParkingStore.hhmmss(time)} Keluar',
                ),
                const SizedBox(height: 6),
                const Text('Pengendara Saat Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card.withOpacity(.7), borderRadius: BorderRadius.circular(14)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryDark),
                SizedBox(width: 6),
                Text('Instruksi Prosedural Petugas:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
              SizedBox(height: 6),
              Text(
                'Pengendara berbeda dengan saat masuk. Hubungi petugas keamanan untuk pemeriksaan fisik STNK dan KTP secara manual.',
                style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMuted),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onCallSecurity,
          icon: const Icon(Icons.support_agent_rounded),
          label: const Text('Panggil Tim Keamanan Lapangan'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.pinkDark,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      TextButton(onPressed: onDismiss, child: const Text('Tutup alarm')),
    ]);
  }
}
