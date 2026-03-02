import os
import sqlite3
import subprocess
from datetime import datetime
from pathlib import Path

TRASH_DB = os.path.expanduser("~/.local/share/ranger_trash/trash.db")


def init_db():
    os.makedirs(os.path.dirname(TRASH_DB), exist_ok=True)
    conn = sqlite3.connect(TRASH_DB)
    c = conn.cursor()
    c.execute("""CREATE TABLE IF NOT EXISTS trash (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_path TEXT NOT NULL,
        trash_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        deleted_at TEXT NOT NULL,
        file_size INTEGER,
        is_directory INTEGER
    )""")
    conn.commit()
    conn.close()


def add_to_trash(original_path, trash_path, file_name, is_directory):
    conn = sqlite3.connect(TRASH_DB)
    c = conn.cursor()
    file_size = (
        os.path.getsize(os.path.join(trash_path, "files", file_name))
        if os.path.exists(os.path.join(trash_path, "files", file_name))
        else 0
    )
    c.execute(
        "INSERT INTO trash (original_path, trash_path, file_name, deleted_at, file_size, is_directory) VALUES (?, ?, ?, ?, ?, ?)",
        (
            original_path,
            trash_path,
            file_name,
            datetime.now().isoformat(),
            file_size,
            1 if is_directory else 0,
        ),
    )
    conn.commit()
    conn.close()


def get_all_trash():
    conn = sqlite3.connect(TRASH_DB)
    c = conn.cursor()
    c.execute(
        "SELECT id, original_path, trash_path, file_name, deleted_at FROM trash ORDER BY deleted_at DESC"
    )
    rows = c.fetchall()
    conn.close()
    return rows


def find_in_trash(original_path):
    conn = sqlite3.connect(TRASH_DB)
    c = conn.cursor()
    c.execute(
        "SELECT id, trash_path, file_name FROM trash WHERE original_path = ?",
        (original_path,),
    )
    row = c.fetchone()
    conn.close()
    return row


def find_by_filename(file_name):
    conn = sqlite3.connect(TRASH_DB)
    c = conn.cursor()
    c.execute(
        "SELECT id, original_path, trash_path, file_name FROM trash WHERE file_name = ?",
        (file_name,),
    )
    rows = c.fetchall()
    conn.close()
    return rows


def remove_from_trash(original_path):
    conn = sqlite3.connect(TRASH_DB)
    c = conn.cursor()
    c.execute("DELETE FROM trash WHERE original_path = ?", (original_path,))
    conn.commit()
    conn.close()


init_db()
