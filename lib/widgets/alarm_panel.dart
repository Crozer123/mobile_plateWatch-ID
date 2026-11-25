import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/bounding_box.dart';
import '../models/parking_session.dart';
import '../services/alarm_sound_service.dart';
import '../services/parking_store.dart';
import 'app_card.dart';
import 'snapshot_thumb.dart';

/// Panel alarm saat wajah atau plat nomor keluar tidak cocok hingga 3x deteksi.
class AlarmPanel extends StatelessWidget {
  final ParkingSession? registered;
  final String registeredPlate;
  final String detectedPlate;
  final String mismatchType;
  final String? currentImage;
  final List<BoundingBox> currentBoxes;
  final Size? currentSize;
  final DateTime time;
  final VoidCallback onCallSecurity;
  final VoidCallback onDismiss;
  const AlarmPanel({
    super.key,
    required this.registered,
    required this.registeredPlate,
    required this.detectedPlate,
    required this.mismatchType,
    required this.currentImage,
    required this.currentBoxes,
    required this.currentSize,
    required this.time,
    required this.onCallSecurity,
    required this.onDismiss,
  });

  String get _reasonTitle {
    if (mismatchType == 'PLATE_MISMATCH') return 'Plat Nomor Berbeda (3x Cek)!';
    if (mismatchType == 'FACE_AND_PLATE_MISMATCH') return 'Wajah & Plat Berbeda (3x Cek)!';
    return 'Wajah Berbeda (3x Cek)!';
  }

  String get _reasonDesc {
    if (mismatchType == 'PLATE_MISMATCH') {
      return 'Pengendara tercatat masuk dengan plat $registeredPlate, tapi pas keluar terdeteksi plat $detectedPlate.';
    }
    if (mismatchType == 'FACE_AND_PLATE_MISMATCH') {
      return 'Selama 3x pemeriksaan beruntun, wajah dan plat ($detectedPlate) tidak cocok dengan data masuk ($registeredPlate).';
    }
    return 'Wajah pengendara berbeda dengan foto saat motor ($registeredPlate) pertama kali masuk.';
  }

  @override
  Widget build(BuildContext context) {
    final reg = registered;
    return Column(children: [
      AppCard(
        color: AppColors.dangerBg,
        borderColor: AppColors.dangerBorder,
        shadowColor: AppColors.dangerBorder,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_reasonTitle, style: AppTheme.heading(size: 16, color: AppColors.danger)),
              const SizedBox(height: 4),
              Text(_reasonDesc, style: AppTheme.body(size: 12.5, color: AppColors.danger, height: 1.5)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      ValueListenableBuilder<bool>(
        valueListenable: AlarmSoundService.instance.isPlaying,
        builder: (_, playing, __) => AppCard(
          color: playing ? AppColors.dangerBg : AppColors.card,
          borderColor: playing ? AppColors.dangerBorder : AppColors.border,
          shadowColor: playing ? AppColors.dangerBorder : AppColors.cardShadow,
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: playing ? AppColors.dangerBorder : AppColors.border, width: 1.5),
              ),
              child: Icon(
                playing ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: playing ? AppColors.danger : AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  playing ? 'Sirine Alarm Berbunyi!' : 'Sirine Alarm Dimatikan',
                  style: AppTheme.heading(size: 14, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  playing ? 'Tap tombol untuk hentikan suara.' : 'Tap untuk bunyikan ulang.',
                  style: AppTheme.body(size: 11.5, color: AppColors.textMuted, height: 1.3),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            SquishyButton(
              label: playing ? 'Matikan Suara' : 'Bunyikan',
              variant: playing ? SquishyVariant.secondary : SquishyVariant.danger,
              fullWidth: false,
              compact: true,
              onPressed: () {
                if (playing) {
                  AlarmSoundService.instance.stopAlarm();
                } else {
                  AlarmSoundService.instance.startAlarm();
                }
              },
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.compare_rounded, size: 18, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(child: Text('Bandingkan Data Masuk & Keluar', style: AppTheme.heading(size: 14.5, color: AppColors.textDark))),
            const Pill('3x Berbeda', bg: AppColors.dangerBg, fg: AppColors.danger, borderColor: AppColors.dangerBorder),
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
                  caption: reg == null ? 'Masuk: $registeredPlate' : '${ParkingStore.hhmmss(reg.entryTime)} Masuk',
                ),
                const SizedBox(height: 6),
                Text('Terdaftar: $registeredPlate', style: AppTheme.body(size: 11.5, w: FontWeight.w700, color: AppColors.textDark, height: 1.2)),
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
                Text('Terdeteksi: $detectedPlate', style: AppTheme.body(size: 11.5, w: FontWeight.w700, color: AppColors.danger, height: 1.2)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.butterShadow, width: 1.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.butterInk),
                const SizedBox(width: 6),
                Text('Catatan untuk Petugas:', style: AppTheme.heading(size: 13, color: AppColors.butterInk)),
              ]),
              const SizedBox(height: 4),
              Text(
                'Tahan kendaraan sebentar ya. Cocokkan STNK, plat nomor, dan pengendara sebelum izin keluar diberikan.',
                style: AppTheme.body(size: 12, color: AppColors.butterInk, height: 1.5),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      SquishyButton(
        label: 'Panggil Petugas Jaga',
        icon: Icons.support_agent_rounded,
        variant: SquishyVariant.danger,
        onPressed: onCallSecurity,
      ),
      const SizedBox(height: 10),
      SquishyButton(
        label: 'Matikan Alarm & Kembali',
        icon: Icons.camera_alt_rounded,
        variant: SquishyVariant.secondary,
        onPressed: onDismiss,
      ),
    ]);
  }
}
