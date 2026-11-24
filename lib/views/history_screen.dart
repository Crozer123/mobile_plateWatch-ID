import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/parking_session.dart';
import '../services/parking_store.dart';
import '../widgets/app_card.dart';
import '../widgets/history_card.dart';
import 'ticket_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _store = ParkingStore.instance;
  String _query = '';
  int _filter = 0; // 0 semua, 1 selesai, 2 ditolak

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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

          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            Center(
              child: Column(children: [
                Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
            ),
            const SizedBox(height: 14),
            const Row(children: [
              Text('Riwayat Parkir', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              Spacer(),
              Pill('Arsip Otomatis', bg: AppColors.card, fg: AppColors.primaryDark, icon: Icons.cloud_done_outlined),
            ]),
            const SizedBox(height: 4),
            const Text('Hanya mencatat sesi yang telah selesai atau ditolak.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _statCard('Selesai Hari Ini', '${_store.doneToday}', 'motor', AppColors.card, AppColors.primary, Icons.check_circle_outline_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('Ditolak Hari Ini', '${_store.rejectedToday}', 'insiden', const Color(0xFFFFE0E0), AppColors.danger, Icons.shield_outlined)),
            ]),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari plat nomor riwayat...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _chip(0, 'Semua', all.length),
              const SizedBox(width: 8),
              _chip(1, 'Selesai', done),
              const SizedBox(width: 8),
              _chip(2, 'Ditolak', rejected),
            ]),
            const SizedBox(height: 14),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: Text('Belum ada riwayat', style: TextStyle(color: AppColors.textMuted))),
              ),
            for (final s in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HistoryCard(
                  session: s,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketDetailScreen(session: s))),
                ),
              ),
          ]);
        },
      ),
    );
  }

  Widget _statCard(String label, String value, String unit, Color bg, Color fg, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg))),
            Icon(icon, size: 18, color: fg),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: fg, height: 1)),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(unit, style: TextStyle(fontSize: 12, color: fg))),
          ]),
        ]),
      );

  Widget _chip(int i, String label, int count) {
    final active = _filter == i;
    return GestureDetector(
      onTap: () => setState(() => _filter = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: active ? Colors.white : AppColors.textDark)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: active ? Colors.white24 : AppColors.card, borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? Colors.white : AppColors.primaryDark)),
          ),
        ]),
      ),
    );
  }
}
