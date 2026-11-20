from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import onnxruntime as ort
from datetime import datetime

app = FastAPI(title="PlateWatch AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

face_session = ort.InferenceSession("models/face_best.onnx", providers=["CPUExecutionProvider"])
input_name = face_session.get_inputs()[0].name

def letterbox(img, new_shape=(640, 640), color=(114, 114, 114)):
    shape = img.shape[:2]  
    r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
    new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
    dw, dh = (new_shape[1] - new_unpad[0]) / 2, (new_shape[0] - new_unpad[1]) / 2

    if shape[::-1] != new_unpad:
        img = cv2.resize(img, new_unpad, interpolation=cv2.INTER_LINEAR)
    top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
    left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
    img = cv2.copyMakeBorder(img, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)
    return img, r, (dw, dh)

def detect_faces(img, conf_thresh=0.45):
    orig_h, orig_w = img.shape[:2]
    padded_img, ratio, (dw, dh) = letterbox(img, (640, 640))

    blob = cv2.cvtColor(padded_img, cv2.COLOR_BGR2RGB)
    blob = blob.transpose(2, 0, 1).astype(np.float32) / 255.0
    blob = np.expand_dims(blob, axis=0)

    outputs = face_session.run(None, {input_name: blob})[0][0]

    boxes = []
    for det in outputs:
        if len(det) < 5:
            continue
        x1, y1, x2, y2, score = float(det[0]), float(det[1]), float(det[2]), float(det[3]), float(det[4])
        if score < conf_thresh:
            continue

        x1 = max(0.0, (x1 - dw) / ratio)
        y1 = max(0.0, (y1 - dh) / ratio)
        x2 = min(float(orig_w), (x2 - dw) / ratio)
        y2 = min(float(orig_h), (y2 - dh) / ratio)

        boxes.append({
            "label": "face",
            "confidence": round(score, 2),
            "x1": round(x1 / orig_w, 4),
            "y1": round(y1 / orig_h, 4),
            "x2": round(x2 / orig_w, 4),
            "y2": round(y2 / orig_h, 4),
        })
    return boxes

@app.post("/scan")
async def scan_frame(
    file: UploadFile = File(...),
    gate_mode: str = Form("IN")
):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        return {"error": "Gambar tidak valid"}

    face_boxes = detect_faces(img, conf_thresh=0.45)

    detected_plate = "P 1234 XY" if len(face_boxes) > 0 else "-"

    return {
        "timestamp": datetime.now().strftime("%H:%M:%S"),
        "gate_mode": gate_mode,
        "status": "VERIFIED" if len(face_boxes) > 0 else "SCANNING",
        "plate_number": detected_plate,
        "boxes": face_boxes
    }
@app.get("/parking/active")
def list_active():
    return {"data": pipeline.parking_service.get_active_vehicles()}

@app.get("/parking/history")
def list_history():
    return {"data": pipeline.parking_service.get_history_vehicles()}