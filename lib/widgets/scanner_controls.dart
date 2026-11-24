import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'app_card.dart';

class ParkingHeaderCard extends StatelessWidget {
  final int terisi;
  final int kapasitas;
  const ParkingHeaderCard({super.key, required this.terisi, required this.kapasitas});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: const Text('P', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Parkir Gedung A', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text('Terisi $terisi/$kapasitas Motor • Sisa ${kapasitas - terisi}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
        const Pill('Online', bg: AppColors.successBg, fg: AppColors.success, icon: Icons.circle),
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
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
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
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 17, color: active ? Colors.white : AppColors.primaryDark),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: active ? Colors.white : AppColors.primaryDark)),
          ]),
        ),
      ),
    );
  }
}
