from datetime import datetime
from pydantic import BaseModel


class MessageOut(BaseModel):
    id: str
    conversationId: str
    senderType: str
    senderId: str | None
    body: str
    createdAt: datetime
    updatedAt: datetime | None = None


class PaginatedMessages(BaseModel):
    items: list[MessageOut]
    page: int
    pageSize: int
    total: int
    nextCursor: str | None = None


class SendMessageRequest(BaseModel):
    body: str
    senderType: str = "agent"
    senderId: str | None = None
