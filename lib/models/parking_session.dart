import 'dart:ui' show Size;
import 'bounding_box.dart';

enum SessionStatus { active, done, rejected }

/// Satu sesi verifikasi kendaraan (dari masuk hingga keluar / alarm).
class ParkingSession {
  ParkingSession({
    required this.id,
    required this.plate,
    required this.entryTime,
    this.status = SessionStatus.active,
  });

  final String id;
  String plate;
  String? detectedPlate;
  String? mismatchType;
  SessionStatus status;
  int seq = 0;

  // Masuk
  DateTime entryTime;
  bool entryKnown = true;
  String? entryImage;
  List<BoundingBox> entryBoxes = const [];
  Size? entrySize;
  double? entryPlateScore;

  // Keluar / insiden alarm
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
}
