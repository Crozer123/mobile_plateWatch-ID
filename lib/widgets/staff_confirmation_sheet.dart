import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'app_card.dart';

/// Kartu konfirmasi petugas (muncul setelah gagal verifikasi 3x).
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
              decoration: BoxDecoration(shape: BoxShape.circle, color: i < failed ? AppColors.danger : AppColors.border),
            ),
          const SizedBox(width: 6),
          Text('$failed dari $maxAttempt gagal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const Spacer(),
          const Text('Batas scan otomatis habis', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Text('VERIFIKASI MANUAL PETUGAS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: .5)),
            Spacer(),
            Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.primary),
          ]),
          const SizedBox(height: 10),
          Text.rich(TextSpan(children: [
            TextSpan(text: isEntry ? 'Buka portal masuk untuk ' : 'Buka portal keluar untuk '),
            TextSpan(text: '$plate?', style: const TextStyle(color: AppColors.primary)),
          ]), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.3)),
          const SizedBox(height: 8),
          Text('Pindai otomatis wajah gagal $maxAttempt kali. Petugas dapat memeriksa fisik pengendara sebelum membuka portal.',
              style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onKeep,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Tetap tutup'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD6E3),
                  foregroundColor: AppColors.pinkDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: const Text('Buka portal'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        child: const Row(children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primaryDark),
          SizedBox(width: 10),
          Expanded(
            child: Text('Portal tertutup, menunggu konfirmasi petugas',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
          ),
        ]),
      ),
    ]);
  }
}
