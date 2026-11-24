import 'package:flutter/material.dart';
import 'camera_screen.dart';

/// Tab "Scanner". Memakai Navigator sendiri supaya halaman hasil
/// (Masuk/Keluar, Konfirmasi Petugas, Alarm) tampil DI DALAM tab,
/// dengan navigasi bawah tetap terlihat.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPop: () => _navKey.currentState?.maybePop(),
      child: Navigator(
        key: _navKey,
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const CameraScreen()),
      ),
    );
  }
}
