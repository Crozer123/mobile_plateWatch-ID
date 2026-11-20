from .base_detector import BaseYoloDetector

class FaceDetector(BaseYoloDetector):
    def __init__(self, model_path: str = "models/face_best.onnx"):
        super().__init__(model_path=model_path, label_name="face", conf_thresh=0.45)