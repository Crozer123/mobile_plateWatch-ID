import cv2
import numpy as np
from fastapi import FastAPI, File, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from services.pipeline_manager import PipelineManager

app = FastAPI(title="PlateWatch AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

pipeline = PipelineManager()

@app.get("/")
def root():
    return {"message": "PlateWatch AI Backend is running"}

@app.post("/scan")
async def scan_frame(
    file: UploadFile = File(...),
    gate_mode: str = Form("IN"),
):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        return {"error": "Gambar tidak valid"}

    return pipeline.process_frame(img, gate_mode)


@app.post("/detect/ocr")
async def detect_ocr(file: UploadFile = File(...)):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        return {"error": "Gambar tidak valid"}

    return pipeline.read_plate_only(img)


@app.get("/parking/active")
def list_active():
    return {"data": pipeline.parking_service.get_active_vehicles()}


@app.get("/parking/history")
def list_history():
    return {"data": pipeline.parking_service.get_history_vehicles()}