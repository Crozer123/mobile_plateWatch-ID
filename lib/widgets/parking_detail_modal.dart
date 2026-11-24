import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import 'result_cards.dart';

/// Detail singkat kendaraan yang sedang parkir (dari tab Parkir Aktif).
Future<void> showParkingDetailModal(BuildContext context, ParkingSession s) {
  final d = DateTime.now().difference(s.entryTime);
  Widget row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ]),
      );

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 44, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 16),
        PlateBox(s.plate),
        const SizedBox(height: 10),
        row('ID Sesi', '#${s.id}'),
        row('Waktu masuk', ParkingStore.hm(s.entryTime)),
        row('Durasi berjalan', ParkingStore.durationText(d)),
        row('Estimasi tarif', ParkingStore.tariffFor(d)),
        row('Lokasi', s.slotLabel),
        row('Metode masuk', s.manual ? 'Manual (petugas)' : 'Otomatis'),
      ]),
    ),
  );
}
