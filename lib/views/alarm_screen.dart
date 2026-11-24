import 'package:flutter/material.dart';
import '../core/scan_status.dart';
import '../models/parking_record.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import '../widgets/alarm_panel.dart';
import '../widgets/result_scaffold.dart';
import '../widgets/scan_images_row.dart';

/// Halaman "Alarm Wajah" - wajah saat keluar tidak sama dengan saat masuk.
class AlarmScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final f = record.faceScore;
    final pct = f == null ? '-' : '${(f * 100).round()}';
    final reg = registered;
    return ResultScaffold(
      isEntry: false,
      children: [
        ScanImagesRow(
          path: imagePath,
          boxes: record.boxes,
          faceText: 'Skor: $pct% (Tidak Cocok)',
          faceOk: false,
          plateText: reg == null ? record.plateNumber : '${record.plateNumber} • Terdaftar ${ParkingStore.hhmm(reg.entryTime)}',
          plateOk: true,
        ),
        const SizedBox(height: 14),
        AlarmPanel(
          registered: reg,
          currentImage: imagePath,
          currentBoxes: record.boxes,
          currentSize: imageSize,
          time: record.time,
          onCallSecurity: () {
            // TODO: kirim notifikasi ke tim keamanan lewat backend.
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tim keamanan lapangan dihubungi')));
          },
          onDismiss: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
