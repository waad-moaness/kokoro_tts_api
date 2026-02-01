from pathlib import Path
from kokoro_onnx import Kokoro

BASE_DIR = Path(__file__).resolve().parent.parent 

MODEL_PATH = BASE_DIR / "models/kokoro-v1.0.onnx"
VOICES_PATH = BASE_DIR / "models/voices-v1.0.bin"

model: Kokoro | None = None

def load_model():
    global model
    if model is None:
        model = Kokoro(MODEL_PATH, VOICES_PATH)
    return model