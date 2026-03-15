from dataclasses import dataclass
import os


@dataclass
class Settings:
    app_name: str = "Realtime Support Inbox Mock API"
    cors_origins: list[str] | None = None
    seed_count: int = 28
    demo_event_interval_sec: int = 6

    @staticmethod
    def load() -> "Settings":
        origins_raw = os.getenv("CORS_ORIGINS", "")
        origins = [o.strip() for o in origins_raw.split(",") if o.strip()]
        seed_count = int(os.getenv("SEED_COUNT", "28"))
        demo_interval = int(os.getenv("DEMO_EVENT_INTERVAL_SEC", "6"))
        return Settings(
            cors_origins=origins or [
                "http://localhost:3000",
                "http://localhost:5173",
                "http://localhost:8080",
                "http://localhost:4200",
                "http://192.168.1.8",
                "http://127.0.0.1"
            ],
            seed_count=seed_count,
            demo_event_interval_sec=demo_interval,
        )


settings = Settings.load()
