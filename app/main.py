from fastapi import FastAPI
import uvicorn
from contextlib import asynccontextmanager
from models.kokoro_model import load_model
from api.routes import router

@asynccontextmanager
async def lifespan(app: FastAPI):
    load_model()
    yield

app = FastAPI(lifespan=lifespan)
app.include_router(router)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)