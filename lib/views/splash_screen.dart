import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/kawaii_decorations.dart';
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
    'Menyiapkan mata kamera...',
    'Menyapa server AI...',
    'Membuka buku catatan plat...',
    'Siap berjaga!',
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
      body: KawaiiBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              child: Column(children: [
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Pill(
                    'Siap Berjaga',
                    bg: AppColors.successBg,
                    fg: AppColors.success,
                    borderColor: AppColors.successBorder,
                    icon: Icons.circle,
                  ),
                  StickerTag('Pos Gerbang 01'),
                ]),
                const Spacer(),
                _logo(),
                const SizedBox(height: 24),
                Text('PlateWatch-ID', style: AppTheme.heading(size: 32, color: AppColors.primaryDark)),
                const SizedBox(height: 8),
                Text(
                  'Jaga motor masuk & keluar\ndengan cek wajah dan plat otomatis',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(size: 14, color: AppColors.textMuted, height: 1.65),
                ),
                const SizedBox(height: 18),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Pill(
                    'Auto-Capture',
                    bg: AppColors.peach,
                    fg: AppColors.peachInk,
                    borderColor: AppColors.peachShadow,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  SizedBox(width: 10),
                  Pill(
                    'Cek Wajah',
                    bg: AppColors.butter,
                    fg: AppColors.butterInk,
                    borderColor: AppColors.butterShadow,
                    icon: Icons.face_retouching_natural,
                  ),
                ]),
                const Spacer(),
                AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) {
                    final i = math.min((_progress.value * _steps.length).floor(), _steps.length - 1);
                    final pct = Curves.easeInOut.transform(_progress.value);
                    return AppCard(
                      color: AppColors.elevated,
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Container(
                          height: 12,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: pct.clamp(0.06, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const KawaiiSparkle(size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(_steps[i], style: AppTheme.body(size: 12.5, w: FontWeight.w600, color: AppColors.textDark)),
                        ]),
                        const SizedBox(height: 4),
                        Text('v2.0 • Strawberry Milk Edition', style: AppTheme.sticker(size: 12.5, color: AppColors.textMuted)),
                      ]),
                    );
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
      width: 196,
      height: 196,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final t = _pulse.value;
          return Stack(alignment: Alignment.center, children: [
            for (final delay in [0.0, .5])
              Builder(builder: (_) {
                final v = (t + delay) % 1;
                return Opacity(
                  opacity: (1 - v) * .55,
                  child: Container(
                    width: 118 + 74 * v,
                    height: 118 + 74 * v,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34 + 18 * v),
                      border: Border.all(color: AppColors.border, width: 2.5),
                    ),
                  ),
                );
              }),
            Container(
              width: 116,
              height: 116,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primaryShadow, width: 2.5),
                boxShadow: const [BoxShadow(color: AppColors.primaryShadow, offset: Offset(0, 6), blurRadius: 0)],
              ),
              child: Stack(children: [
                const Center(child: Icon(Icons.two_wheeler_rounded, size: 54, color: Colors.white)),
                Positioned(
                  top: 116 * (0.5 + 0.42 * math.sin(t * 2 * math.pi)) - 2,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.butter.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const Positioned(right: 10, bottom: 10, child: Icon(Icons.videocam_rounded, size: 17, color: Colors.white)),
              ]),
            ),
            const Positioned(top: 22, right: 26, child: KawaiiSparkle(size: 22, color: AppColors.primaryDark)),
            const Positioned(bottom: 24, left: 26, child: KawaiiBow(size: 28, color: AppColors.primaryDark)),
          ]);
        },
      ),
    );
  }
}
