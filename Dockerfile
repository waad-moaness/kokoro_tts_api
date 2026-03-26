FROM tiangolo/uvicorn-gunicorn-fastapi:python3.11

# 1. Install system dependencies (Root)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libgl1 \
    espeak-ng \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup user and environment
RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    PYTHONPATH=/home/user/app/app:/home/user/app \
    WEB_CONCURRENCY=1 \
    PORT=7860 \
    HF_HOME=/home/user/.cache/huggingface

WORKDIR $HOME/app

# 3. Create cache and models directory
RUN mkdir -p /home/user/.cache/huggingface app/models

# 4. DOWNLOAD MODELS FIRST (The "Heavy" Lift)
# By putting these here, they are cached as a separate layer.
# Changing your code later will NOT trigger a re-download.
RUN wget -q -O app/models/voices-v1.0.bin https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin && \
    wget -q -O app/models/kokoro-v1.0.onnx https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx

# 5. Install Python dependencies
# We do this before copying your actual code to keep the cache clean.
COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 6. Copy your application code last
# Only this step runs when you update your main.py
COPY --chown=user . .

EXPOSE 7860

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]