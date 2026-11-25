import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'app_card.dart';
import 'kawaii_decorations.dart';
import 'result_cards.dart';

/// Detail singkat sepeda motor yang sedang berada di dalam (dari tab Dashboard).
Future<void> showParkingDetailModal(BuildContext context, ParkingSession s) {
  final d = DateTime.now().difference(s.entryTime);
  Widget row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: AppTheme.body(size: 13, color: AppColors.textMuted, height: 1.3)),
          Text(v, style: AppTheme.body(size: 13.5, w: FontWeight.w700, color: AppColors.textDark, height: 1.3)),
        ]),
      );

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      side: BorderSide(color: AppColors.border, width: 2),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 48, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999))),
        const SizedBox(height: 14),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          StickerTag('Catatan Kendaraan ✦'),
          Pill('Sedang di Dalam', bg: AppColors.successBg, fg: AppColors.success, borderColor: AppColors.successBorder),
        ]),
        const SizedBox(height: 12),
        PlateBox(s.plate),
        const SizedBox(height: 12),
        AppCard(
          color: AppColors.elevated,
          radius: 18,
          shadowOffset: 3,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(children: [
            row('Kode Sesi', '#${s.id}'),
            row('Waktu Masuk', ParkingStore.hm(s.entryTime)),
            row('Durasi di Dalam', ParkingStore.durationText(d)),
            row('Status', 'Terdaftar & Terpantau'),
          ]),
        ),
      ]),
    ),
  );
}
