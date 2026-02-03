from kokoro_onnx import Kokoro
import re
import numpy as np


_SENTENCE_REGEX = re.compile(
    r'(?<=[.!?])\s+'
)

def split_text(text: str) -> list[str]:
    return [s.strip() for s in _SENTENCE_REGEX.split(text) if s.strip()]

def generate_speech(
    text: str,
    *,
    model: Kokoro,
    voice: str = "af_heart",
    speed: float = 0.8,
    lang: str = "en-us",
    pause_sec: float = 0.2,
):
    sentences = split_text(text)
    if not sentences:
        raise ValueError("Text is empty or contains no valid sentences")
    audio_segments = []


    for i, sentence in enumerate(sentences):
        samples, sample_rate = model.create(
                sentence,
                voice=voice,
                speed=speed,
                lang=lang,
            )

        audio_segments.append(samples)

        if pause_sec > 0 and i < len(sentences) - 1:
            audio_segments.append(
                np.zeros(int(sample_rate * pause_sec), dtype=np.float32)
            )

    return np.concatenate(audio_segments), sample_rate


