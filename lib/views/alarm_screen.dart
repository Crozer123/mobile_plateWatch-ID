import 'package:flutter/material.dart';
import '../core/scan_status.dart';
import '../models/parking_record.dart';
import '../models/parking_session.dart';
import '../services/alarm_sound_service.dart';
import '../services/parking_store.dart';
import '../widgets/alarm_panel.dart';
import '../widgets/result_scaffold.dart';
import '../widgets/scan_images_row.dart';

/// Halaman "Alarm Aktif" - otomatis membunyikan suara sirine aplikasi ketika
/// deteksi keluar berbeda wajah atau plat nomor hingga 3x berturut-turut.
class AlarmScreen extends StatefulWidget {
  final ParkingRecord record;
  final ParkingSession? registered;
  final String imagePath;
  final Size? imageSize;
  const AlarmScreen({
    super.key,
    required this.record,
    required this.registered,
    required this.imagePath,
    required this.imageSize,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    AlarmSoundService.instance.startAlarm();
  }

  @override
  void dispose() {
    AlarmSoundService.instance.stopAlarm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final reg = widget.registered;
    final f = record.faceScore;
    final pct = f == null ? '-' : '${(f * 100).round()}';
    final mismatch = record.mismatchType ?? 'FACE_MISMATCH';
    final isPlateDiff = mismatch == 'PLATE_MISMATCH';
    final isBothDiff = mismatch == 'FACE_AND_PLATE_MISMATCH';
    final regPlate = record.registeredPlate ?? reg?.plate ?? record.plateNumber;

    return ResultScaffold(
      isEntry: false,
      children: [
        ScanImagesRow(
          path: widget.imagePath,
          boxes: record.boxes,
          faceText: isPlateDiff ? 'Skor: $pct% (Cocok)' : 'Skor: $pct% (Berbeda)',
          faceOk: isPlateDiff,
          faceFailedMark: !isPlateDiff,
          plateText: (isPlateDiff || isBothDiff)
              ? '${record.plateNumber} != $regPlate'
              : (reg == null ? record.plateNumber : '${record.plateNumber} • Masuk ${ParkingStore.hhmm(reg.entryTime)}'),
          plateOk: !(isPlateDiff || isBothDiff),
        ),
        const SizedBox(height: 14),
        AlarmPanel(
          registered: reg,
          registeredPlate: regPlate,
          detectedPlate: record.plateNumber,
          mismatchType: mismatch,
          currentImage: widget.imagePath,
          currentBoxes: record.boxes,
          currentSize: widget.imageSize,
          time: record.time,
          onCallSecurity: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Peringatan darurat diteruskan ke petugas jaga!')),
            );
          },
          onDismiss: () async {
            await AlarmSoundService.instance.stopAlarm();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
