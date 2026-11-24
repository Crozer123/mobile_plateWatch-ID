import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/parking_detail_modal.dart';
import '../widgets/vehicle_card.dart';

class ActiveParkingScreen extends StatefulWidget {
  const ActiveParkingScreen({super.key});
  @override
  State<ActiveParkingScreen> createState() => _ActiveParkingScreenState();
}

class _ActiveParkingScreenState extends State<ActiveParkingScreen> {
  final _store = ParkingStore.instance;
  String _query = '';
  bool _newestFirst = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: _store,
        builder: (_, __) {
          var list = _store.active.where((s) => s.plate.replaceAll(' ', '').toUpperCase().contains(_query.replaceAll(' ', '').toUpperCase())).toList();
          list.sort((a, b) => _newestFirst ? b.entryTime.compareTo(a.entryTime) : a.entryTime.compareTo(b.entryTime));
          final total = _store.activeCount;
          final pct = total / ParkingStore.capacity;

          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            Center(
              child: Column(children: [
                Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                const Text('Parkir Aktif', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari plat nomor...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Text('Kapasitas Real-Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const Spacer(),
                  Text('${(pct * 100).round()}% Terisi', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: AppColors.card, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total kapasitas ${ParkingStore.capacity}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('Tersisa ${ParkingStore.capacity - total} slot',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.pinkDark)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Text('KENDARAAN\nTERPARKIR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, height: 1.3)),
              const SizedBox(width: 12),
              Pill('${list.length} Ditampilkan', bg: AppColors.card, fg: AppColors.primaryDark),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _newestFirst = !_newestFirst),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(_newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 4),
                    const Text('Waktu\nMasuk', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.1, color: AppColors.primaryDark)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: Text('Belum ada kendaraan parkir', style: TextStyle(color: AppColors.textMuted))),
              ),
            for (final s in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VehicleCard(session: s, onTap: () => showParkingDetailModal(context, s)),
              ),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: _stat(Icons.timelapse_rounded, 'Rata-rata Parkir',
                    _store.activeCount == 0 ? '-' : ParkingStore.durationWords(_store.averageParking)),
              ),
              const SizedBox(width: 10),
              Expanded(child: _stat(Icons.payments_outlined, 'Estimasi Omzet', ParkingStore.rupiah(_store.revenueToday))),
            ]),
          ]);
        },
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: Colors.white, child: Icon(icon, size: 18, color: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ),
        ]),
      );
}
