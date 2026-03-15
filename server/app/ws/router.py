from __future__ import annotations

import json
from datetime import datetime

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.services.auth_service import AuthService
from app.ws.manager import manager

router = APIRouter()


@router.websocket("")
async def websocket_endpoint(websocket: WebSocket, token: str | None = None) -> None:
    agent = AuthService.verify_token(token)

    # Temporary dev fallback if token is invalid
    if not agent:
        class DummyAgent:
            id = "dev-agent"

        agent = DummyAgent()

    await manager.connect(websocket, agent.id)

    try:
        while True:
            raw_message = await websocket.receive_text()

            try:
                payload = json.loads(raw_message)
            except json.JSONDecodeError:
                await websocket.send_json(
                    {
                        "type": "error",
                        "timestamp": datetime.utcnow().isoformat() + "Z",
                        "payload": {"message": "Invalid JSON"},
                    }
                )
                continue

            if payload.get("type") == "typing.updated":
                await manager.broadcast(
                    {
                        "type": "typing.updated",
                        "timestamp": datetime.utcnow().isoformat() + "Z",
                        "conversationId": payload.get("conversationId"),
                        "payload": payload.get("payload", {}),
                    }
                )

    except WebSocketDisconnect:
        await manager.disconnect(websocket)