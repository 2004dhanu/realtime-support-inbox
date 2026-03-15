# Realtime Support Inbox Assessment

This repo is a private-ready monorepo for a Flutter hiring assessment. It contains a partial Flutter app and a local FastAPI backend with REST and WebSocket endpoints.
Just run the below commands one-by-one in your terminal to set up the repository.

## Quickstart

1) Backend (get back to the team if there are any issues regarding setting up the backend)
```bash
cd server
python -m venv .venv
source .venv/bin/activate
pip install -e .
python -m uvicorn app.main:app --reload --port 8000
```

    2) Seed data (this is basically to add dummy data in the database)
```bash
./scripts/seed-server.sh
```

3) App
```bash
cd app
flutter pub get
flutter run
```

## Repo Structure
- `app` Flutter starter application
- `server` FastAPI mock backend with REST + WebSocket
- `docs` Candidate handout, rubric, API and WS specs, change requests
- `scripts` Helper scripts for local dev
- `.env.example` Example env configuration

## Local Run Commands
- Start backend: `./scripts/start-server.sh`
- Seed backend: `./scripts/seed-server.sh`
- Emit demo WS events: `./scripts/emit-demo-events.sh`
- Start app: `./scripts/start-app.sh`

## Backend Seed/Reset
- The backend uses in-memory data seeded on startup.
- `./scripts/seed-server.sh` reseeds to the configured count.
- `./scripts/reset-server.sh` reseeds to the default count.

## Demo WebSocket Events
Run `./scripts/emit-demo-events.sh` to broadcast sample updates on the WebSocket channel while the server is running.

## Assessment Maintainer Notes
- The Flutter inbox flow is intentionally incomplete in `app/lib/features/inbox`.
- Realtime event handling is scaffolded but not wired in `app/lib/features/inbox/realtime`.
- Conversation detail flow lacks pagination, optimistic updates, and reconnect recovery logic.
- The mixed state-management setup (BLoC + GetX) is intentional and should remain.
- Reviewers should focus on API correctness, realtime stability, reconnect strategy, and the candidate's ability to work within existing patterns.
