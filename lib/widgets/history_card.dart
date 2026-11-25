import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'app_card.dart';
import 'result_cards.dart';

/// Kartu satu baris riwayat (cocok / alarm).
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

    return SquishyTap(
      onTap: onTap,
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.all(14),
        borderColor: rejected ? AppColors.dangerBorder : AppColors.border,
        shadowColor: rejected ? AppColors.dangerBorder : AppColors.cardShadow,
        child: Column(children: [
          Row(children: [
            PlateChip(s.plate),
            const SizedBox(width: 8),
            if (d != null)
              Text(ParkingStore.durationShort(d), style: AppTheme.body(size: 12, color: AppColors.textMuted, height: 1.2)),
            const Spacer(),
            rejected
                ? const Pill('Alarm', bg: AppColors.dangerBg, fg: AppColors.danger, borderColor: AppColors.dangerBorder, icon: Icons.notifications_active_rounded)
                : const Pill('Cocok', bg: AppColors.successBg, fg: AppColors.success, borderColor: AppColors.successBorder, icon: Icons.check_circle_outline_rounded),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 14, color: rejected ? AppColors.danger : AppColors.textMuted),
            const SizedBox(width: 5),
            Expanded(
              child: Text('Masuk $entry • Keluar $exit',
                  style: AppTheme.body(size: 12, color: AppColors.textMuted, height: 1.2)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark),
          ]),
          if (s.note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: s.noteIsError ? AppColors.dangerBg : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: s.noteIsError ? AppColors.dangerBorder : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(children: [
                Icon(
                  s.noteIsError ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  size: 15,
                  color: s.noteIsError ? AppColors.danger : AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.note!,
                    style: AppTheme.body(
                      size: 11.5,
                      color: s.noteIsError ? AppColors.danger : AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
