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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(child: Text(plate, style: AppTheme.mono(size: 26, w: FontWeight.w800, spacing: 2))),
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
        decoration: BoxDecoration(color: AppColors.card.withOpacity(.6), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
          ]),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
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
          const Row(children: [
            Icon(Icons.two_wheeler_rounded, size: 18, color: AppColors.primary),
            SizedBox(width: 6),
            Text('HASIL PEMBACAAN OCR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            Spacer(),
            Pill('Sesi dibuat', bg: AppColors.card, fg: AppColors.primaryDark),
          ]),
          const SizedBox(height: 12),
          PlateBox(plate),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _InfoTile(Icons.schedule_rounded, 'Waktu Masuk', entryTime)),
            const SizedBox(width: 10),
            const Expanded(child: _InfoTile(Icons.meeting_room_outlined, 'Kanal Palang', 'Gate 01 In')),
          ]),
        ]),
      );
}

/// Kartu hasil saat KELUAR.
class ExitResultCard extends StatelessWidget {
  final String plate;
  final String entryTime;
  final String exitTime;
  final String duration;
  final String tariff;
  const ExitResultCard({
    super.key,
    required this.plate,
    required this.entryTime,
    required this.exitTime,
    required this.duration,
    required this.tariff,
  });
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(children: [
          Row(children: [
            const Icon(Icons.two_wheeler_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(plate, style: AppTheme.mono(size: 22, w: FontWeight.w800)),
            const Spacer(),
            const Pill('Valid', bg: AppColors.successBg, fg: AppColors.success, icon: Icons.circle),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
            children: [
              _InfoTile(Icons.login_rounded, 'Waktu Masuk', entryTime),
              _InfoTile(Icons.logout_rounded, 'Waktu Keluar', exitTime),
              _InfoTile(Icons.timer_outlined, 'Durasi Parkir', duration),
              _InfoTile(Icons.payments_outlined, 'Tarif Parkir', tariff),
            ],
          ),
        ]),
      );
}

/// Plat kecil bergaya chip (untuk daftar & riwayat).
class PlateChip extends StatelessWidget {
  final String plate;
  final double size;
  const PlateChip(this.plate, {super.key, this.size = 13});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(.35)),
        ),
        child: Text(plate, style: AppTheme.mono(size: size, w: FontWeight.w800)),
      );
}
