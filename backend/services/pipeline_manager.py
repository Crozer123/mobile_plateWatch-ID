from datetime import datetime
import numpy as np
from detectors.face_detector import FaceDetector
from services.parking_service import ParkingService

class PipelineManager:
    def __init__(self):
        self.face_detector = FaceDetector("models/face_best.onnx")
        self.parking_service = ParkingService("parking.db")

    def process_frame(self, img: np.ndarray, gate_mode: str) -> dict:
        faces = self.face_detector.predict(img)
        timestamp = datetime.now().strftime("%H:%M:%S")

        if not faces:
            return {
                "timestamp": timestamp,
                "gate_mode": gate_mode,
                "status": "SCANNING",
                "ui_state": "Deteksi Ulang Wajah",
                "plate_number": "-",
                "similarity_score": None,
                "boxes": [],
            }

        # Placeholder plat & similarity (nanti diganti model plat + OCR + face embedding temanmu)
        detected_plate = "P 1234 XY"
        dummy_similarity = 0.91

        if gate_mode.upper() == "OUT":
            tx = self.parking_service.verify_exit(
                plate_number=detected_plate,
                similarity_score=dummy_similarity,
            )
        else:
            tx = self.parking_service.register_entry(plate_number=detected_plate)

        return {
            "timestamp": timestamp,
            "gate_mode": gate_mode.upper(),
            "ticket_code": tx.get("ticket_code"),
            "status": tx.get("status"),
            "ui_state": tx.get("ui_state"),
            "plate_number": detected_plate,
            "similarity_score": tx.get("similarity_score"),
            "boxes": faces,
        }