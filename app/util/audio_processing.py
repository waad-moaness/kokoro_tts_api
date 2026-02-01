import subprocess

pitch_factor = 1.2

sample_rate = 24000
new_rate = int(sample_rate * pitch_factor)
tempo = 1.0 / pitch_factor

def pitch_shifting(input_path, output_path):
    command = [
        "ffmpeg",
        "-y",
        "-i",
        input_path,
        "-af",
        f"asetrate={new_rate},atempo={tempo},rubberband=formant=1.5",
        output_path,
    ]

    try:
        subprocess.run(
            command,
            check=True,
            capture_output=True, 
            text=True          
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"audio processing failed:\n{e.stderr}")
    