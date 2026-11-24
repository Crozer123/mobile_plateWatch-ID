import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'app_card.dart';
import 'result_cards.dart';

/// Kartu satu baris riwayat (selesai / ditolak).
class HistoryCard extends StatelessWidget {
  final ParkingSession session;
  final VoidCallback onTap;
  const HistoryCard({super.key, required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final rejected = s.status == SessionStatus.rejected;
    final d = s.duration;
    final entry = s.entryKnown ? ParkingStore.hhmm(s.entryTime) : '-';
    final exit = s.exitTime == null ? '-' : ParkingStore.hhmm(s.exitTime!);
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            PlateChip(s.plate),
            const SizedBox(width: 8),
            if (d != null) Text(ParkingStore.durationShort(d), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const Spacer(),
            rejected
                ? const Pill('Ditolak', bg: Color(0xFFFFE0E0), fg: AppColors.danger, icon: Icons.error_outline_rounded)
                : const Pill('Selesai', bg: AppColors.card, fg: AppColors.primaryDark, icon: Icons.check_circle_outline_rounded),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 14, color: rejected ? AppColors.danger : AppColors.textMuted),
            const SizedBox(width: 5),
            Expanded(child: Text('Masuk $entry • Keluar $exit', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ]),
          if (s.note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: s.noteIsError ? const Color(0xFFFFE0E0) : AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(s.noteIsError ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    size: 14, color: s.noteIsError ? AppColors.danger : AppColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(s.note!,
                      style: TextStyle(fontSize: 11.5, color: s.noteIsError ? AppColors.danger : AppColors.primaryDark)),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
