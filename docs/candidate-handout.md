# Realtime Support Inbox Assessment

**Objective**
Build a working realtime support inbox by extending the existing Flutter starter app. You will integrate REST APIs, connect to a WebSocket stream, handle reconnect and recovery logic, and make change requests against an existing mixed-architecture codebase.

**Timebox**
8 to 10 hours of active effort within 48 hours of receiving the repo.

**What Is Provided**
- A Flutter starter app with routing, theming, and a dev login screen.
- A mock FastAPI backend with REST and WebSocket endpoints.
- A partial inbox module that uses BLoC.
- A small legacy/debug module that uses GetX.
- Existing UI components for loading, error, and empty states.

**Required Screens**
- Inbox list
- Conversation detail
- Connection or sync state indicator

**Required API Flows**
- Fetch inbox list
- Filter by status
- Open a conversation
- Fetch paginated message history
- Send a message
- Update conversation status
- Recover state after reconnect

**Required Realtime Behavior**
- Authenticated connection setup
- Reconnect on disconnect
- Backoff strategy for repeated failures
- Duplicate event protection
- Stable ordering of messages
- Recovery after reconnect
- Visible connection state in the UI

**UI Expectations**
- No pixel-perfect design requirement
- Clean, usable layout
- Sensible loading, empty, and error states
- No broken edge states

**Important Notes**
- There is no Figma and no flow diagram.
- The codebase is intentionally mixed: BLoC in inbox, GetX in debug/settings.
- Do not rewrite the entire app into a single architecture.

**Required Deliverables**
- Git repo with logical commits
- `README.md`
- `CODEBASE_NOTES.md`
- `COMMUNICATION.md`
- Tests (unit and widget; integration if time allows)
- A 3 to 5 minute screen recording

**Acceptance Criteria**
- The app runs without crashing and the main flows are usable.
- Inbox list and conversation detail are correctly wired to the API.
- Realtime events update UI in a stable, deduplicated way.
- Reconnect and recovery behavior works without manual restart.
- Status and priority updates are reflected in UI state.
- Clear written communication in `CODEBASE_NOTES.md` and `COMMUNICATION.md`.

**Hard Rejection Criteria**
- Full architecture rewrite without justification.
- No reconnect or recovery handling.
- WebSocket logic placed directly in UI widgets.
- Weak or vague communication notes.
- Ignoring mixed state-management constraints.
- Pretty UI with shallow or broken logic.
