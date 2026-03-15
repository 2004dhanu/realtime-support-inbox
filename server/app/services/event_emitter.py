from __future__ import annotations

import asyncio
import random
from datetime import datetime

from app.store.memory import store
from app.ws.manager import manager


class EventEmitter:
    def __init__(self, interval_seconds: int = 6) -> None:
        self.interval_seconds = interval_seconds
        self._task: asyncio.Task | None = None

    async def start(self) -> None:
        if self._task and not self._task.done():
            return
        self._task = asyncio.create_task(self._run())

    async def _run(self) -> None:
        while True:
            await asyncio.sleep(self.interval_seconds)
            await self.emit_random_updates()

    async def emit_random_updates(self) -> None:
        conversations = list(store.conversations.values())
        if not conversations:
            return
        conversation = random.choice(conversations)
        event_type = random.choice(
            [
                "typing.updated",
                "presence.updated",
                "conversation.updated",
                "conversation.created",
                "message.updated",
            ]
        )

        if event_type == "typing.updated":
            payload = {
                "agentId": conversation.assignee_id,
                "isTyping": random.choice([True, False]),
            }
        elif event_type == "presence.updated":
            agent_id = random.choice(list(store.agents.keys()))
            state = random.choice(["online", "away", "offline"])
            store.upsert_presence(agent_id, state)
            payload = {"agentId": agent_id, "state": state}
        elif event_type == "conversation.created":
            payload = {
                "id": conversation.id,
                "title": conversation.title,
                "status": conversation.status,
                "priority": conversation.priority,
                "assignee": conversation.assignee_id,
                "lastMessageAt": conversation.last_message_at.isoformat() + "Z",
            }
        elif event_type == "message.updated":
            payload = {
                "id": conversation.messages[-1],
                "conversationId": conversation.id,
                "body": "Updated content from demo emitter.",
            }
        else:
            payload = {
                "id": conversation.id,
                "status": conversation.status,
                "priority": conversation.priority,
                "lastMessageAt": conversation.last_message_at.isoformat() + "Z",
            }

        await manager.broadcast(
            {
                "type": event_type,
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "conversationId": conversation.id,
                "payload": payload,
            }
        )


event_emitter = EventEmitter()
