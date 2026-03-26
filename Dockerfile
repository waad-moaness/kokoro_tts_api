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

# 4. DOWNLOAD MODELS FIRST 
RUN wget -q -O app/models/voices-v1.0.bin https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin && \
    wget -q -O app/models/kokoro-v1.0.onnx https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx

# 5. Install Python dependencies
COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 6. Copy your application code last
COPY --chown=user . .

EXPOSE 7860

# Change the timeout from the default 30s to 120s
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "120", "--chdir", "app", "main:app"]