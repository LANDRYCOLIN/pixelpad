import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

HOST = "0.0.0.0"
PORT = 8080


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


USERS = {
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
NEXT_ID = 2


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
            self._send_json(user)
            return
        self._not_found()

    def log_message(self, format, *args):
        return


def main():
    server = HTTPServer((HOST, PORT), MockHandler)
    print(f"Mock backend running on http://{HOST}:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
