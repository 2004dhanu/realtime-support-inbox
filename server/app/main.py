from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.auth import router as auth_router
from app.api.conversations import router as conversations_router
from app.core.config import settings
from app.services.event_emitter import event_emitter
from app.store.seed import seed_if_empty
from app.ws.router import router as ws_router

app = FastAPI(title=settings.app_name)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(conversations_router)
app.include_router(ws_router, prefix="/ws")


@app.on_event("startup")
async def startup_event() -> None:
    seed_if_empty(settings.seed_count)
    event_emitter.interval_seconds = settings.demo_event_interval_sec
    await event_emitter.start()


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
