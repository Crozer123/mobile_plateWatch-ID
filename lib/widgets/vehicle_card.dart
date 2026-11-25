import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'app_card.dart';

/// Kartu sepeda yang sedang berada di dalam area pengecekan.
class VehicleCard extends StatelessWidget {
  final ParkingSession session;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now().difference(session.entryTime);
    return SquishyTap(
      onTap: onTap,
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: const Icon(Icons.two_wheeler_rounded, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(session.plate, style: AppTheme.mono(size: 16, w: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 12.5, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Masuk ${ParkingStore.hm(session.entryTime)}',
                    style: AppTheme.body(size: 11.5, color: AppColors.textMuted, height: 1.2)),
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Pill(
              ParkingStore.durationText(d),
              bg: AppColors.butter,
              fg: AppColors.butterInk,
              borderColor: AppColors.butterShadow,
            ),
            const SizedBox(height: 4),
            Text('Di dalam', style: AppTheme.sticker(size: 12, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }
}
