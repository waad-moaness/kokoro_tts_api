from fastapi import APIRouter, Form, Depends, BackgroundTasks
from tempfile import NamedTemporaryFile
import soundfile as sf
import os
from fastapi.responses import FileResponse
from models.kokoro_model import load_model
from services.tts_logic import generate_speech
from util.audio_conversion import convert_audio
from tempfile import NamedTemporaryFile


router = APIRouter()

def get_model():
    return load_model()

def remove_file(path: str):
    if os.path.exists(path):
        os.remove(path)


@router.get("/")
def read_root():
    return {"health_check": "OK"}

@router.post("/generate-audio")
async def generate_audio(
    text: str = Form(...),
    background_tasks: BackgroundTasks = None,
    model = Depends(get_model),
):

    audio_data, sample_rate = generate_speech( text ,model=model)

    with NamedTemporaryFile(delete=False, suffix=".wav") as wav_file:
        wav_path = wav_file.name

    sf.write(
        wav_path,
        audio_data,
        sample_rate,
        subtype="PCM_16",
    )

    with NamedTemporaryFile(delete=False, suffix=".mp3") as mp3_file:
        mp3_path = mp3_file.name

    convert_audio(wav_path, mp3_path)

    remove_file(wav_path)

    if background_tasks:
        background_tasks.add_task(remove_file, mp3_path)

    return FileResponse(
        mp3_path,
        media_type="audio/mpeg",
        filename="speech.mp3",
    )
        

