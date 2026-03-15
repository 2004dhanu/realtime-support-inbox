import asyncio
import random
from datetime import datetime

from app.store.memory import store
from app.ws.manager import manager


async def emit_demo_events(loop_count: int = 5) -> None:
    conversations = list(store.conversations.values())
    for _ in range(loop_count):
        if not conversations:
            return
        convo = random.choice(conversations)
        await manager.broadcast(
            {
                "type": "conversation.updated",
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "conversationId": convo.id,
                "payload": {
                    "id": convo.id,
                    "status": convo.status,
                    "priority": convo.priority,
                    "lastMessageAt": convo.last_message_at.isoformat() + "Z",
                },
            }
        )
        await asyncio.sleep(1.5)


if __name__ == "__main__":
    asyncio.run(emit_demo_events())
