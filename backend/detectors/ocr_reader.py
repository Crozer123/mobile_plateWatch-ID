import json
import cv2
import numpy as np
import onnxruntime as ort


class OCRReader:
    def __init__(
        self,
        model_path: str = "models/ocr_resnet18.onnx",
        classes_path: str = "models/ocr_classes.json",
    ):
        self.session = ort.InferenceSession(model_path, providers=["CPUExecutionProvider"])
        self.input_name = self.session.get_inputs()[0].name

        with open(classes_path, "r") as f:
            self.classes = json.load(f)

        self.mean = np.array([0.485, 0.456, 0.406], dtype=np.float32).reshape(3, 1, 1)
        self.std = np.array([0.229, 0.224, 0.225], dtype=np.float32).reshape(3, 1, 1)

    def _preprocess_char(self, char_img: np.ndarray) -> np.ndarray:
        if len(char_img.shape) == 3:
            gray = cv2.cvtColor(char_img, cv2.COLOR_BGR2GRAY)
        else:
            gray = char_img.copy()

        border = np.concatenate([gray[0, :], gray[-1, :], gray[:, 0], gray[:, -1]])
        if np.median(border) < np.median(gray):
            gray = 255 - gray

        resized = cv2.resize(gray, (64, 64), interpolation=cv2.INTER_AREA)
        img_3ch = cv2.cvtColor(resized, cv2.COLOR_GRAY2RGB).astype(np.float32) / 255.0
        img_chw = np.transpose(img_3ch, (2, 0, 1))
        img_norm = (img_chw - self.mean) / self.std
        return np.expand_dims(img_norm, axis=0)

    def _segment_characters(self, plate_img: np.ndarray) -> list[np.ndarray]:
        gray = cv2.cvtColor(plate_img, cv2.COLOR_BGR2GRAY)
        blur = cv2.GaussianBlur(gray, (3, 3), 0)
        thresh = cv2.adaptiveThreshold(
            blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 19, 9
        )

        if np.mean(thresh) > 127:
            thresh = cv2.bitwise_not(thresh)

        num_labels, _, stats, _ = cv2.connectedComponentsWithStats(thresh, connectivity=8)
        h_img, w_img = gray.shape
        candidates = []

        for i in range(1, num_labels):
            x, y, w, h, area = stats[i]
            aspect_ratio = h / float(w) if w > 0 else 0
            if (0.25 * h_img <= h <= 0.90 * h_img) and (0.8 <= aspect_ratio <= 4.5) and area > 50:
                candidates.append((x, y, w, h))

        candidates.sort(key=lambda b: b[0])

        crops = []
        for x, y, w, h in candidates:
            pad = 4
            x1 = max(0, x - pad)
            y1 = max(0, y - pad)
            x2 = min(w_img, x + w + pad)
            y2 = min(h_img, y + h + pad)
            crops.append(plate_img[y1:y2, x1:x2])

        return crops

    def read_plate(self, plate_img: np.ndarray) -> str:
        char_crops = self._segment_characters(plate_img)
        if not char_crops:
            return "-"

        result = []
        for crop in char_crops:
            blob = self._preprocess_char(crop)
            logits = self.session.run(None, {self.input_name: blob})[0][0]
            pred_idx = int(np.argmax(logits))
            result.append(self.classes[pred_idx])

        return "".join(result)