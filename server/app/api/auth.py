from fastapi import APIRouter, HTTPException

from app.schemas.auth import AgentOut, DevLoginRequest, DevLoginResponse
from app.services.auth_service import AuthService
from app.store.memory import store

router = APIRouter()


@router.post("/auth/dev-login", response_model=DevLoginResponse)
async def dev_login(payload: DevLoginRequest) -> DevLoginResponse:
    agent = None
    if payload.agentId:
        agent = store.agents.get(payload.agentId)
    if not agent and payload.username:
        agent = next((a for a in store.agents.values() if payload.username.lower() in a.name.lower()), None)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")

    token = AuthService.issue_token(agent)
    return DevLoginResponse(token=token, agent=AgentOut(id=agent.id, name=agent.name, email=agent.email))
