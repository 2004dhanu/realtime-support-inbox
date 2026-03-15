from __future__ import annotations

from datetime import datetime
from typing import List, Tuple

from app.models.entities import Conversation, Message
from app.store.memory import store


class ConversationService:
    @staticmethod
    def list_conversations(
        status: str | None,
        assignee: str | None,
        priority: str | None,
        page: int,
        page_size: int,
    ) -> Tuple[List[Conversation], int]:
        conversations = list(store.conversations.values())

        if status:
            conversations = [c for c in conversations if c.status == status]
        if assignee:
            conversations = [c for c in conversations if c.assignee_id == assignee]
        if priority:
            conversations = [c for c in conversations if c.priority == priority]

        conversations.sort(key=lambda c: c.last_message_at, reverse=True)

        total = len(conversations)
        start = (page - 1) * page_size
        end = start + page_size
        return conversations[start:end], total

    @staticmethod
    def get_conversation(conversation_id: str) -> Conversation:
        return store.conversations[conversation_id]

    @staticmethod
    def list_messages(conversation_id: str, page: int, page_size: int) -> Tuple[List[Message], int]:
        all_messages = store.get_conversation_messages(conversation_id)
        all_messages.sort(key=lambda m: m.created_at)
        total = len(all_messages)
        start = (page - 1) * page_size
        end = start + page_size
        return all_messages[start:end], total

    @staticmethod
    def append_message(conversation_id: str, message: Message) -> Message:
        store.messages[message.id] = message
        conversation = store.conversations[conversation_id]
        conversation.messages.append(message.id)
        conversation.last_message_preview = message.body
        conversation.last_message_at = message.created_at
        conversation.updated_at = datetime.utcnow()
        return message

    @staticmethod
    def update_status(conversation_id: str, status: str) -> Conversation:
        conversation = store.conversations[conversation_id]
        conversation.status = status
        conversation.updated_at = datetime.utcnow()
        return conversation

    @staticmethod
    def update_priority(conversation_id: str, priority: str) -> Conversation:
        conversation = store.conversations[conversation_id]
        conversation.priority = priority
        conversation.updated_at = datetime.utcnow()
        return conversation
