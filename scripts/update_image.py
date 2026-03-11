#!/usr/bin/env python3
"""Upload a local image to the Android emulator gallery via ADB."""

from __future__ import annotations

import os
import shlex
import shutil
import subprocess
import threading
from datetime import datetime
from pathlib import Path
from tkinter import filedialog, messagebox, ttk
import tkinter as tk


WINDOW_TITLE = "PixelPad 图片上传到模拟器相册"
DEVICE_ID = "emulator-5554"
REMOTE_DIR = "/sdcard/DCIM/Camera"
ADB_CANDIDATES = ("/home/cqc/Android/Sdk/platform-tools/adb",)
IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".bmp"}


def find_adb() -> str:
    for candidate in ADB_CANDIDATES:
        if Path(candidate).is_file() and os.access(candidate, os.X_OK):
            return candidate

    adb_path = shutil.which("adb")
    if adb_path:
        return adb_path

    raise RuntimeError("未找到 adb，请确认 Android SDK platform-tools 已安装。")


def extract_process_details(process: subprocess.CompletedProcess[str]) -> str:
    parts = []
    stdout = (process.stdout or "").strip()
    stderr = (process.stderr or "").strip()
    if stdout:
        parts.append(f"stdout: {stdout}")
    if stderr:
        parts.append(f"stderr: {stderr}")
    return "\n".join(parts)


def run_adb(
    adb_path: str,
    args: list[str],
    *,
    check: bool = True,
    timeout: int = 30,
) -> subprocess.CompletedProcess[str]:
    try:
        process = subprocess.run(
            [adb_path, "-s", DEVICE_ID, *args],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"ADB 命令执行超时：{' '.join(args)}") from exc
    if check and process.returncode != 0:
        detail = extract_process_details(process)
        message = "ADB 命令执行失败。"
        if detail:
            message = f"{message}\n{detail}"
        raise RuntimeError(message)
    return process


def build_device_error(process: subprocess.CompletedProcess[str]) -> str:
    detail = extract_process_details(process)
    combined = "\n".join(
        part for part in ((process.stdout or "").strip(), (process.stderr or "").strip()) if part
    )
    lowered = combined.lower()

    if "offline" in lowered:
        reason = f"设备 {DEVICE_ID} 当前处于 offline 状态。"
    elif "device not found" in lowered or "no devices" in lowered:
        reason = f"未找到目标设备 {DEVICE_ID}。"
    elif "cannot connect" in lowered or "connection refused" in lowered:
        reason = "ADB 无法连接到目标模拟器。"
    elif "daemon" in lowered or "vsock" in lowered or "socket" in lowered:
        reason = "ADB 服务启动或连接异常。"
    else:
        reason = f"无法确认设备 {DEVICE_ID} 已就绪。"

    lines = [
        reason,
        "请先确认 Android 模拟器已启动。",
        f"请在当前终端确认 `adb devices` 或 `flutter devices` 能看到 `{DEVICE_ID}`。",
    ]
    if detail:
        lines.append(detail)
    return "\n".join(lines)


def check_device_ready(adb_path: str) -> None:
    try:
        process = subprocess.run(
            [adb_path, "-s", DEVICE_ID, "get-state"],
            capture_output=True,
            text=True,
            timeout=20,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(
            "检测设备状态超时，请确认模拟器和 ADB 服务运行正常。"
        ) from exc
    state = (process.stdout or "").strip()
    if process.returncode != 0 or state != "device":
        raise RuntimeError(build_device_error(process))


def validate_image(path_str: str) -> Path:
    if not path_str:
        raise RuntimeError("请先选择一张图片。")

    path = Path(path_str).expanduser()
    if not path.exists():
        raise RuntimeError("所选图片不存在，可能已被移动或删除。")
    if not path.is_file():
        raise RuntimeError("所选路径不是文件，请重新选择图片。")
    if path.suffix.lower() not in IMAGE_SUFFIXES:
        raise RuntimeError("请选择图片文件。")
    return path


def select_image(state: dict[str, object]) -> None:
    file_path = filedialog.askopenfilename(
        title="选择要上传的图片",
        filetypes=[
            ("图片文件", "*.png *.jpg *.jpeg *.webp *.bmp"),
            ("PNG 图片", "*.png"),
            ("JPEG 图片", "*.jpg *.jpeg"),
            ("WEBP 图片", "*.webp"),
            ("BMP 图片", "*.bmp"),
        ],
    )
    if not file_path:
        return

    try:
        image_path = validate_image(file_path)
    except RuntimeError as exc:
        set_status(state, str(exc), level="error")
        messagebox.showerror("选择失败", str(exc))
        return

    path_var = state["path_var"]
    upload_button = state["upload_button"]
    assert isinstance(path_var, tk.StringVar)
    assert isinstance(upload_button, ttk.Button)

    path_var.set(str(image_path))
    upload_button.configure(state="normal")
    set_status(state, "图片已选择，可以上传到模拟器相册。", level="info")


def ensure_remote_dir(adb_path: str) -> None:
    run_adb(adb_path, ["shell", f"mkdir -p {shlex.quote(REMOTE_DIR)}"])


def remote_exists(adb_path: str, remote_path: str) -> bool:
    process = run_adb(
        adb_path,
        ["shell", f"if [ -e {shlex.quote(remote_path)} ]; then echo 1; else echo 0; fi"],
    )
    lines = [line.strip() for line in (process.stdout or "").splitlines() if line.strip()]
    return bool(lines) and lines[-1] == "1"


def resolve_remote_filename(adb_path: str, local_path: Path) -> str:
    remote_path = f"{REMOTE_DIR}/{local_path.name}"
    if not remote_exists(adb_path, remote_path):
        return remote_path

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    renamed = f"{local_path.stem}_{timestamp}{local_path.suffix}"
    return f"{REMOTE_DIR}/{renamed}"


def push_file(adb_path: str, local_path: Path, remote_path: str) -> None:
    try:
        process = subprocess.run(
            [adb_path, "-s", DEVICE_ID, "push", str(local_path), remote_path],
            capture_output=True,
            text=True,
            timeout=120,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError("图片上传超时，请稍后重试。") from exc
    if process.returncode != 0:
        detail = extract_process_details(process)
        message = "图片上传失败。"
        if detail:
            message = f"{message}\n{detail}"
        raise RuntimeError(message)


def refresh_media_store(adb_path: str, remote_path: str) -> str | None:
    attempts = [
        ["shell", f"cmd media rescan {shlex.quote(remote_path)}"],
        [
            "shell",
            "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE "
            f"-d {shlex.quote(f'file://{remote_path}')}",
        ],
    ]
    failures = []

    for args in attempts:
        try:
            process = subprocess.run(
                [adb_path, "-s", DEVICE_ID, *args],
                capture_output=True,
                text=True,
                timeout=30,
            )
        except subprocess.TimeoutExpired:
            failures.append(f"{' '.join(args)}\n命令执行超时")
            continue
        if process.returncode == 0:
            return None
        detail = extract_process_details(process)
        command = " ".join(args)
        failures.append(f"{command}\n{detail}".strip())

    return "\n\n".join(failures) if failures else "媒体库刷新失败。"


def set_status(state: dict[str, object], message: str, *, level: str) -> None:
    status_var = state["status_var"]
    status_label = state["status_label"]
    assert isinstance(status_var, tk.StringVar)
    assert isinstance(status_label, tk.Label)

    color_map = {
        "info": "#1f2937",
        "success": "#166534",
        "warning": "#9a3412",
        "error": "#b91c1c",
    }
    status_var.set(message)
    status_label.configure(foreground=color_map.get(level, color_map["info"]))


def upload_selected_image(state: dict[str, object]) -> None:
    path_var = state["path_var"]
    select_button = state["select_button"]
    upload_button = state["upload_button"]
    root = state["root"]
    assert isinstance(path_var, tk.StringVar)
    assert isinstance(select_button, ttk.Button)
    assert isinstance(upload_button, ttk.Button)
    assert isinstance(root, tk.Tk)

    selected_path = path_var.get().strip()
    try:
        validate_image(selected_path)
    except RuntimeError as exc:
        set_status(state, str(exc), level="error")
        upload_button.configure(state="disabled")
        messagebox.showerror("上传失败", str(exc))
        return

    select_button.configure(state="disabled")
    upload_button.configure(state="disabled")
    set_status(state, "上传中，请稍候...", level="info")

    worker = threading.Thread(
        target=perform_upload,
        args=(state, selected_path),
        daemon=True,
    )
    worker.start()


def perform_upload(state: dict[str, object], selected_path: str) -> None:
    root = state["root"]
    assert isinstance(root, tk.Tk)

    try:
        local_path = validate_image(selected_path)
        adb_path = find_adb()
        check_device_ready(adb_path)
        ensure_remote_dir(adb_path)
        remote_path = resolve_remote_filename(adb_path, local_path)
        push_file(adb_path, local_path, remote_path)
        refresh_error = refresh_media_store(adb_path, remote_path)

        if refresh_error:
            root.after(0, handle_upload_warning, state, remote_path, refresh_error)
        else:
            root.after(0, handle_upload_success, state, remote_path)
    except Exception as exc:
        root.after(0, handle_upload_error, state, str(exc))


def restore_buttons(state: dict[str, object]) -> None:
    select_button = state["select_button"]
    upload_button = state["upload_button"]
    path_var = state["path_var"]
    assert isinstance(select_button, ttk.Button)
    assert isinstance(upload_button, ttk.Button)
    assert isinstance(path_var, tk.StringVar)

    select_button.configure(state="normal")
    try:
        validate_image(path_var.get().strip())
    except RuntimeError:
        upload_button.configure(state="disabled")
    else:
        upload_button.configure(state="normal")


def handle_upload_success(state: dict[str, object], remote_path: str) -> None:
    restore_buttons(state)
    message = (
        "上传成功。\n"
        f"设备：{DEVICE_ID}\n"
        f"目标路径：{remote_path}"
    )
    set_status(state, "图片已成功上传并触发媒体库刷新。", level="success")
    messagebox.showinfo("上传成功", message)


def handle_upload_warning(state: dict[str, object], remote_path: str, detail: str) -> None:
    restore_buttons(state)
    message = (
        "文件已上传，但媒体库刷新失败，可能需要稍后在相册中出现。\n"
        f"设备：{DEVICE_ID}\n"
        f"目标路径：{remote_path}"
    )
    set_status(state, message, level="warning")
    messagebox.showwarning("上传完成", f"{message}\n\n诊断信息：\n{detail}")


def handle_upload_error(state: dict[str, object], detail: str) -> None:
    restore_buttons(state)
    set_status(state, detail, level="error")
    messagebox.showerror("上传失败", detail)


def build_gui() -> dict[str, object]:
    root = tk.Tk()
    root.title(WINDOW_TITLE)
    root.geometry("760x230")
    root.resizable(False, False)
    root.columnconfigure(0, weight=1)

    main_frame = ttk.Frame(root, padding=16)
    main_frame.grid(row=0, column=0, sticky="nsew")
    main_frame.columnconfigure(0, weight=1)

    info_text = f"目标设备：{DEVICE_ID}    目标目录：{REMOTE_DIR}"
    ttk.Label(main_frame, text=info_text).grid(row=0, column=0, sticky="w")

    ttk.Label(main_frame, text="本地图片").grid(row=1, column=0, sticky="w", pady=(14, 6))

    path_var = tk.StringVar()
    path_entry = ttk.Entry(main_frame, textvariable=path_var, state="readonly", width=96)
    path_entry.grid(row=2, column=0, sticky="ew")

    button_frame = ttk.Frame(main_frame)
    button_frame.grid(row=3, column=0, sticky="w", pady=(14, 10))

    select_button = ttk.Button(button_frame, text="选择图片")
    select_button.grid(row=0, column=0, padx=(0, 8))

    upload_button = ttk.Button(button_frame, text="上传到模拟器相册", state="disabled")
    upload_button.grid(row=0, column=1)

    ttk.Label(main_frame, text="状态").grid(row=4, column=0, sticky="w", pady=(8, 6))

    status_var = tk.StringVar(value="请选择一张图片后上传到模拟器相册。")
    status_label = tk.Label(
        main_frame,
        textvariable=status_var,
        justify="left",
        wraplength=720,
        anchor="w",
        fg="#1f2937",
    )
    status_label.grid(row=5, column=0, sticky="w")

    state: dict[str, object] = {
        "root": root,
        "path_var": path_var,
        "status_var": status_var,
        "status_label": status_label,
        "select_button": select_button,
        "upload_button": upload_button,
    }

    select_button.configure(command=lambda: select_image(state))
    upload_button.configure(command=lambda: upload_selected_image(state))
    set_status(state, "请选择一张图片后上传到模拟器相册。", level="info")
    return state


def main() -> None:
    state = build_gui()
    root = state["root"]
    assert isinstance(root, tk.Tk)
    root.mainloop()


if __name__ == "__main__":
    main()
