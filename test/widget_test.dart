import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platewatch/core/app_colors.dart';
import 'package:platewatch/main.dart';
import 'package:platewatch/services/parking_store.dart';
import 'package:platewatch/views/active_parking_screen.dart';

void main() {
  testWidgets('PlateWatchApp memakai palet Kawaii Soft-Pink (Anti-AI Slop)', (WidgetTester tester) async {
    expect(AppColors.bg, const Color(0xFFFFF8FA));
    expect(AppColors.textDark, const Color(0xFF4A2C36));
    expect(AppColors.primary, const Color(0xFFF4729B));

    await tester.pumpWidget(const PlateWatchApp());
    expect(find.byType(PlateWatchApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 4600));
  });

  testWidgets('Dashboard menampilkan Total Sepeda Masuk dan Total Sepeda Keluar tanpa tarif', (WidgetTester tester) async {
    final store = ParkingStore.instance..clearAll();
    store.recordEntry(plate: 'B 4821 SKA', time: DateTime(2026, 11, 25, 8, 0));
    store.recordEntry(plate: 'D 3920 KL', time: DateTime(2026, 11, 25, 8, 10));
    store.recordExit(plate: 'D 3920 KL', time: DateTime(2026, 11, 25, 9, 15));

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ActiveParkingScreen())));

    expect(find.text('Total Sepeda Masuk'), findsOneWidget);
    expect(find.text('Total Sepeda Keluar'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('B 4821 SKA'), findsOneWidget);
    expect(find.textContaining('Omzet'), findsNothing);
    expect(find.textContaining('Tarif'), findsNothing);

    store.clearAll();
  });
}
