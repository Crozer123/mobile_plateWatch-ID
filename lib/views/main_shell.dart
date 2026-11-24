import 'package:flutter/material.dart';
import '../services/parking_store.dart';
import '../widgets/app_bottom_nav.dart';
import 'active_parking_screen.dart';
import 'history_screen.dart';
import 'scanner_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _index, children: const [
          ScannerScreen(),
          ActiveParkingScreen(),
          HistoryScreen(),
        ]),
        bottomNavigationBar: ListenableBuilder(
          listenable: ParkingStore.instance,
          builder: (_, __) => AppBottomNav(
            index: _index,
            onTap: (i) => setState(() => _index = i),
            activeCount: ParkingStore.instance.activeCount,
          ),
        ),
      );
}
