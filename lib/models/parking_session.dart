import 'dart:ui' show Size;
import 'bounding_box.dart';

enum SessionStatus { active, done, rejected }

/// Satu tiket parkir (dari masuk sampai keluar / ditolak).
/// Model ini dibuat di sisi aplikasi untuk menampilkan Parkir Aktif,
/// Riwayat, dan Detail Tiket dari hasil scan backend.
class ParkingSession {
  ParkingSession({required this.id, required this.plate, required this.entryTime, this.status = SessionStatus.active});

  final String id;
  String plate;
  SessionStatus status;
  int seq = 0;

  // masuk
  DateTime entryTime;
  bool entryKnown = true;
  String? entryImage;
  List<BoundingBox> entryBoxes = const [];
  Size? entrySize;
  double? entryPlateScore;

  // keluar / percobaan keluar
  DateTime? exitTime;
  String? exitImage;
  List<BoundingBox> exitBoxes = const [];
  Size? exitSize;
  double? exitPlateScore;
  double? faceMatch; // 0..1

  bool manual = false;
  String? note;
  bool noteIsError = false;

  Duration? get duration => (exitTime != null && entryKnown) ? exitTime!.difference(entryTime) : null;
  DateTime get closedAt => exitTime ?? entryTime;

  /// PLACEHOLDER: backend belum mengirim lokasi slot, jadi dibuat dari nomor urut.
  String get slotLabel => 'Lantai ${seq % 2 + 1} • A-${(seq % 20 + 1).toString().padLeft(2, '0')}';
}
