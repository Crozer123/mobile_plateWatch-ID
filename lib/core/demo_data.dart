import '../models/parking_session.dart';
import '../services/parking_store.dart';

/// false = data bersih, diisi real-time dari hasil deteksi API.
const bool kUseDemoData = false;

/// false = kamera mengirim frame langsung ke FastAPI server (`Deep learning plat/api`).
const bool kUseMockScan = false;

void seedDemoData(ParkingStore store) {
  final now = DateTime.now();
  DateTime at(int h, int m) => DateTime(now.year, now.month, now.day, h, m);

  ParkingSession active(int seq, String plate, Duration ago) =>
      ParkingSession(id: 'PK-00$seq', plate: plate, entryTime: now.subtract(ago))..seq = seq;

  ParkingSession closed(
    int seq,
    String plate,
    DateTime entry,
    DateTime exit, {
    bool rejected = false,
    bool entryKnown = true,
    String? note,
    bool noteIsError = false,
    double? face,
    String? mismatchType,
  }) =>
      ParkingSession(
        id: 'PK-90$seq',
        plate: plate,
        entryTime: entry,
        status: rejected ? SessionStatus.rejected : SessionStatus.done,
      )
        ..seq = seq
        ..entryKnown = entryKnown
        ..exitTime = exit
        ..note = note
        ..noteIsError = noteIsError
        ..faceMatch = face
        ..mismatchType = mismatchType
        ..entryPlateScore = .98
        ..exitPlateScore = .97;

  store.loadDemo(
    active: [
      active(1, 'B 4821 SKA', const Duration(minutes: 32)),
      active(2, 'D 3920 KL', const Duration(hours: 2, minutes: 10)),
    ],
    closed: [
      closed(1, 'D 3920 KL', at(8, 15), at(11, 45), face: .96),
      closed(
        2,
        'B 6912 PZX',
        at(7, 30),
        at(11, 35),
        rejected: true,
        note: 'Alarm 3x verifikasi gagal: Wajah tidak cocok',
        noteIsError: true,
        face: .41,
        mismatchType: 'FACE_MISMATCH',
      ),
    ],
  );
}
