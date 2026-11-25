import 'dart:ui' show Size;
import 'package:flutter/foundation.dart';
import '../models/bounding_box.dart';
import '../models/parking_session.dart';

/// Penyimpanan state sesi verifikasi sepeda motor masuk/keluar secara real-time.
class ParkingStore extends ChangeNotifier {
  ParkingStore._();
  static final ParkingStore instance = ParkingStore._();

  final List<ParkingSession> _active = [];
  final List<ParkingSession> _closed = []; // terbaru di depan
  int _seq = 0;
  int _totalMasuk = 0;
  int _totalKeluar = 0;
  bool _scannerTabActive = true;

  List<ParkingSession> get active => List.unmodifiable(_active);
  List<ParkingSession> get closed => List.unmodifiable(_closed);
  int get activeCount => _active.length;
  int get sedangDiDalam => _active.length;
  int get totalMasuk => _totalMasuk;
  int get totalKeluar => _totalKeluar;
  bool get scannerTabActive => _scannerTabActive;

  void setScannerTabActive(bool active) {
    if (_scannerTabActive == active) return;
    _scannerTabActive = active;
    notifyListeners();
  }

  static String _key(String p) => p.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  ParkingSession? findActive(String plate) {
    for (final s in _active) {
      if (_key(s.plate) == _key(plate)) return s;
    }
    return null;
  }

  ParkingSession _create(String plate, DateTime t, {String? ticketCode}) {
    _seq++;
    return ParkingSession(
      id: (ticketCode != null && ticketCode.isNotEmpty) ? ticketCode : 'PK-${1000 + _seq}',
      plate: plate,
      entryTime: t,
    )..seq = _seq;
  }

  ParkingSession recordEntry({
    required String plate,
    required DateTime time,
    String? ticketCode,
    String? imagePath,
    List<BoundingBox> boxes = const [],
    Size? size,
    double? plateScore,
    bool manual = false,
    String? note,
    int? serverTotalMasuk,
    int? serverTotalKeluar,
  }) {
    final old = findActive(plate);
    if (old != null) _active.remove(old);
    final s = _create(plate, time, ticketCode: ticketCode)
      ..entryImage = imagePath
      ..entryBoxes = boxes
      ..entrySize = size
      ..entryPlateScore = plateScore
      ..manual = manual
      ..note = note;
    _active.add(s);

    if (serverTotalMasuk != null) {
      _totalMasuk = serverTotalMasuk;
    } else {
      _totalMasuk++;
    }
    if (serverTotalKeluar != null) {
      _totalKeluar = serverTotalKeluar;
    }

    notifyListeners();
    return s;
  }

  ParkingSession recordExit({
    required String plate,
    required DateTime time,
    String? ticketCode,
    String? imagePath,
    List<BoundingBox> boxes = const [],
    Size? size,
    double? plateScore,
    double? faceMatch,
    bool manual = false,
    String? note,
    int? serverTotalMasuk,
    int? serverTotalKeluar,
  }) {
    var s = findActive(plate);
    if (s != null) {
      _active.remove(s);
    } else {
      s = _create(plate, time, ticketCode: ticketCode)
        ..entryKnown = false
        ..note = 'Data masuk tercatat di server';
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

    if (serverTotalMasuk != null) {
      _totalMasuk = serverTotalMasuk;
    }
    if (serverTotalKeluar != null) {
      _totalKeluar = serverTotalKeluar;
    } else {
      _totalKeluar++;
    }

    notifyListeners();
    return s;
  }

  /// Percobaan keluar gagal sampai 3x (wajah / plat berbeda) -> catat insiden alarm.
  /// Sepeda asli yang terdaftar tetap berada di daftar sedang di dalam.
  ParkingSession recordRejected({
    required String plate,
    String? detectedPlate,
    String? mismatchType,
    required DateTime time,
    String? ticketCode,
    String? imagePath,
    List<BoundingBox> boxes = const [],
    Size? size,
    double? plateScore,
    double? faceMatch,
    required String note,
    int? serverTotalMasuk,
    int? serverTotalKeluar,
  }) {
    final reg = findActive(plate);
    final s = _create(plate, reg?.entryTime ?? time, ticketCode: ticketCode)
      ..detectedPlate = detectedPlate
      ..mismatchType = mismatchType
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

    if (serverTotalMasuk != null) _totalMasuk = serverTotalMasuk;
    if (serverTotalKeluar != null) _totalKeluar = serverTotalKeluar;

    notifyListeners();
    return s;
  }

  void syncFromDashboard(Map<String, dynamic> data) {
    final m = (data['total_masuk'] as num?)?.toInt();
    final k = (data['total_keluar'] as num?)?.toInt();
    var changed = false;
    if (m != null && m != _totalMasuk) {
      _totalMasuk = m;
      changed = true;
    }
    if (k != null && k != _totalKeluar) {
      _totalKeluar = k;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void loadDemo({required List<ParkingSession> active, required List<ParkingSession> closed}) {
    _active
      ..clear()
      ..addAll(active);
    _closed
      ..clear()
      ..addAll(closed);
    final doneCount = closed.where((s) => s.status == SessionStatus.done).length;
    _totalMasuk = active.length + doneCount;
    _totalKeluar = doneCount;
    _seq = 100;
    notifyListeners();
  }

  void clearAll() {
    _active.clear();
    _closed.clear();
    _totalMasuk = 0;
    _totalKeluar = 0;
    _seq = 0;
    notifyListeners();
  }

  // ---- statistik ----
  static bool _today(DateTime t) {
    final n = DateTime.now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }

  int get doneToday => _closed.where((s) => s.status == SessionStatus.done && _today(s.closedAt)).length;
  int get rejectedToday => _closed.where((s) => s.status == SessionStatus.rejected && _today(s.closedAt)).length;

  // ---- format ----
  static String _two(int n) => n.toString().padLeft(2, '0');
  static String hhmm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';
  static String hhmmss(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
  static String hm(DateTime t) => '${hhmm(t)} WIB';

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  static String dateTime(DateTime t) => '${t.day} ${_months[t.month - 1]} ${t.year}, ${hm(t)}';

  static String durationText(Duration d) => '${d.inHours} j ${d.inMinutes % 60} m';
  static String durationShort(Duration d) => '${d.inHours}j ${d.inMinutes % 60}m';
  static String durationLong(Duration d) => '${d.inHours} Jam ${d.inMinutes % 60} Menit';
  static String durationWords(Duration d) => '${d.inHours} jam ${d.inMinutes % 60} menit';
}
