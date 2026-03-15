import asyncio

from app.ws.manager import manager


async def close_connections() -> None:
    await manager.close_all(code=1012)


if __name__ == "__main__":
    asyncio.run(close_connections())
