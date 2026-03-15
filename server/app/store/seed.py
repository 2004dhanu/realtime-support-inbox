from __future__ import annotations

import random
from datetime import datetime, timedelta

from app.models.entities import Agent, Conversation, Customer, Message
from app.store.memory import store

STATUSES = ["open", "pending", "closed"]
PRIORITIES = ["high", "medium", "low"]


def _now() -> datetime:
    return datetime.utcnow()


def seed_data(count: int = 28) -> None:
    store.reset()

    agents = [
        Agent(id="agent_1", name="Avery Quinn", email="avery@acme.test"),
        Agent(id="agent_2", name="Jordan Lee", email="jordan@acme.test"),
        Agent(id="agent_3", name="Kai Patel", email="kai@acme.test"),
    ]
    for agent in agents:
        store.agents[agent.id] = agent

    customers = []
    for i in range(count):
        customers.append(
            Customer(
                id=f"cust_{i+1}",
                name=f"Customer {i+1}",
                email=f"customer{i+1}@example.test",
            )
        )
    for customer in customers:
        store.customers[customer.id] = customer

    base_time = _now() - timedelta(days=2)
    for i, customer in enumerate(customers):
        status = random.choice(STATUSES)
        priority = random.choice(PRIORITIES)
        assignee = random.choice([None, "agent_1", "agent_2", "agent_3"])
        convo_id = f"conv_{i+1}"
        created_at = base_time + timedelta(minutes=i * 7)
        last_message_at = created_at + timedelta(minutes=15)
        last_preview = random.choice(
            [
                "Can you help me with my order?",
                "I'm still seeing the error.",
                "Thanks for the quick reply!",
                "The app keeps signing me out.",
                "Is there an ETA on the fix?",
            ]
        )
        conversation = Conversation(
            id=convo_id,
            customer_id=customer.id,
            title=customer.name,
            status=status,
            priority=priority,
            assignee_id=assignee,
            unread_count=random.randint(0, 4),
            last_message_preview=last_preview,
            last_message_at=last_message_at,
            created_at=created_at,
            updated_at=last_message_at,
        )
        store.conversations[conversation.id] = conversation

        for j in range(random.randint(3, 7)):
            message_id = f"msg_{i+1}_{j+1}"
            sender_type = "customer" if j % 2 == 0 else "agent"
            sender_id = customer.id if sender_type == "customer" else (assignee or "agent_1")
            message_time = created_at + timedelta(minutes=3 + j * 2)
            message = Message(
                id=message_id,
                conversation_id=conversation.id,
                sender_type=sender_type,
                sender_id=sender_id,
                body=f"Sample message {j+1} for {customer.name}.",
                created_at=message_time,
            )
            store.messages[message.id] = message
            conversation.messages.append(message.id)

        conversation.last_message_preview = store.messages[conversation.messages[-1]].body
        conversation.last_message_at = store.messages[conversation.messages[-1]].created_at
        conversation.updated_at = conversation.last_message_at


def seed_if_empty(count: int = 28) -> None:
    if not store.conversations:
        seed_data(count)
