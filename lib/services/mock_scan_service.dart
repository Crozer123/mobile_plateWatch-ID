import '../models/parking_record.dart';

/// Balasan simulasi cadangan jika `kUseMockScan = true`.
class MockScanService {
  static int _n = 0;

  static Map<String, dynamic> _box(String label, double conf, double x1, double y1, double x2, double y2) =>
      {'label': label, 'confidence': conf, 'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};

  static Future<ParkingRecord?> scan(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final i = _n++ % 5;
    final now = DateTime.now().toIso8601String();
    final plateBox = _box('plate', .99, .28, .62, .72, .78);

    Map<String, dynamic> json;
    switch (i) {
      case 0:
        json = {
          'timestamp': now,
          'gate_mode': 'IN',
          'status': 'ENTRY_SUCCESS',
          'plate_number': 'B 4821 SKA',
          'boxes': [_box('face', .98, .36, .08, .64, .38), plateBox],
        };
      case 1:
      case 2:
        json = {
          'timestamp': now,
          'gate_mode': 'OUT',
          'status': 'MISMATCH_RETRY',
          'plate_number': 'B 4821 SKA',
          'registered_plate': 'B 4821 SKA',
          'mismatch_type': 'FACE_MISMATCH',
          'attempt': i,
          'max_attempt': 3,
          'similarity_score': .41,
          'message': 'Wajah berbeda! Percobaan $i dari 3.',
          'boxes': [_box('face', .41, .36, .08, .64, .38), plateBox],
        };
      case 3:
        json = {
          'timestamp': now,
          'gate_mode': 'OUT',
          'status': 'ALARM',
          'plate_number': 'B 4821 SKA',
          'registered_plate': 'B 4821 SKA',
          'mismatch_type': 'FACE_MISMATCH',
          'attempt': 3,
          'max_attempt': 3,
          'similarity_score': .38,
          'message': 'ALARM! 3x deteksi wajah tidak cocok.',
          'boxes': [_box('face', .38, .36, .08, .64, .38), plateBox],
        };
      default:
        json = {
          'timestamp': now,
          'gate_mode': 'OUT',
          'status': 'EXIT_SUCCESS',
          'plate_number': 'B 4821 SKA',
          'registered_plate': 'B 4821 SKA',
          'similarity_score': .95,
          'boxes': [_box('face', .95, .36, .08, .64, .38), plateBox],
        };
    }
    return ParkingRecord.fromJson(json);
  }
}
