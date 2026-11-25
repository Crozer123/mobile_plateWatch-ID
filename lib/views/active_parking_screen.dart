import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/kawaii_decorations.dart';
import '../widgets/parking_detail_modal.dart';
import '../widgets/vehicle_card.dart';

/// Tab Dashboard: menampilkan Total Sepeda Masuk, Total Sepeda Keluar,
/// dan daftar sepeda yang sedang di dalam dengan gaya Bento & Scrapbook Kawaii.
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
    return KawaiiBackground(
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _store,
          builder: (_, __) {
            final q = _query.replaceAll(' ', '').toUpperCase();
            final list = _store.active
                .where((s) => s.plate.replaceAll(' ', '').toUpperCase().contains(q))
                .toList();
            list.sort((a, b) => _newestFirst ? b.entryTime.compareTo(a.entryTime) : a.entryTime.compareTo(b.entryTime));

            return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
              // Header asimetris ala scrapbook
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                    const SizedBox(height: 2),
                    Text('Dashboard Sepeda', style: AppTheme.heading(size: 24, color: AppColors.textDark)),
                    Text('Catatan keluar-masuk motor hari ini',
                        style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.4)),
                  ]),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: StickerTag('Pantauan Aktif ✦'),
                ),
              ]),
              const SizedBox(height: 16),

              // Bento Box asimetris untuk Total Sepeda Masuk & Keluar
              Row(children: [
                Expanded(
                  flex: 11,
                  child: AppCard(
                    color: AppColors.elevated,
                    padding: const EdgeInsets.all(16),
                    child: Stack(children: [
                      const Positioned(right: 0, top: 0, child: KawaiiSparkle(size: 18, color: AppColors.primary)),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.successBorder, width: 1.5),
                          ),
                          child: const Icon(Icons.login_rounded, size: 18, color: AppColors.success),
                        ),
                        const SizedBox(height: 12),
                        Text('Total Sepeda Masuk', style: AppTheme.body(size: 12, w: FontWeight.w700, color: AppColors.textDark, height: 1.3)),
                        const SizedBox(height: 6),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${_store.totalMasuk}', style: AppTheme.heading(size: 36, color: AppColors.primaryDark, height: 1)),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('sepeda', style: AppTheme.body(size: 12, color: AppColors.textMuted, height: 1.2)),
                          ),
                        ]),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 10,
                  child: AppCard(
                    color: AppColors.card,
                    padding: const EdgeInsets.all(16),
                    child: Stack(children: [
                      const Positioned(right: 0, top: 2, child: KawaiiBow(size: 22, color: AppColors.primaryDark)),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.peach,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.peachShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.logout_rounded, size: 18, color: AppColors.peachInk),
                        ),
                        const SizedBox(height: 12),
                        Text('Total Sepeda Keluar', style: AppTheme.body(size: 12, w: FontWeight.w700, color: AppColors.textDark, height: 1.3)),
                        const SizedBox(height: 6),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${_store.totalKeluar}', style: AppTheme.heading(size: 36, color: AppColors.textDark, height: 1)),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('sepeda', style: AppTheme.body(size: 12, color: AppColors.textMuted, height: 1.2)),
                          ),
                        ]),
                      ]),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Search field tactile
              TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppTheme.body(size: 13.5, color: AppColors.textDark, height: 1.3),
                decoration: const InputDecoration(
                  hintText: 'Cari plat nomor sepeda yuk...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 18),

              Row(children: [
                Expanded(
                  child: Row(children: [
                    Text('Sepeda di Dalam', style: AppTheme.heading(size: 16, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Pill(
                      '${list.length} unit',
                      bg: AppColors.peach,
                      fg: AppColors.peachInk,
                      borderColor: AppColors.peachShadow,
                    ),
                  ]),
                ),
                SquishyTap(
                  onTap: () => setState(() => _newestFirst = !_newestFirst),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 2), blurRadius: 0)],
                    ),
                    child: Row(children: [
                      Icon(_newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          size: 14, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      const Text('Terbaru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              if (list.isEmpty)
                AppCard(
                  color: AppColors.card,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Column(children: [
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      KawaiiSparkle(size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      KawaiiCloud(size: 58, color: AppColors.primaryDark),
                      SizedBox(width: 8),
                      KawaiiSparkle(size: 14, color: AppColors.peachShadow),
                    ]),
                    const SizedBox(height: 12),
                    Text('Wah, area masih lengang nih!', style: AppTheme.heading(size: 16, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada sepeda yang masuk saat ini. Kamera bakal mencatat otomatis pas motor lewat.',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.6),
                    ),
                  ]),
                ),
              for (final s in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VehicleCard(session: s, onTap: () => showParkingDetailModal(context, s)),
                ),
            ]);
          },
        ),
      ),
    );
  }
}
