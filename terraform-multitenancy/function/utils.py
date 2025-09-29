import re
from datetime import datetime

USERNAME_PATTERN = re.compile(r"^[a-zA-Z]+$")


def is_valid_username(username: str) -> bool:
    return bool(USERNAME_PATTERN.match(username))


def is_valid_dob(date_str: str) -> bool:
    try:
        dob = datetime.strptime(date_str, "%Y-%m-%d").date()
        return dob < datetime.now().date()
    except Exception as ex:
        print(f"Date format is invalid. Error: {ex}")
        return False


def days_until_next_birthday(birth_date: datetime.date) -> int:
    today = datetime.now().date()
    this_year = birth_date.replace(year=today.year)
    if this_year == today:
        return 0
    elif this_year > today:
        return (this_year - today).days
    else:
        next_year = birth_date.replace(year=today.year + 1)
        return (next_year - today).days
