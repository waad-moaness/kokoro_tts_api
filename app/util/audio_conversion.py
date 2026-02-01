import subprocess

def convert_audio(input_path, output_path):
    command = [
        "ffmpeg",
        "-y",
        "-i",
        input_path,
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
        raise RuntimeError(f"FFmpeg failed:\n{e.stderr}")
