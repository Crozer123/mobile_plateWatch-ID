import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'app_card.dart';

/// Kartu kendaraan di tab Parkir Aktif.
class VehicleCard extends StatelessWidget {
  final ParkingSession session;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now().difference(session.entryTime);
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          const CircleAvatar(radius: 20, backgroundColor: AppColors.pink, child: Icon(Icons.two_wheeler_rounded, color: AppColors.pinkDark, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(session.plate, style: AppTheme.mono(size: 16, w: FontWeight.w800)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Masuk ${ParkingStore.hm(session.entryTime)}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Pill(ParkingStore.durationText(d), bg: AppColors.card, fg: AppColors.primaryDark),
            const SizedBox(height: 4),
            Text(session.slotLabel, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }
}
