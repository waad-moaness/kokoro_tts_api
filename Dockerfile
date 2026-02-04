FROM tiangolo/uvicorn-gunicorn-fastapi:python3.11

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libgl1 \
    espeak-ng \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup User
RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    PYTHONPATH=/home/user/app \
    WEB_CONCURRENCY=1 \
    PORT=7860 \
    HF_HOME=/home/user/.cache/huggingface

WORKDIR $HOME/app

RUN mkdir -p /home/user/.cache/huggingface

# 3. Install Python Dependencies
COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 4. Download Models (Done BEFORE copying code to save build time)
RUN mkdir -p models
RUN wget -O models/voices-v1.0.bin https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin
RUN wget -O models/kokoro-v1.0.onnx https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx

# 5. Copy Application Code (The critical fix!)
# We copy everything (.) to the current directory (.)
COPY --chown=user . .

EXPOSE 7860

# 6. Start the App
# Ensure your python file is named 'main.py' and has an app object named 'app'
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:7860", "--workers", "1", "main:app"]