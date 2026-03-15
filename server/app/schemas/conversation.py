from datetime import datetime
from pydantic import BaseModel


class ConversationSummary(BaseModel):
    id: str
    title: str
    status: str
    priority: str
    assignee: str | None
    unreadCount: int
    lastMessagePreview: str
    lastMessageAt: datetime


class ConversationDetail(BaseModel):
    id: str
    title: str
    status: str
    priority: str
    assignee: str | None
    customerId: str
    unreadCount: int
    lastMessagePreview: str
    lastMessageAt: datetime
    createdAt: datetime
    updatedAt: datetime


class PaginatedConversations(BaseModel):
    items: list[ConversationSummary]
    page: int
    pageSize: int
    total: int


class StatusUpdateRequest(BaseModel):
    status: str


class PriorityUpdateRequest(BaseModel):
    priority: str
