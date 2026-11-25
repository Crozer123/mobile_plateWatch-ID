import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/history_card.dart';
import '../widgets/kawaii_decorations.dart';
import 'ticket_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _store = ParkingStore.instance;
  String _query = '';
  int _filter = 0; // 0 semua, 1 selesai, 2 alarm/ditolak

  @override
  Widget build(BuildContext context) {
    return KawaiiBackground(
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _store,
          builder: (_, __) {
            final all = _store.closed;
            final done = all.where((s) => s.status == SessionStatus.done).length;
            final rejected = all.where((s) => s.status == SessionStatus.rejected).length;
            final q = _query.replaceAll(' ', '').toUpperCase();
            final list = all.where((s) {
              if (_filter == 1 && s.status != SessionStatus.done) return false;
              if (_filter == 2 && s.status != SessionStatus.rejected) return false;
              return s.plate.replaceAll(' ', '').toUpperCase().contains(q);
            }).toList();

            return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                    const SizedBox(height: 2),
                    Text('Buku Riwayat', style: AppTheme.heading(size: 24, color: AppColors.textDark)),
                    Text('Mencatat pengecekan keluar yang cocok atau kena alarm.',
                        style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.45)),
                  ]),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: StickerTag('Arsip Rapi ✦'),
                ),
              ]),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  flex: 11,
                  child: _statCard(
                    'Cocok Hari Ini',
                    '${_store.doneToday}',
                    'motor',
                    AppColors.successBg,
                    AppColors.success,
                    AppColors.successBorder,
                    Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 10,
                  child: _statCard(
                    'Alarm Hari Ini',
                    '${_store.rejectedToday}',
                    'insiden',
                    AppColors.dangerBg,
                    AppColors.danger,
                    AppColors.dangerBorder,
                    Icons.notifications_active_outlined,
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppTheme.body(size: 13.5, color: AppColors.textDark, height: 1.3),
                decoration: const InputDecoration(
                  hintText: 'Cari plat nomor di riwayat...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 14),

              Row(children: [
                _chip(0, 'Semua', all.length),
                const SizedBox(width: 8),
                _chip(1, 'Cocok', done),
                const SizedBox(width: 8),
                _chip(2, 'Alarm', rejected),
              ]),
              const SizedBox(height: 16),

              if (list.isEmpty)
                AppCard(
                  color: AppColors.card,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Column(children: [
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      KawaiiSparkle(size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      KawaiiCloud(size: 56, color: AppColors.primaryDark),
                    ]),
                    const SizedBox(height: 12),
                    Text('Wah, buku riwayat masih kosong nih!', style: AppTheme.heading(size: 16, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(
                      'Setiap motor yang keluar atau memicu alarm bakal tersimpan rapi di sini.',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(size: 12.5, color: AppColors.textMuted, height: 1.6),
                    ),
                  ]),
                ),
              for (final s in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HistoryCard(
                    session: s,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketDetailScreen(session: s))),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String unit, Color bg, Color fg, Color border, IconData icon) => AppCard(
        color: bg,
        borderColor: border,
        shadowColor: border,
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg))),
            Icon(icon, size: 18, color: fg),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: AppTheme.heading(size: 32, color: fg, height: 1)),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(unit, style: TextStyle(fontSize: 12, color: fg))),
          ]),
        ]),
      );

  Widget _chip(int i, String label, int count) {
    final active = _filter == i;
    return SquishyTap(
      onTap: () => setState(() => _filter = i),
      child: AnimatedContainer(
        duration: AppTheme.bouncyDuration,
        curve: AppTheme.bouncyCurve,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.elevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppColors.primaryShadow : AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: active ? AppColors.primaryShadow : AppColors.cardShadow,
              offset: Offset(0, active ? 3 : 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: active ? Colors.white : AppColors.textDark)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: active ? Colors.white24 : AppColors.card,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? Colors.white : AppColors.primaryDark)),
          ),
        ]),
      ),
    );
  }
}
