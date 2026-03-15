from __future__ import annotations

import asyncio
from datetime import datetime
from typing import Any

from fastapi import WebSocket


class ConnectionManager:
    def __init__(self) -> None:
        self._lock = asyncio.Lock()
        self.active_connections: list[tuple[WebSocket, str]] = []

    async def connect(self, websocket: WebSocket, agent_id: str) -> None:
        await websocket.accept()
        async with self._lock:
            self.active_connections.append((websocket, agent_id))
        await websocket.send_json(
            {
                "type": "connection.state",
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "payload": {"state": "connected", "agentId": agent_id},
            }
        )

    async def disconnect(self, websocket: WebSocket) -> None:
        async with self._lock:
            self.active_connections = [c for c in self.active_connections if c[0] is not websocket]

    async def broadcast(self, message: dict[str, Any]) -> None:
        async with self._lock:
            connections = list(self.active_connections)
        for websocket, _agent_id in connections:
            try:
                await websocket.send_json(message)
            except Exception:
                await self.disconnect(websocket)

    async def close_all(self, code: int = 1001) -> None:
        async with self._lock:
            connections = list(self.active_connections)
            self.active_connections.clear()
        for websocket, _ in connections:
            try:
                await websocket.close(code=code)
            except Exception:
                pass


manager = ConnectionManager()
