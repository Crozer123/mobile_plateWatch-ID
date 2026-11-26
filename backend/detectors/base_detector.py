from abc import ABC

# from matplotlib.pylab import det
import cv2
import numpy as np
import onnxruntime as ort

class BaseYoloDetector(ABC):
    def __init__(self, model_path: str, label_name: str, conf_thresh: float = 0.45):
        self.session = ort.InferenceSession(model_path, providers=["CPUExecutionProvider"])
        self.input_name = self.session.get_inputs()[0].name
        self.label_name = label_name
        self.conf_thresh = conf_thresh

    def _letterbox(self, img: np.ndarray, new_shape=(640, 640)):
        shape = img.shape[:2]
        r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
        new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
        dw, dh = (new_shape[1] - new_unpad[0]) / 2, (new_shape[0] - new_unpad[1]) / 2
        if shape[::-1] != new_unpad:
            img = cv2.resize(img, new_unpad, interpolation=cv2.INTER_LINEAR)
        top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
        left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
        padded = cv2.copyMakeBorder(img, top, bottom, left, right, cv2.BORDER_CONSTANT, value=(114, 114, 114))
        return padded, r, (dw, dh)

    def predict(self, img: np.ndarray) -> list[dict]:
        orig_h, orig_w = img.shape[:2]
        padded_img, ratio, (dw, dh) = self._letterbox(img)

        blob = cv2.cvtColor(padded_img, cv2.COLOR_BGR2RGB).transpose(2, 0, 1).astype(np.float32) / 255.0
        outputs = self.session.run(None, {self.input_name: np.expand_dims(blob, axis=0)})[0][0]

        results = []
        for det in outputs:
            if len(det) < 5:
                continue
            x1, y1, x2, y2, score = float(det[0]), float(det[1]), float(det[2]), float(det[3]), float(det[4])
            if score < self.conf_thresh:
                continue
            x1 = max(0.0, (x1 - dw) / ratio)
            y1 = max(0.0, (y1 - dh) / ratio)
            x2 = min(float(orig_w), (x2 - dw) / ratio)
            y2 = min(float(orig_h), (y2 - dh) / ratio)

            results.append({
                "label": self.label_name,
                "confidence": round(float(score), 2),
                "x1": round(x1 / orig_w, 4),
                "y1": round(y1 / orig_h, 4),
                "x2": round(x2 / orig_w, 4),
                "y2": round(y2 / orig_h, 4),
            })
        return results