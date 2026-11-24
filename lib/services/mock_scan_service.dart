import '../models/parking_record.dart';

/// Balasan PALSU pengganti backend, hanya untuk uji alur & tampilan.
/// Aktif jika kUseMockScan = true (core/demo_data.dart).
///
/// Urutan skenario (berputar tiap kali menekan scan / memilih foto):
///  1. Plat B 4821 SKA, sukses       -> belum terdaftar    => MASUK berhasil
///  2. Plat B 4821 SKA, sukses       -> sudah terdaftar    => KELUAR cocok
///  3-5. Plat B 3021 KLD, wajah tertutup -> coba ulang 3x  => konfirmasi petugas
///  6. Plat B 6912 PZX, wajah beda   -> (terdaftar di data demo) => ALARM
class MockScanService {
  static int _n = 0;

  static Map<String, dynamic> _box(String label, double conf, double x1, double y1, double x2, double y2) =>
      {'label': label, 'confidence': conf, 'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};

  static Future<ParkingRecord?> scan(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final i = _n++ % 6;
    final now = DateTime.now().toIso8601String();

    final plateBox = _box('plate', .991, .28, .62, .72, .78);
    Map<String, dynamic> json;
    switch (i) {
      case 0:
      case 1:
        json = {
          'timestamp': now,
          'status': 'SUCCESS',
          'plate_number': 'B 4821 SKA',
          'boxes': [_box('face', .98, .36, .08, .64, .38), plateBox],
        };
      case 2:
      case 3:
      case 4:
        json = {
          'timestamp': now,
          'status': 'NO_FACE',
          'plate_number': 'B 3021 KLD',
          'boxes': [plateBox],
        };
      default:
        json = {
          'timestamp': now,
          'status': 'MISMATCH',
          'plate_number': 'B 6912 PZX',
          'boxes': [_box('face', .41, .36, .08, .64, .38), plateBox],
        };
    }
    return ParkingRecord.fromJson(json);
  }
}
