import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../core/scan_status.dart';
import 'app_card.dart';

/// Banner status di bawah kamera: verifikasi cocok / mismatch retry (1-2x) / error server.
class ScannerStatusBanner extends StatelessWidget {
  final ScanPhase? phase;
  final bool isEntry;
  final int attempt;
  final int maxAttempt;
  final String message;
  final String title;
  final bool serverError;
  const ScannerStatusBanner({
    super.key,
    required this.phase,
    required this.isEntry,
    required this.attempt,
    required this.maxAttempt,
    required this.message,
    required this.serverError,
    this.title = 'Ups, belum cocok nih!',
  });

  @override
  Widget build(BuildContext context) {
    if (serverError) return const _ServerErrorBanner();
    switch (phase) {
      case ScanPhase.success:
        return _VerifiedBanner(
          title: isEntry ? 'Yeay! Motor masuk tercatat rapi' : 'Yeay! Wajah & plat cocok',
          subtitle: isEntry ? 'Foto wajah dan plat sudah disimpan aman.' : 'Data cocok dengan catatan masuk, silakan jalan.',
        );
      case ScanPhase.mismatchRetry:
        return Column(children: [
          _MismatchWarningBanner(title: title, message: message),
          const SizedBox(height: 10),
          _RetryBanner(attempt: attempt, max: maxAttempt),
        ]);
      case ScanPhase.retrying:
        return _MismatchWarningBanner(title: title, message: message);
      case ScanPhase.manual:
      case ScanPhase.alarm:
      case null:
        return const SizedBox.shrink();
    }
  }
}

class _VerifiedBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _VerifiedBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.successBg,
        borderColor: AppColors.successBorder,
        shadowColor: AppColors.successBorder,
        radius: 20,
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTheme.heading(size: 14.5, color: AppColors.success)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTheme.body(size: 12, color: AppColors.success, height: 1.4)),
            ]),
          ),
        ]),
      );
}

class _MismatchWarningBanner extends StatelessWidget {
  final String title;
  final String message;
  const _MismatchWarningBanner({required this.title, required this.message});
  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.warningBg,
        borderColor: AppColors.warningBorder,
        shadowColor: AppColors.warningBorder,
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 19),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: AppTheme.heading(size: 14, color: AppColors.warning))),
          ]),
          const SizedBox(height: 5),
          Text(
            '$message Cek lagi yuk — kalau sampai 3x berbeda, alarm bakal berbunyi.',
            style: AppTheme.body(size: 12, color: AppColors.warning, height: 1.45),
          ),
        ]),
      );
}

class _RetryBanner extends StatelessWidget {
  final int attempt;
  final int max;
  const _RetryBanner({required this.attempt, required this.max});
  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.elevated,
        borderColor: AppColors.dangerBorder,
        shadowColor: AppColors.dangerBorder,
        radius: 18,
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            for (var i = 1; i <= max; i++)
              Container(
                margin: const EdgeInsets.only(right: 5),
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= attempt ? AppColors.danger : AppColors.card,
                  border: Border.all(color: AppColors.dangerBorder, width: 1.5),
                ),
              ),
            const SizedBox(width: 6),
            Text('Cek Ulang $attempt/$max', style: AppTheme.heading(size: 13, color: AppColors.danger)),
            const Spacer(),
            const Pill('Auto-Scan', bg: AppColors.dangerBg, fg: AppColors.danger, borderColor: AppColors.dangerBorder, icon: Icons.sync_rounded),
          ]),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            key: ValueKey(attempt),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 2200),
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: AppColors.dangerBg,
                color: AppColors.danger,
              ),
            ),
          ),
        ]),
      );
}

class _ServerErrorBanner extends StatelessWidget {
  const _ServerErrorBanner();
  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.dangerBg,
        borderColor: AppColors.dangerBorder,
        shadowColor: AppColors.dangerBorder,
        radius: 20,
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ups, server AI (${AppConstants.baseUrl}) belum nyambung nih. Cek apakah FastAPI menyala dan WiFi sama ya!',
              style: AppTheme.body(size: 12, color: AppColors.danger, height: 1.45),
            ),
          ),
        ]),
      );
}
