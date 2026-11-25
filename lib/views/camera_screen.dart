import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../core/demo_data.dart';
import '../core/scan_status.dart';
import '../models/bounding_box.dart';
import '../models/parking_record.dart';
import '../services/alarm_sound_service.dart';
import '../services/api_service.dart';
import '../services/mock_scan_service.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/bbox_pointer.dart';
import '../widgets/camera_panel.dart';
import '../widgets/kawaii_decorations.dart';
import '../widgets/scanner_status_banner.dart';
import 'alarm_screen.dart';
import 'scan_success_screen.dart';

/// HALAMAN KAMERA AUTO-CAPTURE (Gaya Kawaii Polaroid Smart Viewfinder):
/// - Kamera berjalan otomatis memeriksa setiap frame untuk mendeteksi WAJAH & PLAT.
/// - Tidak ada tombol foto manual: saat wajah & plat sama-sama terlihat, kamera
///   langsung memotret & mencocokkan data Masuk / Keluar otomatis.
/// - Jika keluar berbeda wajah atau plat hingga 3x deteksi, alarm berbunyi.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final _api = ApiService();
  final _store = ParkingStore.instance;

  CameraController? _cam;
  String? _camError;

  Timer? _autoTimer;
  bool _autoScanEnabled = true;
  bool _checkingFrame = false;
  bool _busy = false;
  bool _serverError = false;
  DateTime _cooldownUntil = DateTime.fromMillisecondsSinceEpoch(0);

  List<BoundingBox> _liveBoxes = const [];
  bool _faceDetected = false;
  bool _plateDetected = false;
  String? _plateCandidate;
  String _liveMessage = 'Arahkan wajah & plat motor ke bingkai manis ini ya~';

  ParkingRecord? _mismatchBanner;
  int _mismatchAttempt = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _syncDashboard();
    _autoTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) => _autoTick());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    _cam?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _cam;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      c.dispose();
      if (mounted) setState(() => _cam = null);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _syncDashboard() async {
    final dash = await _api.fetchDashboard();
    if (dash != null && mounted) _store.syncFromDashboard(dash);
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _camError = 'Kamera tidak ditemukan.\nCoba pakai tombol galeri di atas ya!');
        return;
      }
      final cam = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final c = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await c.initialize();
      try {
        await c.setFlashMode(FlashMode.off);
      } catch (_) {}
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() {
        _cam = c;
        _camError = null;
      });
    } catch (_) {
      if (mounted) setState(() => _camError = 'Kamera belum bisa dibuka.\nCek izin kamera di setelan HP yuk!');
    }
  }

  Future<void> _autoTick() async {
    if (!mounted) return;
    if (!_autoScanEnabled || _busy || _checkingFrame) return;
    if (!_store.scannerTabActive) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    if (DateTime.now().isBefore(_cooldownUntil)) return;

    final c = _cam;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;

    _checkingFrame = true;
    File? frameFile;
    try {
      final x = await c.takePicture();
      frameFile = File(x.path);

      if (kUseMockScan) {
        await _processCaptured(frameFile);
        frameFile = null;
        return;
      }

      final det = await _api.detectFrame(frameFile.path);
      if (!mounted) return;

      if (det == null) {
        setState(() {
          _serverError = true;
          _faceDetected = false;
          _plateDetected = false;
          _plateCandidate = null;
          _liveBoxes = const [];
        });
        return;
      }

      setState(() {
        _serverError = false;
        _liveBoxes = det.boxes;
        _faceDetected = det.faceDetected;
        _plateDetected = det.plateDetected;
        _plateCandidate = det.plateCandidate;
        _liveMessage = det.message;
      });

      if (det.readyToCapture) {
        final captured = frameFile;
        frameFile = null;
        await _processCaptured(captured);
      }
    } catch (_) {
      // Abaikan frame error sesaat; loop akan lanjut di tick berikutnya
    } finally {
      if (frameFile != null) {
        try {
          if (await frameFile.exists()) await frameFile.delete();
        } catch (_) {}
      }
      _checkingFrame = false;
    }
  }

  Future<void> _pickGallery() async {
    if (_busy) return;
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) await _processCaptured(File(x.path));
  }

  Future<Size?> _readSize(File f) async {
    try {
      final img = await decodeImageFromList(await f.readAsBytes());
      return Size(img.width.toDouble(), img.height.toDouble());
    } catch (_) {
      return null;
    }
  }

  Future<void> _processCaptured(File image) async {
    setState(() {
      _busy = true;
      _serverError = false;
    });

    final size = await _readSize(image);
    final rec = kUseMockScan ? await MockScanService.scan(image.path) : await _api.scanFrame(image.path, 'AUTO');
    if (!mounted) return;

    if (rec == null) {
      setState(() {
        _busy = false;
        _serverError = true;
      });
      _cooldownUntil = DateTime.now().add(const Duration(seconds: 2));
      return;
    }

    if (rec.totalMasuk != null && rec.totalKeluar != null) {
      _store.syncFromDashboard({
        'total_masuk': rec.totalMasuk,
        'total_keluar': rec.totalKeluar,
      });
    }

    final phase = rec.phase;
    setState(() {
      _busy = false;
      _liveBoxes = rec.boxes;
    });

    switch (phase) {
      case ScanPhase.success:
        setState(() {
          _mismatchBanner = null;
          _mismatchAttempt = 0;
        });
        final entry = rec.isEntryResult;
        final session = entry
            ? _store.recordEntry(
                plate: rec.plateNumber,
                time: rec.time,
                ticketCode: rec.ticketCode,
                imagePath: image.path,
                boxes: rec.boxes,
                size: size,
                plateScore: rec.plateScore,
                serverTotalMasuk: rec.totalMasuk,
                serverTotalKeluar: rec.totalKeluar,
              )
            : _store.recordExit(
                plate: rec.plateNumber,
                time: rec.time,
                ticketCode: rec.ticketCode,
                imagePath: image.path,
                boxes: rec.boxes,
                size: size,
                plateScore: rec.plateScore,
                faceMatch: rec.faceScore,
                serverTotalMasuk: rec.totalMasuk,
                serverTotalKeluar: rec.totalKeluar,
              );
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ScanSuccessScreen(
            record: rec,
            session: session,
            imagePath: image.path,
            imageSize: size,
            isEntry: entry,
          ),
        ));
        _cooldownUntil = DateTime.now().add(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _liveBoxes = const [];
            _faceDetected = false;
            _plateDetected = false;
            _plateCandidate = null;
          });
        }
        break;

      case ScanPhase.mismatchRetry:
        await AlarmSoundService.instance.playWarningBeep();
        setState(() {
          _mismatchBanner = rec;
          _mismatchAttempt = rec.attempt;
        });
        _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 2200));
        break;

      case ScanPhase.alarm:
        setState(() {
          _mismatchBanner = null;
          _mismatchAttempt = 0;
        });
        final regPlate = rec.registeredPlate ?? rec.plateNumber;
        final registered = _store.findActive(regPlate);
        _store.recordRejected(
          plate: regPlate,
          detectedPlate: rec.plateNumber,
          mismatchType: rec.mismatchType,
          time: rec.time,
          ticketCode: rec.ticketCode,
          imagePath: image.path,
          boxes: rec.boxes,
          size: size,
          plateScore: rec.plateScore,
          faceMatch: rec.faceScore,
          note: rec.message.isNotEmpty ? rec.message : 'Alarm 3x verifikasi berbeda',
          serverTotalMasuk: rec.totalMasuk,
          serverTotalKeluar: rec.totalKeluar,
        );
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AlarmScreen(
            record: rec,
            registered: registered,
            imagePath: image.path,
            imageSize: size,
          ),
        ));
        _cooldownUntil = DateTime.now().add(const Duration(seconds: 3));
        break;

      case ScanPhase.manual:
      case ScanPhase.retrying:
        setState(() {
          if (rec.message.isNotEmpty) _liveMessage = rec.message;
        });
        _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1500));
        break;
    }
  }

  Future<void> _resetMismatch() async {
    await _api.resetMismatch();
    if (!mounted) return;
    setState(() {
      _mismatchBanner = null;
      _mismatchAttempt = 0;
    });
  }

  Future<void> _showServerDialog() async {
    final ctrl = TextEditingController(text: AppConstants.baseUrl);
    String? testMsg;
    bool testing = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(children: [
            const KawaiiSparkle(size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Alamat Server AI', style: AppTheme.heading(size: 19, color: AppColors.textDark)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Pastikan HP dan laptop satu WiFi ya. Isi IP laptop dan port FastAPI di bawah:',
              style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: AppTheme.mono(size: 13, color: AppColors.textDark),
              decoration: const InputDecoration(hintText: 'http://192.168.1.155:8001'),
            ),
            if (testMsg != null) ...[
              const SizedBox(height: 10),
              Pill(
                testMsg!,
                bg: testMsg!.startsWith('Yeay') ? AppColors.successBg : AppColors.dangerBg,
                fg: testMsg!.startsWith('Yeay') ? AppColors.success : AppColors.danger,
                borderColor: testMsg!.startsWith('Yeay') ? AppColors.successBorder : AppColors.dangerBorder,
              ),
            ],
          ]),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(children: [
              Expanded(
                child: SquishyButton(
                  label: testing ? 'Mengecek...' : 'Tes Koneksi',
                  variant: SquishyVariant.secondary,
                  compact: true,
                  onPressed: testing
                      ? null
                      : () async {
                          setDlgState(() {
                            testing = true;
                            testMsg = null;
                          });
                          AppConstants.setBaseUrl(ctrl.text);
                          final ok = await _api.checkHealth();
                          if (ok) await _syncDashboard();
                          setDlgState(() {
                            testing = false;
                            testMsg = ok
                                ? 'Yeay! Terhubung ke server'
                                : 'Ups, belum nyambung ke ${AppConstants.baseUrl}';
                          });
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SquishyButton(
                  label: 'Simpan ✨',
                  variant: SquishyVariant.primary,
                  compact: true,
                  onPressed: () {
                    AppConstants.setBaseUrl(ctrl.text);
                    Navigator.pop(ctx);
                    _syncDashboard();
                    setState(() => _serverError = false);
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMismatch = _mismatchBanner != null;
    final bothReady = _faceDetected && _plateDetected;

    return Scaffold(
      body: KawaiiBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(children: [
              // Bar atas: Galeri | Pill Auto-Capture | Setting Server
              Row(children: [
                _iconCircleBtn(
                  icon: Icons.photo_library_outlined,
                  tooltip: 'Uji foto dari galeri',
                  onTap: _busy ? null : _pickGallery,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 2), blurRadius: 0)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.circle,
                      size: 9,
                      color: _serverError
                          ? AppColors.danger
                          : _autoScanEnabled
                              ? AppColors.success
                              : AppColors.warning,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _autoScanEnabled ? 'Auto-Capture Aktif' : 'Auto-Capture Jeda',
                      style: AppTheme.heading(size: 12.5, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 4),
                    const KawaiiSparkle(size: 13, color: AppColors.primary),
                  ]),
                ),
                const Spacer(),
                _iconCircleBtn(
                  icon: Icons.settings_rounded,
                  tooltip: 'Atur URL Server AI',
                  onTap: _showServerDialog,
                ),
              ]),
              const SizedBox(height: 10),

              // Indikator sensor Wajah & Plat (Bento asimetris kecil)
              Row(children: [
                Expanded(
                  flex: 10,
                  child: _sensorChip('Wajah', _faceDetected ? 'Terlihat!' : 'Mencari...', _faceDetected),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 11,
                  child: _sensorChip(
                    'Plat',
                    _plateDetected ? (_plateCandidate ?? 'Terbaca!') : 'Mencari...',
                    _plateDetected,
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Bingkai Kamera bergaya Kawaii Polaroid / Purikura
              Expanded(
                child: AppCard(
                  color: AppColors.elevated,
                  radius: 24,
                  padding: const EdgeInsets.all(10),
                  borderColor: hasMismatch ? AppColors.dangerBorder : AppColors.border,
                  shadowColor: hasMismatch ? AppColors.dangerBorder : AppColors.cardShadow,
                  shadowOffset: 5,
                  child: Stack(fit: StackFit.expand, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(fit: StackFit.expand, children: [
                        CameraView(controller: _cam, error: _camError),
                        if (_liveBoxes.isNotEmpty) BBoxPointer(boxes: _liveBoxes),
                        CustomPaint(
                          painter: BracketPainter(
                            color: hasMismatch
                                ? AppColors.danger
                                : bothReady
                                    ? AppColors.successBorder
                                    : AppColors.elevated.withValues(alpha: .88),
                            inset: 24,
                            len: 28,
                          ),
                        ),
                        if (_busy)
                          Container(
                            color: AppColors.cameraBg.withValues(alpha: .82),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 14),
                              Text(
                                'Sebentar ya, lagi mencocokkan wajah & plat...',
                                textAlign: TextAlign.center,
                                style: AppTheme.heading(size: 15, color: Colors.white),
                              ),
                            ]),
                          ),
                      ]),
                    ),
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: StickerTag('Cam Pos 01 ✦', angle: -0.05),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // Banner status / Peringatan Mismatch 1-2x / Error server
              if (_serverError)
                const ScannerStatusBanner(
                  phase: null,
                  isEntry: true,
                  attempt: 1,
                  maxAttempt: 3,
                  message: '',
                  serverError: true,
                )
              else if (hasMismatch)
                ScannerStatusBanner(
                  phase: ScanPhase.mismatchRetry,
                  isEntry: false,
                  attempt: _mismatchBanner!.attempt,
                  maxAttempt: _mismatchBanner!.maxAttempt,
                  title: 'Ups! Deteksi ${_mismatchBanner!.attempt}/${_mismatchBanner!.maxAttempt} Tidak Cocok',
                  message: _mismatchBanner!.message,
                  serverError: false,
                )
              else
                AppCard(
                  color: bothReady ? AppColors.successBg : AppColors.card,
                  borderColor: bothReady ? AppColors.successBorder : AppColors.border,
                  shadowColor: bothReady ? AppColors.successBorder : AppColors.cardShadow,
                  radius: 18,
                  shadowOffset: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    Icon(
                      bothReady ? Icons.camera_enhance_rounded : Icons.center_focus_weak_rounded,
                      size: 18,
                      color: bothReady ? AppColors.success : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _liveMessage,
                        style: AppTheme.body(
                          size: 12,
                          w: FontWeight.w600,
                          color: bothReady ? AppColors.success : AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 10),

              // Tombol kontrol auto-scan squishy (tanpa tombol foto manual)
              Row(children: [
                Expanded(
                  child: SquishyButton(
                    label: _autoScanEnabled ? 'Jeda Auto-Scan' : 'Lanjut Auto-Scan',
                    icon: _autoScanEnabled ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    variant: _autoScanEnabled ? SquishyVariant.secondary : SquishyVariant.primary,
                    compact: true,
                    onPressed: () => setState(() => _autoScanEnabled = !_autoScanEnabled),
                  ),
                ),
                if (_mismatchAttempt > 0) ...[
                  const SizedBox(width: 10),
                  SquishyButton(
                    label: 'Reset ($_mismatchAttempt/3)',
                    icon: Icons.refresh_rounded,
                    variant: SquishyVariant.danger,
                    fullWidth: false,
                    compact: true,
                    onPressed: _resetMismatch,
                  ),
                ],
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _iconCircleBtn({required IconData icon, required String tooltip, required VoidCallback? onTap}) {
    return SquishyTap(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 3), blurRadius: 0)],
          ),
          child: Icon(icon, size: 20, color: onTap == null ? AppColors.textMuted : AppColors.primaryDark),
        ),
      ),
    );
  }

  Widget _sensorChip(String label, String value, bool ok) => AnimatedContainer(
        duration: AppTheme.bouncyDuration,
        curve: AppTheme.bouncyCurve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ok ? AppColors.successBg : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ok ? AppColors.successBorder : AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: ok ? AppColors.successBorder : AppColors.cardShadow,
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.search_rounded,
            size: 15,
            color: ok ? AppColors.success : AppColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $value',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: ok ? AppColors.success : AppColors.textDark,
              ),
            ),
          ),
        ]),
      );
}
