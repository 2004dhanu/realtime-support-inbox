from __future__ import annotations

from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, Header, HTTPException

from app.schemas.conversation import (
    ConversationDetail,
    ConversationSummary,
    PaginatedConversations,
    PriorityUpdateRequest,
    StatusUpdateRequest,
)
from app.schemas.message import PaginatedMessages, MessageOut, SendMessageRequest
from app.services.auth_service import AuthService
from app.services.conversation_service import ConversationService
from app.store.memory import store
from app.ws.manager import manager
from app.models.entities import Message

router = APIRouter()


def get_current_agent(authorization: Annotated[str | None, Header()] = None):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing token")
    token = authorization.replace("Bearer ", "", 1)
    agent = AuthService.verify_token(token)
    if not agent:
        raise HTTPException(status_code=401, detail="Invalid token")
    return agent


def _summary(convo) -> ConversationSummary:
    return ConversationSummary(
        id=convo.id,
        title=convo.title,
        status=convo.status,
        priority=convo.priority,
        assignee=convo.assignee_id,
        unreadCount=convo.unread_count,
        lastMessagePreview=convo.last_message_preview,
        lastMessageAt=convo.last_message_at,
    )


@router.get("/conversations", response_model=PaginatedConversations)
async def list_conversations(
    status: str | None = None,
    assignee: str | None = None,
    priority: str | None = None,
    page: int = 1,
    pageSize: int = 20,
    _agent=Depends(get_current_agent),
) -> PaginatedConversations:
    conversations, total = ConversationService.list_conversations(
        status=status,
        assignee=assignee,
        priority=priority,
        page=page,
        page_size=pageSize,
    )
    return PaginatedConversations(
        items=[_summary(c) for c in conversations],
        page=page,
        pageSize=pageSize,
        total=total,
    )


@router.get("/conversations/{conversation_id}", response_model=ConversationDetail)
async def get_conversation(conversation_id: str, _agent=Depends(get_current_agent)) -> ConversationDetail:
    conversation = ConversationService.get_conversation(conversation_id)
    return ConversationDetail(
        id=conversation.id,
        title=conversation.title,
        status=conversation.status,
        priority=conversation.priority,
        assignee=conversation.assignee_id,
        customerId=conversation.customer_id,
        unreadCount=conversation.unread_count,
        lastMessagePreview=conversation.last_message_preview,
        lastMessageAt=conversation.last_message_at,
        createdAt=conversation.created_at,
        updatedAt=conversation.updated_at,
    )


@router.get("/conversations/{conversation_id}/messages", response_model=PaginatedMessages)
async def list_messages(
    conversation_id: str,
    page: int = 1,
    pageSize: int = 30,
    _agent=Depends(get_current_agent),
) -> PaginatedMessages:
    messages, total = ConversationService.list_messages(conversation_id, page, pageSize)
    return PaginatedMessages(
        items=[
            MessageOut(
                id=m.id,
                conversationId=m.conversation_id,
                senderType=m.sender_type,
                senderId=m.sender_id,
                body=m.body,
                createdAt=m.created_at,
                updatedAt=m.updated_at,
            )
            for m in messages
        ],
        page=page,
        pageSize=pageSize,
        total=total,
    )


@router.post("/conversations/{conversation_id}/messages", response_model=MessageOut)
async def send_message(
    conversation_id: str,
    payload: SendMessageRequest,
    agent=Depends(get_current_agent),
) -> MessageOut:
    message_id = f"msg_{conversation_id}_{len(store.messages) + 1}"
    message = ConversationService.append_message(
        conversation_id,
        message=store.messages.get(message_id)
        or Message(
            id=message_id,
            conversation_id=conversation_id,
            sender_type=payload.senderType,
            sender_id=payload.senderId or agent.id,
            body=payload.body,
            created_at=datetime.utcnow(),
        ),
    )

    event = {
        "type": "message.created",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "conversationId": conversation_id,
        "payload": {
            "id": message.id,
            "conversationId": message.conversation_id,
            "senderType": message.sender_type,
            "senderId": message.sender_id,
            "body": message.body,
            "createdAt": message.created_at.isoformat() + "Z",
        },
    }
    await manager.broadcast(event)

    return MessageOut(
        id=message.id,
        conversationId=message.conversation_id,
        senderType=message.sender_type,
        senderId=message.sender_id,
        body=message.body,
        createdAt=message.created_at,
        updatedAt=message.updated_at,
    )


@router.patch("/conversations/{conversation_id}/status", response_model=ConversationSummary)
async def update_status(
    conversation_id: str,
    payload: StatusUpdateRequest,
    _agent=Depends(get_current_agent),
) -> ConversationSummary:
    conversation = ConversationService.update_status(conversation_id, payload.status)
    await manager.broadcast(
        {
            "type": "conversation.status.updated",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "conversationId": conversation_id,
            "payload": {"status": conversation.status},
        }
    )
    return _summary(conversation)


@router.patch("/conversations/{conversation_id}/priority", response_model=ConversationSummary)
async def update_priority(
    conversation_id: str,
    payload: PriorityUpdateRequest,
    _agent=Depends(get_current_agent),
) -> ConversationSummary:
    conversation = ConversationService.update_priority(conversation_id, payload.priority)
    await manager.broadcast(
        {
            "type": "conversation.priority.updated",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "conversationId": conversation_id,
            "payload": {"priority": conversation.priority},
        }
    )
    return _summary(conversation)
