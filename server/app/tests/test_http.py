from fastapi.testclient import TestClient

from app.main import app
from app.store.seed import seed_data

client = TestClient(app)


def test_dev_login_and_list_conversations() -> None:
    seed_data(10)
    response = client.post("/auth/dev-login", json={"agentId": "agent_1"})
    assert response.status_code == 200
    token = response.json()["token"]

    list_response = client.get(
        "/conversations",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert list_response.status_code == 200
    payload = list_response.json()
    assert payload["total"] >= 1
    assert len(payload["items"]) >= 1
