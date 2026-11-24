import 'dart:math' as math;
import 'dart:ui' show Size;
import 'package:flutter/foundation.dart';
import '../models/bounding_box.dart';
import '../models/parking_session.dart';

/// Penyimpanan lokal (in-memory) sesi parkir dari hasil scan.
/// Kalau backend nanti punya endpoint daftar parkir/riwayat, ganti isi
/// class ini dengan pemanggilan API; UI tidak perlu diubah.
class ParkingStore extends ChangeNotifier {
  ParkingStore._();
  static final ParkingStore instance = ParkingStore._();

  static const capacity = 100;
  final List<ParkingSession> _active = [];
  final List<ParkingSession> _closed = []; // terbaru di depan
  int _seq = 0;

  List<ParkingSession> get active => List.unmodifiable(_active);
  List<ParkingSession> get closed => List.unmodifiable(_closed);
  int get activeCount => _active.length;

  static String _key(String p) => p.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  ParkingSession? findActive(String plate) {
    for (final s in _active) {
      if (_key(s.plate) == _key(plate)) return s;
    }
    return null;
  }

  ParkingSession _create(String plate, DateTime t) {
    _seq++;
    return ParkingSession(id: 'TRX-${98820 + _seq}', plate: plate, entryTime: t)..seq = _seq;
  }

  ParkingSession recordEntry({
    required String plate,
    required DateTime time,
    String? imagePath,
    List<BoundingBox> boxes = const [],
    Size? size,
    double? plateScore,
    bool manual = false,
    String? note,
  }) {
    final old = findActive(plate);
    if (old != null) _active.remove(old);
    final s = _create(plate, time)
      ..entryImage = imagePath
      ..entryBoxes = boxes
      ..entrySize = size
      ..entryPlateScore = plateScore
      ..manual = manual
      ..note = note;
    _active.add(s);
    notifyListeners();
    return s;
  }

  ParkingSession recordExit({
    required String plate,
    required DateTime time,
    String? imagePath,
    List<BoundingBox> boxes = const [],
    Size? size,
    double? plateScore,
    double? faceMatch,
    bool manual = false,
    String? note,
  }) {
    var s = findActive(plate);
    if (s != null) {
      _active.remove(s);
    } else {
      s = _create(plate, time)
        ..entryKnown = false
        ..note = 'Tiket masuk tidak tercatat di aplikasi'
        ..noteIsError = true;
    }
    s
      ..exitTime = time
      ..status = SessionStatus.done
      ..exitImage = imagePath
      ..exitBoxes = boxes
      ..exitSize = size
      ..exitPlateScore = plateScore
      ..faceMatch = faceMatch
      ..manual = manual;
    if (note != null) {
      s
        ..note = note
        ..noteIsError = false;
    }
    _closed.insert(0, s);
    notifyListeners();
    return s;
  }

  /// Percobaan keluar ditolak (wajah tidak cocok / ditutup petugas).
  /// Kendaraan aslinya tetap tercatat parkir aktif.
  ParkingSession recordRejected({
    required String plate,
    required DateTime time,
    String? imagePath,
    List<BoundingBox> boxes = const [],
    Size? size,
    double? plateScore,
    double? faceMatch,
    required String note,
  }) {
    final reg = findActive(plate);
    final s = _create(plate, reg?.entryTime ?? time)
      ..entryKnown = reg != null
      ..entryImage = reg?.entryImage
      ..entryBoxes = reg?.entryBoxes ?? const []
      ..entrySize = reg?.entrySize
      ..entryPlateScore = reg?.entryPlateScore
      ..exitTime = time
      ..exitImage = imagePath
      ..exitBoxes = boxes
      ..exitSize = size
      ..exitPlateScore = plateScore
      ..faceMatch = faceMatch
      ..status = SessionStatus.rejected
      ..note = note
      ..noteIsError = true;
    _closed.insert(0, s);
    notifyListeners();
    return s;
  }

  /// Mengisi data contoh (lihat core/demo_data.dart).
  void loadDemo({required List<ParkingSession> active, required List<ParkingSession> closed}) {
    _active
      ..clear()
      ..addAll(active);
    _closed
      ..clear()
      ..addAll(closed);
    _seq = 100;
    notifyListeners();
  }

  // ---- statistik ----
  static bool _today(DateTime t) {
    final n = DateTime.now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }

  int get doneToday => _closed.where((s) => s.status == SessionStatus.done && _today(s.closedAt)).length;
  int get rejectedToday => _closed.where((s) => s.status == SessionStatus.rejected && _today(s.closedAt)).length;

  int get revenueToday {
    var sum = 0;
    for (final s in _closed) {
      final d = s.duration;
      if (s.status == SessionStatus.done && d != null && _today(s.closedAt)) sum += tariffValue(d);
    }
    return sum;
  }

  Duration get averageParking {
    if (_active.isEmpty) return Duration.zero;
    final now = DateTime.now();
    final total = _active.fold<int>(0, (a, s) => a + now.difference(s.entryTime).inMinutes);
    return Duration(minutes: total ~/ _active.length);
  }

  // ---- format ----
  static int tariffValue(Duration d) => math.max(1, (d.inMinutes / 60).ceil()) * 2000; // Rp 2.000/jam
  static String tariffFor(Duration d) => rupiah(tariffValue(d));

  static String rupiah(int v) =>
      'Rp ${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';

  static String _2(int n) => n.toString().padLeft(2, '0');
  static String hhmm(DateTime t) => '${_2(t.hour)}:${_2(t.minute)}';
  static String hhmmss(DateTime t) => '${_2(t.hour)}:${_2(t.minute)}:${_2(t.second)}';
  static String hm(DateTime t) => '${hhmm(t)} WIB';

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  static String dateTime(DateTime t) => '${t.day} ${_months[t.month - 1]} ${t.year}, ${hm(t)}';

  static String durationText(Duration d) => '${d.inHours} j ${d.inMinutes % 60} m';
  static String durationShort(Duration d) => '${d.inHours}j ${d.inMinutes % 60}m';
  static String durationLong(Duration d) => '${d.inHours} Jam ${d.inMinutes % 60} Menit';
  static String durationWords(Duration d) => '${d.inHours} jam ${d.inMinutes % 60} menit';
}
