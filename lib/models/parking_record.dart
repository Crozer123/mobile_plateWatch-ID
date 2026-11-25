import 'bounding_box.dart';

class DetectFrameResult {
  final bool faceDetected;
  final bool plateDetected;
  final bool readyToCapture;
  final String? plateCandidate;
  final List<BoundingBox> boxes;
  final String message;

  DetectFrameResult({
    required this.faceDetected,
    required this.plateDetected,
    required this.readyToCapture,
    required this.plateCandidate,
    required this.boxes,
    required this.message,
  });

  factory DetectFrameResult.fromJson(Map<String, dynamic> json) {
    final boxList = (json['boxes'] as List<dynamic>? ?? [])
        .map((item) => BoundingBox.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return DetectFrameResult(
      faceDetected: json['face_detected'] == true,
      plateDetected: json['plate_detected'] == true,
      readyToCapture: json['ready_to_capture'] == true,
      plateCandidate: json['plate_candidate'] as String?,
      boxes: boxList,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class ParkingRecord {
  final String timestamp;
  final String gateMode;
  final String status;
  final String plateNumber;
  final List<BoundingBox> boxes;
  final String? ticketCode;
  final String? uiState;
  final String? registeredPlate;
  final String? mismatchType;
  final int attempt;
  final int maxAttempt;
  final double? similarityScore;
  final String message;
  final int? totalMasuk;
  final int? totalKeluar;
  final int? sedangDiDalam;

  ParkingRecord({
    required this.timestamp,
    required this.gateMode,
    required this.status,
    required this.plateNumber,
    required this.boxes,
    this.ticketCode,
    this.uiState,
    this.registeredPlate,
    this.mismatchType,
    this.attempt = 0,
    this.maxAttempt = 3,
    this.similarityScore,
    this.message = '',
    this.totalMasuk,
    this.totalKeluar,
    this.sedangDiDalam,
  });

  factory ParkingRecord.fromJson(Map<String, dynamic> json) {
    final boxList = (json['boxes'] as List<dynamic>? ?? [])
        .map((item) => BoundingBox.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return ParkingRecord(
      timestamp: (json['timestamp'] ?? '-').toString(),
      gateMode: (json['gate_mode'] ?? 'AUTO').toString(),
      status: (json['status'] ?? 'SCANNING').toString(),
      plateNumber: (json['plate_number'] ?? '-').toString(),
      boxes: boxList,
      ticketCode: json['ticket_code'] as String?,
      uiState: json['ui_state'] as String?,
      registeredPlate: json['registered_plate'] as String?,
      mismatchType: json['mismatch_type'] as String?,
      attempt: (json['attempt'] as num?)?.toInt() ?? 0,
      maxAttempt: (json['max_attempt'] as num?)?.toInt() ?? 3,
      similarityScore: (json['similarity_score'] as num?)?.toDouble(),
      message: (json['message'] ?? '').toString(),
      totalMasuk: (json['total_masuk'] as num?)?.toInt(),
      totalKeluar: (json['total_keluar'] as num?)?.toInt(),
      sedangDiDalam: (json['sedang_didalam'] as num?)?.toInt(),
    );
  }
}
