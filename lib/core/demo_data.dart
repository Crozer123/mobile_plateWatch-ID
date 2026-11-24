import '../models/parking_session.dart';
import '../services/parking_store.dart';

/// true  = Parkir Aktif & Riwayat diisi DATA CONTOH (untuk tampilan / presentasi).
/// false = kosong, terisi dari hasil scan asli.
/// >>> Ubah ke false setelah AI terintegrasi. <<<
const bool kUseDemoData = true;

/// true  = scan memakai balasan PALSU (tanpa backend) untuk uji alur & tampilan.
/// false = scan dikirim ke backend asli lewat ApiService.
/// >>> Ubah ke false setelah backend terhubung. <<<
const bool kUseMockScan = true;

void seedDemoData(ParkingStore store) {
  final now = DateTime.now();
  DateTime at(int h, int m) => DateTime(now.year, now.month, now.day, h, m);

  ParkingSession active(int seq, String plate, Duration ago) =>
      ParkingSession(id: 'TRX-${98800 + seq}', plate: plate, entryTime: now.subtract(ago))..seq = seq;

  ParkingSession closed(
    int seq,
    String plate,
    DateTime entry,
    DateTime exit, {
    bool rejected = false,
    bool entryKnown = true,
    bool manual = false,
    String? note,
    bool noteIsError = false,
    double? face,
  }) =>
      ParkingSession(
        id: 'TRX-${98700 + seq}',
        plate: plate,
        entryTime: entry,
        status: rejected ? SessionStatus.rejected : SessionStatus.done,
      )
        ..seq = seq
        ..entryKnown = entryKnown
        ..exitTime = exit
        ..manual = manual
        ..note = note
        ..noteIsError = noteIsError
        ..faceMatch = face
        ..entryPlateScore = .991
        ..exitPlateScore = .989;

  store.loadDemo(
    active: [
      active(1, 'B 4821 SKA', const Duration(minutes: 32)),
      active(2, 'D 3920 KL', const Duration(hours: 3, minutes: 20)),
      active(3, 'B 6912 PZX', const Duration(hours: 4, minutes: 5)),
      active(4, 'B 5501 TZX', const Duration(hours: 2, minutes: 25)),
      active(5, 'F 4118 AA', const Duration(hours: 1, minutes: 55)),
    ],
    closed: [
      closed(1, 'D 3920 KL', at(8, 15), at(11, 45), face: .96),
      closed(2, 'B 6912 PZX', at(7, 30), at(11, 35),
          rejected: true, note: 'Wajah tidak cocok (Skor 41%)', noteIsError: true, face: .41),
      closed(3, 'B 3021 KLD', at(10, 15), at(10, 50),
          manual: true, note: 'Dibuka petugas setelah 3x gagal verifikasi', face: .72),
      closed(4, 'B 1109 BGA', at(8, 45), at(10, 20), face: .94),
      closed(5, 'F 9923 ZT', at(9, 0), at(9, 0),
          rejected: true, entryKnown: false, note: 'Tiket masuk tidak terlacak sistem', noteIsError: true),
    ],
  );
}
