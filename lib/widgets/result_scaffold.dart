import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../services/parking_store.dart';
import 'scanner_controls.dart';

/// Kerangka halaman hasil scan (Masuk / Keluar): header, kartu parkir,
/// tab Masuk/Keluar (hanya penanda), lalu isi halaman.
class ResultScaffold extends StatelessWidget {
  final bool isEntry;
  final List<Widget> children;
  const ResultScaffold({super.key, required this.isEntry, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
          Row(children: [
            IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(
              child: Column(children: [
                Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                const Text('Scanner', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ]),
            ),
            const CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Icon(Icons.person_rounded, color: Colors.white, size: 20)),
          ]),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: ParkingStore.instance,
            builder: (_, __) => ParkingHeaderCard(terisi: ParkingStore.instance.activeCount, kapasitas: ParkingStore.capacity),
          ),
          const SizedBox(height: 12),
          IgnorePointer(child: ModeToggle(isEntry: isEntry, onChanged: (_) {})),
          const SizedBox(height: 12),
          ...children,
        ]),
      ),
    );
  }
}
