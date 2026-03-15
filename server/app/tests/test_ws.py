from fastapi.testclient import TestClient

from app.main import app
from app.store.seed import seed_data

client = TestClient(app)


def test_ws_connect() -> None:
    seed_data(5)
    login_response = client.post("/auth/dev-login", json={"agentId": "agent_1"})
    token = login_response.json()["token"]

    with client.websocket_connect(f"/ws?token={token}") as websocket:
        message = websocket.receive_json()
        assert message["type"] == "connection.state"
        assert message["payload"]["state"] == "connected"
