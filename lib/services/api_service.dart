import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/parking_record.dart';

class ApiService {
  Future<ParkingRecord?> scanFrame(String imagePath, String gateMode) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppConstants.scanEndpoint))
        ..fields['gate_mode'] = gateMode
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final streamedRes = await request.send().timeout(const Duration(seconds: 3));
      final response = await http.Response.fromStream(streamedRes);

      if (response.statusCode == 200) {
        return ParkingRecord.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}