# Realtime Support Inbox

## Setup

1. Install dependencies

flutter pub get

2. Run backend mock server

cd backend
npm install
npm start

3. Run Flutter app

flutter run

---

## Architecture

The project uses a mixed architecture as provided in the starter code:

- BLoC for Inbox state management
- GetX for routing
- Repository layer for API abstraction
- WebSocket adapter for realtime updates

### Key Layers

UI
↓
BLoC
↓
Repository
↓
API Client / WebSocket Client

---

## Design Decisions

- Used BLoC for inbox because realtime events update global state
- Conversation screen kept lightweight using StatefulWidget
- Realtime adapter decouples WebSocket events from UI

---

## Tradeoffs

- Optimistic message sending simplified
- Retry state implemented minimally for assessment timebox
