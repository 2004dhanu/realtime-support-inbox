from __future__ import annotations

from datetime import datetime
from typing import Dict, List

from app.models.entities import Agent, Conversation, Customer, Message, PresenceState


class MemoryStore:
    def __init__(self) -> None:
        self.agents: Dict[str, Agent] = {}
        self.customers: Dict[str, Customer] = {}
        self.conversations: Dict[str, Conversation] = {}
        self.messages: Dict[str, Message] = {}
        self.presence: Dict[str, PresenceState] = {}

    def reset(self) -> None:
        self.agents.clear()
        self.customers.clear()
        self.conversations.clear()
        self.messages.clear()
        self.presence.clear()

    def get_conversation_messages(self, conversation_id: str) -> List[Message]:
        conversation = self.conversations[conversation_id]
        return [self.messages[mid] for mid in conversation.messages]

    def upsert_presence(self, agent_id: str, state: str) -> PresenceState:
        presence = PresenceState(agent_id=agent_id, state=state, updated_at=datetime.utcnow())
        self.presence[agent_id] = presence
        return presence


store = MemoryStore()
