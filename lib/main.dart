import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';
import 'core/demo_data.dart';
import 'services/parking_store.dart';
import 'views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  if (kUseDemoData) seedDemoData(ParkingStore.instance);
  runApp(const PlateWatchApp());
}

class PlateWatchApp extends StatelessWidget {
  const PlateWatchApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PlateWatch-ID',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      );
}
