import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../widgets/app_card.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..forward();
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  static const _steps = [
    'Menyiapkan kamera...',
    'Menghubungkan ke server AI...',
    'Sinkronisasi basis data plat...',
    'Siap digunakan',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _progress.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE9F1), Color(0xFFEAF6FC), Color(0xFFD6EEFA)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Pill('SISTEM AKTIF', bg: Color(0xFFD6EEFA), fg: AppColors.primaryDark, icon: Icons.circle),
                  Text('POS 01', style: AppTheme.mono(size: 11, color: AppColors.textMuted)),
                ]),
                const Spacer(),
                _logo(),
                const SizedBox(height: 28),
                Text('PlateWatch-ID', style: AppTheme.mono(size: 30, w: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 10),
                const Text('Smart parking dengan deteksi wajah\ndan plat nomor',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMuted)),
                const SizedBox(height: 18),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Pill('OCR Plat', bg: Colors.white, fg: AppColors.primaryDark, icon: Icons.document_scanner_outlined),
                  SizedBox(width: 8),
                  Pill('Biometrik', bg: Colors.white, fg: AppColors.primaryDark, icon: Icons.face_retouching_natural),
                ]),
                const Spacer(),
                AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) {
                    final i = math.min((_progress.value * _steps.length).floor(), _steps.length - 1);
                    return Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: Curves.easeInOut.transform(_progress.value),
                          minHeight: 6,
                          backgroundColor: Colors.white,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                        const SizedBox(width: 8),
                        Text(_steps[i], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: 6),
                      Text('v1.0.0 • PlateWatch-ID',
                          style: AppTheme.mono(size: 10, w: FontWeight.w400, color: AppColors.textMuted.withOpacity(.7))),
                    ]);
                  },
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final t = _pulse.value;
          return Stack(alignment: Alignment.center, children: [
            for (final delay in [0.0, .5])
              Builder(builder: (_) {
                final v = (t + delay) % 1;
                return Opacity(
                  opacity: (1 - v) * .5,
                  child: Container(
                    width: 110 + 80 * v,
                    height: 110 + 80 * v,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36 + 20 * v),
                      border: Border.all(color: AppColors.pink, width: 2),
                    ),
                  ),
                );
              }),
            Container(
              width: 110,
              height: 110,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [BoxShadow(color: AppColors.pink.withOpacity(.7), blurRadius: 30, offset: const Offset(0, 12))],
              ),
              child: Stack(children: [
                const Center(child: Icon(Icons.two_wheeler_rounded, size: 52, color: Colors.white)),
                Positioned(
                  top: 110 * (0.5 + 0.5 * math.sin(t * 2 * math.pi)) - 2,
                  left: 0,
                  right: 0,
                  child: Container(height: 3, color: Colors.white.withOpacity(.85)),
                ),
                const Positioned(right: 10, bottom: 10, child: Icon(Icons.videocam_rounded, size: 16, color: Colors.white)),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}
