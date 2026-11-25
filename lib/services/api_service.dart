import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/parking_record.dart';

class ApiService {
  Future<DetectFrameResult?> detectFrame(String imagePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppConstants.detectFrameEndpoint))
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final streamedRes = await request.send().timeout(const Duration(seconds: 4));
      final response = await http.Response.fromStream(streamedRes);

      if (response.statusCode == 200) {
        return DetectFrameResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<ParkingRecord?> scanFrame(String imagePath, [String gateMode = 'AUTO']) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppConstants.scanEndpoint))
        ..fields['gate_mode'] = gateMode
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final streamedRes = await request.send().timeout(const Duration(seconds: 8));
      final response = await http.Response.fromStream(streamedRes);

      if (response.statusCode == 200) {
        return ParkingRecord.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.dashboardEndpoint)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.healthEndpoint)).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetMismatch() async {
    try {
      await http.post(Uri.parse(AppConstants.resetMismatchEndpoint)).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }
}
