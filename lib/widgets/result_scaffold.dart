import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../services/parking_store.dart';
import 'app_card.dart';
import 'kawaii_decorations.dart';
import 'scanner_controls.dart';

/// Kerangka halaman hasil verifikasi (Masuk / Keluar / Alarm) berlatar Kawaii.
class ResultScaffold extends StatelessWidget {
  final bool isEntry;
  final List<Widget> children;
  const ResultScaffold({super.key, required this.isEntry, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KawaiiBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), children: [
            Row(children: [
              SquishyTap(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, offset: Offset(0, 2), blurRadius: 0)],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                ),
              ),
              Expanded(
                child: Column(children: [
                  Text('PLATEWATCH-ID', style: AppTheme.mono(size: 10, color: AppColors.textMuted, spacing: 1.2)),
                  Text('Hasil Pengecekan', style: AppTheme.heading(size: 19, color: AppColors.textDark)),
                ]),
              ),
              const StickerTag('Otomatis ✦'),
            ]),
            const SizedBox(height: 14),
            ListenableBuilder(
              listenable: ParkingStore.instance,
              builder: (_, __) => ParkingHeaderCard(
                totalMasuk: ParkingStore.instance.totalMasuk,
                totalKeluar: ParkingStore.instance.totalKeluar,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Pill(
                isEntry ? 'Deteksi Otomatis • Sepeda Masuk' : 'Deteksi Otomatis • Sepeda Keluar',
                bg: isEntry ? AppColors.butter : AppColors.peach,
                fg: isEntry ? AppColors.butterInk : AppColors.peachInk,
                borderColor: isEntry ? AppColors.butterShadow : AppColors.peachShadow,
                icon: isEntry ? Icons.login_rounded : Icons.logout_rounded,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      ),
    );
  }
}
