import 'bounding_box.dart';

class ParkingRecord {
  final String timestamp;
  final String gateMode;
  final String status;
  final String plateNumber;
  final List<BoundingBox> boxes;

  ParkingRecord({
    required this.timestamp,
    required this.gateMode,
    required this.status,
    required this.plateNumber,
    required this.boxes,
  });

  factory ParkingRecord.fromJson(Map<String, dynamic> json) {
    var boxList = (json['boxes'] as List<dynamic>? ?? [])
        .map((item) => BoundingBox.fromJson(item))
        .toList();

    return ParkingRecord(
      timestamp: json['timestamp'] ?? '-',
      gateMode: json['gate_mode'] ?? 'IN',
      status: json['status'] ?? 'SCANNING',
      plateNumber: json['plate_number'] ?? '-',
      boxes: boxList,
    );
  }
}