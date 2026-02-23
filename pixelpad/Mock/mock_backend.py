import base64
import json
import os
import struct
import uuid
import zlib
from email import policy
from email.parser import BytesParser
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

HOST = "0.0.0.0"
PORT = 8080
DATA_FILE = os.path.join(os.path.dirname(__file__), "mock_data.json")
ROOT_DIR = os.path.dirname(__file__)
SETTINGS_DIR = os.path.join(ROOT_DIR, "settings")

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"

SESSIONS = {}


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


def _rgba_from_hex(hex_value):
    hex_value = (hex_value or "").lstrip("#")
    if len(hex_value) != 6:
        return 0, 0, 0, 255
    r = int(hex_value[0:2], 16)
    g = int(hex_value[2:4], 16)
    b = int(hex_value[4:6], 16)
    return r, g, b, 255


def _png_from_pixels(width, height, pixels):
    raw = bytearray()
    stride = width * 4
    for y in range(height):
        raw.append(0)
        start = y * stride
        raw.extend(pixels[start : start + stride])
    compressed = zlib.compress(bytes(raw), level=6)

    def _chunk(tag, payload):
        return (
            struct.pack(">I", len(payload))
            + tag
            + payload
            + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF)
        )

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return (
        PNG_SIGNATURE
        + _chunk(b"IHDR", ihdr)
        + _chunk(b"IDAT", compressed)
        + _chunk(b"IEND", b"")
    )


def _solid_png(width, height, rgba):
    r, g, b, a = rgba
    pixels = bytes([r, g, b, a]) * (width * height)
    return _png_from_pixels(width, height, pixels)


def _banded_png(width, height, palette):
    if not palette:
        return _solid_png(width, height, (0, 0, 0, 0))
    band_height = max(1, height // len(palette))
    pixels = bytearray()
    for y in range(height):
        idx = min(y // band_height, len(palette) - 1)
        r, g, b, a = palette[idx]
        for _ in range(width):
            pixels.extend([r, g, b, a])
    return _png_from_pixels(width, height, bytes(pixels))


def _isolated_png(width, height, rgba, seed):
    r, g, b, a = rgba
    pixels = bytearray()
    for y in range(height):
        for x in range(width):
            if (x * 3 + y * 5 + seed) % 11 == 0:
                pixels.extend([r, g, b, a])
            else:
                pixels.extend([0, 0, 0, 0])
    return _png_from_pixels(width, height, bytes(pixels))


def _infer_png_size(payload):
    if not payload or len(payload) < 24 or payload[:8] != PNG_SIGNATURE:
        return None
    width = struct.unpack(">I", payload[16:20])[0]
    height = struct.unpack(">I", payload[20:24])[0]
    if width <= 0 or height <= 0:
        return None
    return width, height


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

    def _send_png(self, data, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "image/png")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _not_found(self):
        self._send_json({"error": "not found"}, status=404)

    def _read_form(self):
        content_type = self.headers.get("Content-Type", "")
        if content_type.startswith("multipart/form-data"):
            length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(length) if length else b""
            if not body:
                return {}, {}
            header = f"Content-Type: {content_type}\r\n\r\n".encode("utf-8")
            message = BytesParser(policy=policy.default).parsebytes(header + body)
            data = {}
            files = {}
            for part in message.iter_parts():
                name = part.get_param("name", header="Content-Disposition")
                if not name:
                    continue
                filename = part.get_filename()
                payload = part.get_payload(decode=True)
                if filename:
                    files[name] = {"filename": filename, "content": payload or b""}
                else:
                    data[name] = (payload or b"").decode("utf-8")
            return data, files
        if content_type.startswith("application/x-www-form-urlencoded"):
            length = int(self.headers.get("Content-Length", "0"))
            raw = self.rfile.read(length).decode("utf-8") if length else ""
            parsed = parse_qs(raw)
            return {k: v[0] for k, v in parsed.items()}, {}
        return {}, {}

    def _list_settings(self):
        if not os.path.isdir(SETTINGS_DIR):
            return []
        return sorted(
            name
            for name in os.listdir(SETTINGS_DIR)
            if name.lower().endswith(".json")
        )

    def _make_session(self, settings_file, max_colors):
        session_id = str(uuid.uuid4())
        detected_colors = [
            {"id": "A1", "count": 50, "rgba": [255, 0, 0, 255], "hex": "#ff0000"},
            {"id": "B2", "count": 30, "rgba": [0, 255, 0, 255], "hex": "#00ff00"},
            {"id": "C3", "count": 20, "rgba": [0, 0, 255, 255], "hex": "#0000ff"},
        ]
        if max_colors is not None:
            detected_colors = detected_colors[:max(0, min(len(detected_colors), max_colors))]
        payload = {
            "session_id": session_id,
            "total_pixels": 1024,
            "detected_colors": detected_colors,
            "settings_file": settings_file,
            "width": 128,
            "height": 128,
        }
        SESSIONS[session_id] = payload
        return payload

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            self._send_json({"status": "ok"})
            return
        if parsed.path == "/settings/list":
            self._send_json({"files": self._list_settings()})
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
        if parsed.path == "/process":
            data, _files = self._read_form()
            settings_file = str(data.get("settings_file") or "MARD-24.json")
            max_colors = data.get("max_colors")
            mock_flag = str(data.get("mock", "")).lower() in {"1", "true", "yes"}
            width = data.get("width")
            height = data.get("height")
            try:
                max_colors = int(max_colors) if max_colors is not None else None
            except (TypeError, ValueError):
                max_colors = None
            try:
                width = int(width) if width is not None else None
                height = int(height) if height is not None else None
            except (TypeError, ValueError):
                width, height = None, None
            if not mock_flag:
                # This mock server always returns dummy data; keep behavior explicit.
                mock_flag = True
            payload = self._make_session(settings_file, max_colors)
            file_info = _files.get("file")
            if file_info and isinstance(file_info, dict):
                inferred = _infer_png_size(file_info.get("content"))
                if inferred:
                    width, height = inferred
            if width and height:
                payload["width"] = width
                payload["height"] = height
            self._send_json(payload)
            return
        if parsed.path == "/render":
            data, _files = self._read_form()
            session_id = str(data.get("session_id", "")).strip()
            raw_color_id = str(data.get("color_id", "")).strip()
            selected_ids = [
                item.strip() for item in raw_color_id.split(",") if item.strip()
            ]
            if not session_id or session_id not in SESSIONS:
                self._send_json({"error": "invalid session_id"}, status=400)
                return
            session = SESSIONS[session_id]
            width = int(session.get("width") or 128)
            height = int(session.get("height") or 128)
            palette = [
                _rgba_from_hex(color.get("hex"))
                for color in session.get("detected_colors", [])
            ]
            if selected_ids:
                colors_by_id = {
                    str(color.get("id")): _rgba_from_hex(color.get("hex"))
                    for color in session.get("detected_colors", [])
                    if str(color.get("id", "")).strip()
                }
                selected_palette = []
                for color_id in selected_ids:
                    target = colors_by_id.get(color_id)
                    if not target:
                        self._send_json({"error": "invalid color_id"}, status=400)
                        return
                    selected_palette.append(target)
                if len(selected_palette) == 1:
                    seed = sum(bytearray((session_id + selected_ids[0]).encode("utf-8")))
                    image = _isolated_png(width, height, selected_palette[0], seed)
                else:
                    image = _banded_png(width, height, selected_palette)
            else:
                image = _banded_png(width, height, palette)
            self._send_png(image)
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
