from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional


@dataclass
class Agent:
    id: str
    name: str
    email: str


@dataclass
class Customer:
    id: str
    name: str
    email: str


@dataclass
class Message:
    id: str
    conversation_id: str
    sender_type: str  # "agent" | "customer" | "system"
    sender_id: Optional[str]
    body: str
    created_at: datetime
    updated_at: Optional[datetime] = None


@dataclass
class Conversation:
    id: str
    customer_id: str
    title: str
    status: str  # "open" | "pending" | "closed"
    priority: str  # "high" | "medium" | "low"
    assignee_id: Optional[str]
    unread_count: int
    last_message_preview: str
    last_message_at: datetime
    created_at: datetime
    updated_at: datetime
    messages: list[str] = field(default_factory=list)


@dataclass
class PresenceState:
    agent_id: str
    state: str  # "online" | "away" | "offline"
    updated_at: datetime
