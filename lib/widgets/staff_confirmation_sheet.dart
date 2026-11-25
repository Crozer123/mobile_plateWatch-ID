import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import 'app_card.dart';

/// Kartu konfirmasi petugas bergaya Kawaii Tactile.
class StaffConfirmationSheet extends StatelessWidget {
  final String plate;
  final int failed;
  final int maxAttempt;
  final bool isEntry;
  final VoidCallback onOpen;
  final VoidCallback onKeep;
  const StaffConfirmationSheet({
    super.key,
    required this.plate,
    required this.failed,
    required this.maxAttempt,
    required this.isEntry,
    required this.onOpen,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          for (var i = 0; i < maxAttempt; i++)
            Container(
              margin: const EdgeInsets.only(right: 5),
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < failed ? AppColors.danger : AppColors.card,
                border: Border.all(color: AppColors.dangerBorder, width: 1.5),
              ),
            ),
          const SizedBox(width: 6),
          Text('$failed dari $maxAttempt belum terbaca', style: AppTheme.heading(size: 13.5, color: AppColors.textDark)),
          const Spacer(),
          Text('Cek manual yuk', style: AppTheme.body(size: 11, color: AppColors.textMuted, height: 1.2)),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Konfirmasi Petugas Jaga', style: AppTheme.heading(size: 13, color: AppColors.primaryDark)),
            const Spacer(),
            const Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.primaryDark),
          ]),
          const SizedBox(height: 10),
          Text.rich(TextSpan(children: [
            TextSpan(text: isEntry ? 'Izinkan masuk untuk ' : 'Izinkan keluar untuk '),
            TextSpan(text: '$plate?', style: const TextStyle(color: AppColors.primaryDark)),
          ]), style: AppTheme.heading(size: 20, color: AppColors.textDark, height: 1.3)),
          const SizedBox(height: 8),
          Text(
            'Kamera sudah mencoba $maxAttempt kali tapi belum terbaca jelas. Cek fisik pengendara dulu ya sebelum lanjut.',
            style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.55),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: SquishyButton(
                label: 'Tahan Dulu',
                icon: Icons.close_rounded,
                variant: SquishyVariant.secondary,
                compact: true,
                onPressed: onKeep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SquishyButton(
                label: 'Izinkan ✨',
                icon: Icons.check_rounded,
                variant: SquishyVariant.primary,
                compact: true,
                onPressed: onOpen,
              ),
            ),
          ]),
        ]),
      ),
    ]);
  }
}
