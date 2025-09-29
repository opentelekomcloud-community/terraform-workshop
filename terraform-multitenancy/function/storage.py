import json
import redis
from typing import Optional
from model import User


class RedisStorage:
    def __init__(self, host: str, port: int, password: Optional[str] = None, db: int = 0):
        self.r = redis.Redis(host=host, port=port, password=password or None, db=db, decode_responses=True)

    def set_user(self, username: str, date_of_birth: str) -> None:
        self.r.set(f"user:{username}", json.dumps({"username": username, "dateOfBirth": date_of_birth}))

    def get_user(self, username: str) -> Optional[User]:
        raw = self.r.get(f"user:{username}")
        if not raw:
            return None
        data = json.loads(raw)
        return User(username=data["username"], dateOfBirth=data["dateOfBirth"])
