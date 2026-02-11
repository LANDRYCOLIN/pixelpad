import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

HOST = "0.0.0.0"
PORT = 8080
DATA_FILE = os.path.join(os.path.dirname(__file__), "mock_data.json")


def _default_user(user_id, phone, password):
    return {
        "id": user_id,
        "phone": phone,
        "username": f"User{phone[-4:]}",
        "password": password,
        "email": "",
        "birthday": "2000-01-01",
        "mbti": "",
        "avatarMode": "logo",
    }


def _seed_users():
    return {
        1: {
            "id": 1,
            "phone": "13800000000",
            "username": "PixelPad",
            "password": "123456",
            "email": "pixelpad@example.com",
            "birthday": "2006-11-15",
            "mbti": "INFP",
            "avatarMode": "logo",
        }
    }


def _load_data():
    if not os.path.exists(DATA_FILE):
        users = _seed_users()
        return users, 2
    try:
        with open(DATA_FILE, "r", encoding="utf-8") as handle:
            payload = json.load(handle)
        raw_users = payload.get("users", {})
        users = {int(key): value for key, value in raw_users.items()}
        next_id = int(payload.get("next_id", max(users.keys(), default=0) + 1))
        return users, next_id
    except (OSError, ValueError, json.JSONDecodeError):
        users = _seed_users()
        return users, 2


def _save_data(users, next_id):
    payload = {"next_id": next_id, "users": {str(k): v for k, v in users.items()}}
    temp_path = f"{DATA_FILE}.tmp"
    with open(temp_path, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
    os.replace(temp_path, DATA_FILE)


USERS, NEXT_ID = _load_data()


class MockHandler(BaseHTTPRequestHandler):
    def _read_json(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length == 0:
            return {}
        raw = self.rfile.read(length).decode("utf-8")
        if not raw:
            return {}
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            return {}

    def _send_json(self, payload, status=200):
        data = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _not_found(self):
        self._send_json({"error": "not found"}, status=404)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            self._send_json({"status": "ok"})
            return
        if parsed.path.startswith("/users/"):
            try:
                user_id = int(parsed.path.split("/")[-1])
            except ValueError:
                self._not_found()
                return
            user = USERS.get(user_id)
            if not user:
                self._not_found()
                return
            self._send_json(user)
            return
        self._not_found()

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path == "/login":
            payload = self._read_json()
            phone = str(payload.get("phone", "")).strip()
            password = str(payload.get("password", "")).strip()
            if not phone or not password:
                self._send_json({"error": "phone and password required"}, status=400)
                return
            user = None
            for candidate in USERS.values():
                if candidate.get("phone") == phone and candidate.get("password") == password:
                    user = candidate
                    break
            if not user:
                self._send_json({"error": "invalid credentials"}, status=401)
                return
            self._send_json(user)
            return
        if parsed.path == "/register":
            payload = self._read_json()
            phone = str(payload.get("phone", "")).strip()
            password = str(payload.get("password", "")).strip()
            if not phone or not password:
                self._send_json({"error": "phone and password required"}, status=400)
                return
            global NEXT_ID
            user_id = NEXT_ID
            NEXT_ID += 1
            user = _default_user(user_id, phone, password)
            USERS[user_id] = user
            _save_data(USERS, NEXT_ID)
            self._send_json(user, status=201)
            return
        self._not_found()

    def do_PUT(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith("/users/"):
            try:
                user_id = int(parsed.path.split("/")[-1])
            except ValueError:
                self._not_found()
                return
            if user_id not in USERS:
                self._not_found()
                return
            payload = self._read_json()
            user = USERS[user_id]
            for key in [
                "phone",
                "username",
                "password",
                "email",
                "birthday",
                "mbti",
                "avatarMode",
            ]:
                if key in payload and payload[key] is not None:
                    user[key] = payload[key]
            USERS[user_id] = user
            _save_data(USERS, NEXT_ID)
            self._send_json(user)
            return
        self._not_found()

    def log_message(self, format, *args):
        return


def main():
    _save_data(USERS, NEXT_ID)
    server = HTTPServer((HOST, PORT), MockHandler)
    print(f"Mock backend running on http://{HOST}:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
