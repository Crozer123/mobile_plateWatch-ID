import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/scan_status.dart';
import '../models/parking_record.dart';
import '../models/parking_session.dart';
import '../core/demo_data.dart';
import '../services/api_service.dart';
import '../services/mock_scan_service.dart';
import '../services/parking_store.dart';
import '../widgets/camera_panel.dart';
import '../widgets/scanner_status_banner.dart';
import 'alarm_screen.dart';
import 'scan_success_screen.dart';
import 'staff_confirm_screen.dart';

/// HALAMAN KAMERA (berdiri sendiri, 1 kamera).
/// TIDAK ADA pilihan Masuk/Keluar. Setelah foto dibaca:
///  plat BELUM ada di Parkir Aktif -> MASUK
///  plat SUDAH ada di Parkir Aktif -> KELUAR
/// Lalu:
///  berhasil      -> ScanSuccessScreen  (Masuk Berhasil / Keluar Cocok)
///  gagal 3x      -> StaffConfirmScreen (konfirmasi petugas)
///  wajah beda    -> AlarmScreen
///  wajah tertutup-> tetap di sini, coba ulang otomatis (maks 3x)
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const _maxAttempt = 3;
  static const _faceMsg =
      'Harap buka kaca helm atau lepas masker Anda agar sensor dapat memverifikasi profil pengendara.';
  static const _plateMsg = 'Plat nomor tidak terbaca. Arahkan kamera ke plat motor dan pastikan tidak terhalang.';

  final _api = ApiService();
  final _store = ParkingStore.instance;

  CameraController? _cam;
  String? _camError;

  /// gate_mode yang dikirim ke backend. 'AUTO' = backend/aplikasi menentukan
  /// masuk atau keluar sendiri (lihat catatan di penjelasan).
  static const _gateMode = 'AUTO';
  bool _busy = false;
  bool _serverError = false;

  // info percobaan ulang (null = tidak sedang retry)
  String? _retryTitle;
  String _retryMsg = '';
  int _shownAttempt = 1;
  int _attempt = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cam?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _camError = 'Kamera tidak ditemukan.\nGunakan tombol galeri.');
        return;
      }
      // Ganti ke CameraLensDirection.front untuk kamera depan.
      final cam = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final c = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() => _cam = c);
    } catch (_) {
      if (mounted) setState(() => _camError = 'Kamera tidak bisa dibuka.\nCek izin kamera.');
    }
  }

  /// INPUT GAMBAR #1: foto dari kamera.
  Future<void> _capture() async {
    final c = _cam;
    if (c == null || !c.value.isInitialized || _busy) return;
    try {
      final x = await c.takePicture();
      await _process(File(x.path));
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// INPUT GAMBAR #2: foto dari galeri (untuk uji tanpa kamera).
  Future<void> _pickGallery() async {
    if (_busy) return;
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) await _process(File(x.path));
  }

  Future<Size?> _readSize(File f) async {
    try {
      final img = await decodeImageFromList(await f.readAsBytes());
      return Size(img.width.toDouble(), img.height.toDouble());
    } catch (_) {
      return null;
    }
  }

  /// Aturan utama: plat sudah ada di Parkir Aktif -> keluar, selain itu -> masuk.
  bool _isEntryFor(ParkingRecord rec) => !(rec.hasPlate && _store.findActive(rec.plateNumber) != null);

  String _pct(double? v) => v == null ? '-' : '${(v * 100).round()}';

  /// Semua gambar berakhir di sini -> ApiService.scanFrame -> backend AI.
  Future<void> _process(File image) async {
    _timer?.cancel();
    setState(() {
      _busy = true;
      _serverError = false;
    });
    final size = await _readSize(image);
    final rec = kUseMockScan ? await MockScanService.scan(image.path) : await _api.scanFrame(image.path, _gateMode);
    if (!mounted) return;

    if (rec == null) {
      setState(() {
        _busy = false;
        _serverError = true;
        _retryTitle = null;
      });
      return;
    }

    var phase = rec.phase;
    var msg = _faceMsg;
    var title = 'Wajah tidak terdeteksi!';
    if (phase == ScanPhase.success && !rec.hasPlate) {
      phase = ScanPhase.retrying; // "sukses" tapi plat kosong -> belum valid
      msg = _plateMsg;
      title = 'Plat tidak terbaca!';
    }

    if (phase == ScanPhase.retrying) {
      if (_attempt >= _maxAttempt) {
        phase = ScanPhase.manual;
        _attempt = 1;
      } else {
        setState(() {
          _busy = false;
          _shownAttempt = _attempt;
          _retryTitle = title;
          _retryMsg = msg;
        });
        _attempt++;
        if (_cam != null) _timer = Timer(const Duration(seconds: 2), _capture); // coba lagi otomatis
        return;
      }
    } else {
      _attempt = 1;
    }

    setState(() {
      _busy = false;
      _retryTitle = null;
    });

    final entry = _isEntryFor(rec);
    switch (phase) {
      case ScanPhase.success:
        await _onSuccess(rec, image.path, size, entry);
      case ScanPhase.manual:
        await _onManual(rec, image.path, size, entry);
      case ScanPhase.alarm:
        await _onAlarm(rec, image.path, size);
      case ScanPhase.retrying:
        break;
    }
  }

  Future<void> _onSuccess(ParkingRecord rec, String path, Size? size, bool entry) async {
    final s = entry
        ? _store.recordEntry(plate: rec.plateNumber, time: rec.time, imagePath: path, boxes: rec.boxes, size: size, plateScore: rec.plateScore)
        : _store.recordExit(
            plate: rec.plateNumber,
            time: rec.time,
            imagePath: path,
            boxes: rec.boxes,
            size: size,
            plateScore: rec.plateScore,
            faceMatch: rec.faceScore);
    await _pushSuccess(rec, s, path, size, entry);
  }

  Future<void> _pushSuccess(ParkingRecord rec, ParkingSession? s, String path, Size? size, bool entry) async {
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ScanSuccessScreen(record: rec, session: s, imagePath: path, imageSize: size, isEntry: entry),
    ));
  }

  Future<void> _onManual(ParkingRecord rec, String path, Size? size, bool entry) async {
    if (!mounted) return;
    final open = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => StaffConfirmScreen(record: rec, imagePath: path, isEntry: entry, maxAttempt: _maxAttempt),
    ));
    if (open == true) {
      const note = 'Dibuka petugas setelah 3x gagal verifikasi';
      ParkingSession? s;
      if (rec.hasPlate) {
        // TODO: kirim konfirmasi manual ke backend jika endpoint-nya sudah ada.
        s = entry
            ? _store.recordEntry(plate: rec.plateNumber, time: DateTime.now(), imagePath: path, boxes: rec.boxes, size: size, manual: true, note: note)
            : _store.recordExit(plate: rec.plateNumber, time: DateTime.now(), imagePath: path, boxes: rec.boxes, size: size, manual: true, note: note);
      }
      await _pushSuccess(rec, s, path, size, entry);
    } else if (open == false && rec.hasPlate) {
      _store.recordRejected(
        plate: rec.plateNumber,
        time: DateTime.now(),
        imagePath: path,
        boxes: rec.boxes,
        size: size,
        note: 'Ditutup petugas setelah 3x gagal verifikasi',
      );
    }
  }

  Future<void> _onAlarm(ParkingRecord rec, String path, Size? size) async {
    ParkingSession? registered;
    if (rec.hasPlate) {
      registered = _store.findActive(rec.plateNumber);
      _store.recordRejected(
        plate: rec.plateNumber,
        time: rec.time,
        imagePath: path,
        boxes: rec.boxes,
        size: size,
        plateScore: rec.plateScore,
        faceMatch: rec.faceScore,
        note: 'Wajah tidak cocok (Skor ${_pct(rec.faceScore)}%)',
      );
    }
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AlarmScreen(record: rec, registered: registered, imagePath: path, imageSize: size),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final retrying = _retryTitle != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C27),
      body: Stack(fit: StackFit.expand, children: [
        CameraView(controller: _cam, error: _camError),
        CustomPaint(painter: BracketPainter(color: retrying ? AppColors.warning : Colors.white70, inset: 36, len: 30)),
        SafeArea(
          child: Column(children: [
            // atas: judul + pilihan mode
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Text('PLATEWATCH-ID • CAM-01 LIVE', style: AppTheme.mono(size: 10, color: Colors.white, spacing: .8)),
                  ]),
                ),
              ]),
            ),
            const Spacer(),
            // tengah-bawah: pesan
            if (_serverError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ScannerStatusBanner(
                  phase: null, isEntry: true, attempt: 1, maxAttempt: _maxAttempt, message: '', serverError: true,
                ),
              )
            else if (retrying)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ScannerStatusBanner(
                    phase: ScanPhase.retrying,
                    isEntry: true,
                    attempt: _shownAttempt,
                    maxAttempt: _maxAttempt,
                    message: _retryMsg,
                    title: _retryTitle!,
                    serverError: false,
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)),
                child: const Text('Arahkan wajah dan plat ke dalam bingkai.\nMasuk atau keluar ditentukan otomatis.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            const SizedBox(height: 14),
            // bawah: galeri | rana | spasi
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton.filledTonal(
                  onPressed: _busy ? null : _pickGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Pilih dari galeri',
                ),
                GestureDetector(
                  onTap: _busy ? null : _capture,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _busy ? Colors.white38 : AppColors.pink),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.pinkDark),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ]),
            ),
          ]),
        ),
        if (_busy)
          Container(
            color: Colors.black54,
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('Memproses...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
      ]),
    );
  }
}
