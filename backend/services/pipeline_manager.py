from datetime import datetime
import numpy as np
from detectors.face_detector import FaceDetector
from detectors.ocr_reader import OCRReader
from services.parking_service import ParkingService


class PipelineManager:
    def __init__(self):
        self.face_detector = FaceDetector("models/face_best.onnx")
        self.ocr_reader = OCRReader("models/ocr_resnet18.onnx", "models/ocr_classes.json")
        self.parking_service = ParkingService("parking.db")

    def read_plate_only(self, plate_img: np.ndarray) -> dict:
        text = self.ocr_reader.read_plate(plate_img)
        return {
            "plate_number": text,
            "status": "OCR_SUCCESS" if text != "-" else "OCR_NOT_DETECTED",
        }

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