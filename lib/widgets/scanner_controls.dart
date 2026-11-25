import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import 'app_card.dart';

class ParkingHeaderCard extends StatelessWidget {
  final int totalMasuk;
  final int totalKeluar;
  const ParkingHeaderCard({super.key, required this.totalMasuk, required this.totalKeluar});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.elevated,
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.two_wheeler_rounded, size: 22, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pantauan Gerbang Sepeda', style: AppTheme.heading(size: 15, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text('Masuk: $totalMasuk Sepeda • Keluar: $totalKeluar Sepeda',
                style: AppTheme.body(size: 12, color: AppColors.textMuted, height: 1.3)),
          ]),
        ),
        const Pill('Auto', bg: AppColors.successBg, fg: AppColors.success, borderColor: AppColors.successBorder, icon: Icons.circle),
      ]),
    );
  }
}

class ModeToggle extends StatelessWidget {
  final bool isEntry;
  final ValueChanged<bool> onChanged;
  const ModeToggle({super.key, required this.isEntry, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Row(children: [
        _item(true, Icons.login_rounded, 'Masuk'),
        _item(false, Icons.logout_rounded, 'Keluar'),
      ]),
    );
  }

  Widget _item(bool entry, IconData icon, String label) {
    final active = isEntry == entry;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(entry),
        child: AnimatedContainer(
          duration: AppTheme.bouncyDuration,
          curve: AppTheme.bouncyCurve,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 17, color: active ? Colors.white : AppColors.textDark),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: active ? Colors.white : AppColors.textDark)),
          ]),
        ),
      ),
    );
  }
}
