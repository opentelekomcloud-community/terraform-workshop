import base64
import json
import os
from datetime import datetime

from model import User
from storage import RedisStorage
from utils import days_until_next_birthday, is_valid_dob, is_valid_username

REDIS_HOST = os.environ["REDIS_HOST"]
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))
REDIS_PASSWORD = os.environ.get("REDIS_PASSWORD", "")

storage = RedisStorage(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD)


def respond(status_code: int, message):
    body = message if isinstance(message, str) else json.dumps(message)
    return {
        "statusCode": status_code,
        "body": body,
        "headers": {"Content-Type": "application/json"},
    }


def func_handler(event, context):
    http_method = event.get("httpMethod") or event.get("requestContext", {}).get(
        "http", {}
    ).get("method")
    # Prefer explicit path parameter; otherwise derive from rawPath/path
    raw_path = (
            event.get("pathParameters", {}).get("username")
            or event.get("rawPath")
            or event.get("path")
            or ""
    )
    # Take the last non-empty segment as username
    username = "".join(raw_path.rstrip("/").rsplit("/", 1)[-1:]).strip()

    if not is_valid_username(username):
        return respond(400, "Username must contain only letters.")

    if http_method == "PUT":
        try:
            raw_body = event.get("body", "")
            if event.get("isBase64Encoded"):
                raw_body = base64.b64decode(raw_body).decode("utf-8")
            body = json.loads(raw_body or "{}")
            date_of_birth = body["dateOfBirth"]
        except Exception as ex:
            return respond(400, f"Invalid JSON input. Error: {ex}")

        if not is_valid_dob(date_of_birth):
            return respond(
                400, "Invalid or future date of birth. Must be in YYYY-MM-DD format"
            )

        storage.set_user(username, date_of_birth)
        return {"statusCode": 204, "body": ""}

    elif http_method == "GET":
        user: User = storage.get_user(username)
        if not user:
            return respond(404, "User not found.")

        dob = datetime.strptime(user.dateOfBirth, "%Y-%m-%d").date()
        days = days_until_next_birthday(dob)

        if days == 0:
            msg = f"Hello, {username}! Happy birthday!"
        else:
            msg = f"Hello, {username}! Your birthday is in {days} day(s)"

        return respond(200, {"message": msg})

    else:
        return respond(405, "Method Not Allowed.")
