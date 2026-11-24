import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/scan_status.dart';
import 'app_card.dart';

/// Banner status di bawah kamera: portal terbuka / wajah tidak terdeteksi /
/// percobaan ulang / perlu penjaga / server error.
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
    this.title = 'Wajah tidak terdeteksi!',
  });

  @override
  Widget build(BuildContext context) {
    if (serverError) return const _ServerErrorBanner();
    switch (phase) {
      case ScanPhase.success:
        return _PortalOpenBanner(
          title: 'Portal terbuka otomatis',
          subtitle: isEntry ? 'Silakan masuk. Portal akan menutup dalam 4 detik.' : 'Verifikasi identik, selamat jalan!',
        );
      case ScanPhase.retrying:
        return Column(children: [
          _FaceWarningBanner(title: title, message: message),
          const SizedBox(height: 12),
          _RetryBanner(attempt: attempt, max: maxAttempt),
        ]);
      case ScanPhase.manual:
      case ScanPhase.alarm:
      case null:
        return const SizedBox.shrink();
    }
  }
}

class _PortalOpenBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PortalOpenBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.successBg,
        borderColor: AppColors.success.withOpacity(.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(radius: 20, backgroundColor: AppColors.success, child: Icon(Icons.check_rounded, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0E5C34))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF2F6F4B))),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: 0),
            duration: const Duration(seconds: 4),
            builder: (_, v, __) => Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: Colors.white, color: AppColors.success),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Auto-close dalam ${(v * 4).ceil()} dtk', style: const TextStyle(fontSize: 11, color: Color(0xFF2F6F4B))),
              ),
            ]),
          ),
        ]),
      );
}

class _FaceWarningBanner extends StatelessWidget {
  final String title;
  final String message;
  const _FaceWarningBanner({required this.title, required this.message});
  @override
  Widget build(BuildContext context) => AppCard(
        color: AppColors.warningBg,
        borderColor: AppColors.warning.withOpacity(.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF8A3F05))),
          ]),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF8A3F05))),
        ]),
      );
}

class _RetryBanner extends StatelessWidget {
  final int attempt;
  final int max;
  const _RetryBanner({required this.attempt, required this.max});
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(children: [
          Row(children: [
            for (var i = 1; i <= max; i++)
              Container(
                margin: const EdgeInsets.only(right: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: i <= attempt ? AppColors.warning : AppColors.border),
              ),
            const SizedBox(width: 6),
            Text('Percobaan $attempt dari $max', style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            const Pill('Mencoba lagi...', bg: AppColors.card, fg: AppColors.primaryDark, icon: Icons.sync_rounded),
          ]),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            key: ValueKey(attempt),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: AppColors.border, color: AppColors.warning),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Memindai ulang area wajah pengendara...', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ),
        ]),
      );
}

class _ServerErrorBanner extends StatelessWidget {
  const _ServerErrorBanner();
  @override
  Widget build(BuildContext context) => const AppCard(
        color: Color(0xFFFFF1F1),
        borderColor: AppColors.danger,
        child: Row(children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.danger),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tidak dapat terhubung ke server. Pastikan backend menyala dan alamat di AppConstants.scanEndpoint benar.',
              style: TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
        ]),
      );
}
