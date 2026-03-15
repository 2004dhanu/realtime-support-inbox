from app.models.entities import Agent
from app.store.memory import store


class AuthService:
    @staticmethod
    def issue_token(agent: Agent) -> str:
        return f"devtoken_{agent.id}"

    @staticmethod
    def verify_token(token: str | None) -> Agent | None:
        if not token or not token.startswith("devtoken_"):
            return None
        agent_id = token.replace("devtoken_", "", 1)
        return store.agents.get(agent_id)
