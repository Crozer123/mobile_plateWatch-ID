import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import 'app_card.dart';

class PlateBox extends StatelessWidget {
  final String plate;
  const PlateBox(this.plate, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 3), blurRadius: 0)],
        ),
        child: Center(child: Text(plate, style: AppTheme.mono(size: 26, w: FontWeight.w800, color: AppColors.textDark, spacing: 2))),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Icon(icon, size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: AppTheme.body(size: 11, color: AppColors.textMuted, height: 1.2))),
          ]),
          const SizedBox(height: 5),
          Text(value, overflow: TextOverflow.ellipsis, style: AppTheme.body(size: 13.5, w: FontWeight.w700, color: AppColors.textDark, height: 1.2)),
        ]),
      );
}

/// Kartu hasil saat MASUK.
class EntryResultCard extends StatelessWidget {
  final String plate;
  final String entryTime;
  const EntryResultCard({super.key, required this.plate, required this.entryTime});
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.two_wheeler_rounded, size: 18, color: AppColors.primaryDark),
            const SizedBox(width: 6),
            Text('Catatan Motor Masuk', style: AppTheme.heading(size: 14.5, color: AppColors.textDark)),
            const Spacer(),
            const Pill('Tersimpan ✨', bg: AppColors.successBg, fg: AppColors.success, borderColor: AppColors.successBorder),
          ]),
          const SizedBox(height: 12),
          PlateBox(plate),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _InfoTile(Icons.schedule_rounded, 'Waktu Masuk', entryTime)),
            const SizedBox(width: 10),
            const Expanded(child: _InfoTile(Icons.verified_user_outlined, 'Status Cek', 'Wajah & Plat Disimpan')),
          ]),
        ]),
      );
}

/// Kartu hasil saat KELUAR (hanya pengecekan kecocokan wajah & plat, tanpa tarif).
class ExitResultCard extends StatelessWidget {
  final String plate;
  final String entryTime;
  final String exitTime;
  final String duration;
  const ExitResultCard({
    super.key,
    required this.plate,
    required this.entryTime,
    required this.exitTime,
    required this.duration,
  });
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(children: [
          Row(children: [
            const Icon(Icons.two_wheeler_rounded, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(plate, style: AppTheme.mono(size: 22, w: FontWeight.w800, color: AppColors.textDark)),
            const Spacer(),
            const Pill('Cocok ✨', bg: AppColors.successBg, fg: AppColors.success, borderColor: AppColors.successBorder, icon: Icons.circle),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.25,
            children: [
              _InfoTile(Icons.login_rounded, 'Waktu Masuk', entryTime),
              _InfoTile(Icons.logout_rounded, 'Waktu Keluar', exitTime),
              _InfoTile(Icons.timer_outlined, 'Durasi di Dalam', duration),
              const _InfoTile(Icons.verified_rounded, 'Status Cek', 'Wajah & Plat Cocok'),
            ],
          ),
        ]),
      );
}

/// Plat kecil bergaya chip stiker.
class PlateChip extends StatelessWidget {
  final String plate;
  final double size;
  const PlateChip(this.plate, {super.key, this.size = 13});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(plate, style: AppTheme.mono(size: size, w: FontWeight.w800, color: AppColors.textDark)),
      );
}
