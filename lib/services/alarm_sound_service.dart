import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Layanan suara alarm aplikasi (sirine darurat lewat AudioTrack Android + fallback).
class AlarmSoundService {
  AlarmSoundService._();
  static final AlarmSoundService instance = AlarmSoundService._();

  static const _channel = MethodChannel('com.example.platewatch/alarm');
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  Future<void> startAlarm() async {
    if (isPlaying.value) return;
    isPlaying.value = true;
    try {
      await _channel.invokeMethod<bool>('startAlarm');
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> stopAlarm() async {
    isPlaying.value = false;
    try {
      await _channel.invokeMethod<bool>('stopAlarm');
    } catch (_) {}
  }

  Future<void> playWarningBeep() async {
    try {
      await _channel.invokeMethod<bool>('playWarningBeep');
      HapticFeedback.mediumImpact();
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.mediumImpact();
    }
  }
}
