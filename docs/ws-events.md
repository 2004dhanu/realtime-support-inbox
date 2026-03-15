# WebSocket Event Spec

Endpoint: `ws://localhost:8000/ws?token=<token>`

All messages are JSON with this shape:
```json
{
  "type": "message.created",
  "timestamp": "2026-01-10T10:15:20Z",
  "conversationId": "conv_123",
  "payload": {}
}
```

## Events
- `conversation.created`
- `conversation.updated`
- `message.created`
- `message.updated`
- `typing.updated`
- `presence.updated`
- `conversation.status.updated`
- `conversation.priority.updated`

## Example: message.created
```json
{
  "type": "message.created",
  "timestamp": "2026-01-10T10:15:20Z",
  "conversationId": "conv_1",
  "payload": {
    "id": "msg_conv_1_12",
    "conversationId": "conv_1",
    "senderType": "agent",
    "senderId": "agent_1",
    "body": "Hello! I'm looking into this now.",
    "createdAt": "2026-01-10T10:20:20Z"
  }
}
```

## Example: conversation.status.updated
```json
{
  "type": "conversation.status.updated",
  "timestamp": "2026-01-10T10:21:00Z",
  "conversationId": "conv_1",
  "payload": {
    "status": "closed"
  }
}
```

## Example: typing.updated
```json
{
  "type": "typing.updated",
  "timestamp": "2026-01-10T10:22:00Z",
  "conversationId": "conv_1",
  "payload": {
    "agentId": "agent_1",
    "isTyping": true
  }
}
```

## Connection State
On successful connect, the server emits:
```json
{
  "type": "connection.state",
  "timestamp": "2026-01-10T10:15:20Z",
  "payload": {
    "state": "connected",
    "agentId": "agent_1"
  }
}
```
