from pydantic import BaseModel


class DevLoginRequest(BaseModel):
    username: str | None = None
    agentId: str | None = None


class AgentOut(BaseModel):
    id: str
    name: str
    email: str


class DevLoginResponse(BaseModel):
    token: str
    agent: AgentOut
