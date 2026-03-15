# Codebase Notes

## Key Entry Points

main.dart
Initializes the application and routes.

InboxPage
Main inbox screen displaying conversation list.

ConversationPage
Displays message history and composer.

---

## WebSocket Implementation

RealtimeService
Handles WebSocket connection lifecycle.

InboxRealtimeAdapter
Transforms WebSocket events into BLoC events.

Supported events:

conversation.created
conversation.updated
message.created
message.updated
typing.updated
presence.updated
conversation.priority.updated

---

## API Layer

InboxApiRepository
Handles all REST API calls.

Endpoints used:

GET /conversations
GET /conversations/{id}/messages
POST /conversations/{id}/messages
PATCH /conversations/{id}/status
PATCH /conversations/{id}/priority
