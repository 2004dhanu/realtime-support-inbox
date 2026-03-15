# REST API Spec

Base URL: `http://localhost:8000`

All endpoints require `Authorization: Bearer <token>` except `POST /auth/dev-login`.

## POST /auth/dev-login
Request:
```json
{
  "agentId": "agent_1"
}
```
Response:
```json
{
  "token": "devtoken_agent_1",
  "agent": {
    "id": "agent_1",
    "name": "Avery Quinn",
    "email": "avery@acme.test"
  }
}
```

## GET /conversations
Query params: `status`, `assignee`, `priority`, `page`, `pageSize`

Response:
```json
{
  "items": [
    {
      "id": "conv_1",
      "title": "Customer 1",
      "status": "open",
      "priority": "high",
      "assignee": "agent_1",
      "unreadCount": 2,
      "lastMessagePreview": "Can you help me with my order?",
      "lastMessageAt": "2026-01-10T10:15:20Z"
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 28
}
```

## GET /conversations/{id}
Response:
```json
{
  "id": "conv_1",
  "title": "Customer 1",
  "status": "open",
  "priority": "high",
  "assignee": "agent_1",
  "customerId": "cust_1",
  "unreadCount": 2,
  "lastMessagePreview": "Can you help me with my order?",
  "lastMessageAt": "2026-01-10T10:15:20Z",
  "createdAt": "2026-01-10T10:00:00Z",
  "updatedAt": "2026-01-10T10:15:20Z"
}
```

## GET /conversations/{id}/messages
Query params: `page`, `pageSize`

Response:
```json
{
  "items": [
    {
      "id": "msg_1_1",
      "conversationId": "conv_1",
      "senderType": "customer",
      "senderId": "cust_1",
      "body": "Sample message 1 for Customer 1.",
      "createdAt": "2026-01-10T10:02:00Z"
    }
  ],
  "page": 1,
  "pageSize": 30,
  "total": 5,
  "nextCursor": null
}
```

## POST /conversations/{id}/messages
Request:
```json
{
  "body": "Hello! I'm looking into this now.",
  "senderType": "agent"
}
```
Response:
```json
{
  "id": "msg_conv_1_12",
  "conversationId": "conv_1",
  "senderType": "agent",
  "senderId": "agent_1",
  "body": "Hello! I'm looking into this now.",
  "createdAt": "2026-01-10T10:20:20Z"
}
```

## PATCH /conversations/{id}/status
Request:
```json
{
  "status": "closed"
}
```
Response: conversation summary payload.

## PATCH /conversations/{id}/priority
Request:
```json
{
  "priority": "high"
}
```
Response: conversation summary payload.
