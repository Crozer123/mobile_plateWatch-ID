class AppConstants {
  /// Alamat base URL server FastAPI di laptop (ganti lewat tombol Setting di kamera jika IP berubah).
  static String baseUrl = 'http://192.168.1.155:8001';

  static void setBaseUrl(String raw) {
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'http://$trimmed';
    }
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    baseUrl = trimmed;
  }

  static String get healthEndpoint => '$baseUrl/health';
  static String get detectFrameEndpoint => '$baseUrl/detect-frame';
  static String get scanEndpoint => '$baseUrl/scan';
  static String get dashboardEndpoint => '$baseUrl/dashboard';
  static String get resetMismatchEndpoint => '$baseUrl/reset-mismatch';
  static String get activeEndpoint => '$baseUrl/parking/active';
  static String get historyEndpoint => '$baseUrl/parking/history';
  static String get resetAllEndpoint => '$baseUrl/reset-all';
}
