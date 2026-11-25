import 'package:flutter/material.dart';
import '../services/api_service.dart';
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

  void _onTabChanged(int i) {
    setState(() => _index = i);
    ParkingStore.instance.setScannerTabActive(i == 0);
    if (i == 1) {
      ApiService().fetchDashboard().then((dash) {
        if (dash != null) ParkingStore.instance.syncFromDashboard(dash);
      });
    }
  }

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
            onTap: _onTabChanged,
            activeCount: ParkingStore.instance.sedangDiDalam,
          ),
        ),
      );
}
