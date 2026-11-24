import '../models/bounding_box.dart';
import '../models/parking_record.dart';

enum ScanPhase { success, retrying, manual, alarm }

/// Menerjemahkan field `status` dari backend ke fase tampilan.
/// !! SESUAIKAN kata kunci di bawah dengan nilai status yang
/// sebenarnya dikirim backend (tanyakan ke temanmu). !!
class ScanStatus {
  // ALARM = wajah saat keluar TIDAK cocok dengan saat masuk.
  static const _alarmKeys = ['MISMATCH', 'ALARM', 'NOT_MATCH', 'FACE_DIFF', 'STOLEN'];
  // MANUAL = perlu keputusan petugas.
  static const _manualKeys = ['MANUAL', 'DENIED', 'REJECT', 'UNREGISTERED', 'NOT_FOUND'];
  static const _retryKeys = ['SCANNING', 'NO_FACE', 'FACE_NOT', 'MASK', 'HELMET', 'RETRY', 'UNKNOWN'];
  static const _successKeys = ['SUCCESS', 'OPEN', 'MATCH', 'VALID', 'GRANTED', 'OK'];

  static ScanPhase phaseOf(String status) {
    final s = status.toUpperCase();
    if (_alarmKeys.any(s.contains)) return ScanPhase.alarm;
    if (_manualKeys.any(s.contains)) return ScanPhase.manual;
    if (_retryKeys.any(s.contains)) return ScanPhase.retrying;
    if (_successKeys.any(s.contains)) return ScanPhase.success;
    return ScanPhase.retrying;
  }
}

double? _bestConfidence(List<BoundingBox> boxes, List<String> keys) {
  double? best;
  for (final b in boxes) {
    final l = b.label.toLowerCase();
    if (keys.any(l.contains)) {
      final c = b.confidence <= 1 ? b.confidence : b.confidence / 100;
      if (best == null || c > best) best = c;
    }
  }
  return best;
}

extension ParkingRecordX on ParkingRecord {
  ScanPhase get phase => ScanStatus.phaseOf(status);
  bool get hasPlate => plateNumber.trim().isNotEmpty && plateNumber.trim() != '-';
  DateTime get time => DateTime.tryParse(timestamp) ?? DateTime.now();
  double? get faceScore => _bestConfidence(boxes, ['face', 'wajah']);
  double? get plateScore => _bestConfidence(boxes, ['plate', 'plat']);
}
