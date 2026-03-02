import os
import shutil
import subprocess
from urllib.parse import unquote
from ranger.api.commands import Command
from .trash_lib import (
    get_all_trash,
    find_in_trash,
    remove_from_trash,
    add_to_trash,
    TRASH_DB,
)


def get_trash_path(original_path, username):
    """Get appropriate trash location based on where the file was"""

    # Check /run/media/<user>/<mount>/
    if original_path.startswith(f"/run/media/{username}/"):
        parts = original_path.split("/")
        if len(parts) >= 5:
            mount = parts[4]
            trash_path = f"/run/media/{username}/{mount}/.Trash-1000"
            os.makedirs(os.path.join(trash_path, "files"), exist_ok=True)
            os.makedirs(os.path.join(trash_path, "info"), exist_ok=True)
            return trash_path

    # Check /media/<user>/<mount>/
    if original_path.startswith(f"/media/{username}/"):
        parts = original_path.split("/")
        if len(parts) >= 5:
            mount = parts[4]
            trash_path = f"/media/{username}/{mount}/.Trash-1000"
            os.makedirs(os.path.join(trash_path, "files"), exist_ok=True)
            os.makedirs(os.path.join(trash_path, "info"), exist_ok=True)
            return trash_path

    # Check /mnt/<mount>/
    if original_path.startswith("/mnt/"):
        parts = original_path.split("/")
        if len(parts) >= 3:
            mount = parts[2]
            trash_path = f"/mnt/{mount}/.Trash-1000"
            os.makedirs(os.path.join(trash_path, "files"), exist_ok=True)
            os.makedirs(os.path.join(trash_path, "info"), exist_ok=True)
            return trash_path

    # Default to home trash
    trash_dir = os.path.expanduser("~/.local/share/Trash")
    os.makedirs(os.path.join(trash_dir, "files"), exist_ok=True)
    os.makedirs(os.path.join(trash_dir, "info"), exist_ok=True)
    return trash_dir


def scan_system_trash(username):
    items = []
    bases = [
        f"/run/media/{username}",
        f"/media/{username}",
        "/mnt",
        "/run/media",
        "/media",
    ]

    for base in bases:
        if not os.path.exists(base):
            continue
        try:
            for mount in os.listdir(base):
                trash_path = os.path.join(base, mount, ".Trash-1000")
                if os.path.exists(trash_path):
                    info_dir = os.path.join(trash_path, "info")
                    files_dir = os.path.join(trash_path, "files")
                    if os.path.exists(info_dir) and os.path.exists(files_dir):
                        for f in os.listdir(files_dir):
                            info_file = os.path.join(info_dir, f + ".trashinfo")
                            if os.path.exists(info_file):
                                with open(info_file) as fh:
                                    for line in fh:
                                        if line.startswith("Path="):
                                            orig_path = unquote(line[5:].strip())
                                            if not orig_path.startswith("/"):
                                                orig_path = "/" + orig_path
                                            # Fix: prepend mount point for relative paths
                                            if orig_path.count("/") < 2:
                                                orig_path = "/" + mount + orig_path
                                            items.append(
                                                {
                                                    "original_path": orig_path,
                                                    "trash_path": trash_path,
                                                    "file_name": f,
                                                    "is_system": True,
                                                }
                                            )
                                            break
        except PermissionError:
            pass

    return items


class trashrestore(Command):
    def execute(self):
        username = subprocess.run(
            ["id", "-nu"], capture_output=True, text=True
        ).stdout.strip()

        pwd_output = subprocess.run(
            ["pwd"], capture_output=True, text=True
        ).stdout.strip()
        current_dir = pwd_output

        rows = get_all_trash()
        system_items = scan_system_trash(username)

        all_items = []

        for row in rows:
            all_items.append(
                {
                    "original_path": row[1],
                    "trash_path": row[2],
                    "file_name": row[3],
                    "is_system": False,
                }
            )

        for item in system_items:
            exists_in_db = any(
                x["original_path"] == item["original_path"] for x in all_items
            )
            if not exists_in_db:
                all_items.append(item)

        if not all_items:
            self.fm.notify("Trash is empty!", bad=True)
            return

        lines = [
            f"{item['file_name']} | {item['original_path']} -> {item['trash_path']}"
            for item in all_items
        ]

        fzf = subprocess.Popen(
            ["fzf", "--prompt", "Restore> ", "--multi"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        )
        stdout, _ = fzf.communicate(input="\n".join(lines))

        if fzf.returncode != 0 or not stdout.strip():
            return

        selected = stdout.strip().split("\n")

        for s in selected:
            parts = s.split(" | ")
            file_name = parts[0]
            original_path = parts[1].split(" -> ")[0]

            src = None

            # Check ranger trash first
            db_result = find_in_trash(original_path)
            if db_result:
                trash_id, trash_path, trash_name = db_result
                test_src = os.path.join(trash_path, "files", trash_name)
                if os.path.exists(test_src):
                    src = test_src

            # Find in system trashes
            if not src:
                for base in [f"/run/media/{username}", f"/media/{username}", "/mnt"]:
                    if not os.path.exists(base):
                        continue
                    try:
                        for mount in os.listdir(base):
                            trash_path = os.path.join(base, mount, ".Trash-1000")
                            if os.path.exists(trash_path):
                                files_dir = os.path.join(trash_path, "files")
                                if os.path.exists(files_dir):
                                    test_src = os.path.join(files_dir, file_name)
                                    if os.path.exists(test_src):
                                        src = test_src
                                        # Fix path: prepend mount point if needed
                                        if not original_path.startswith("/"):
                                            original_path = os.path.join(
                                                current_dir, original_path
                                            )
                                        elif original_path.count("/") < 2:
                                            original_path = "/" + mount + original_path
                                        break
                    except PermissionError:
                        pass

            if not src:
                self.fm.notify(f"Not found: {file_name}", bad=True)
                continue

            result = subprocess.run(
                ["mv", src, original_path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
            )

            if result.returncode == 0 and os.path.exists(original_path):
                # Remove from DB or system trash
                if src.startswith(os.path.expanduser("~/.local/share")):
                    remove_from_trash(original_path)
                else:
                    # Remove info file from system trash
                    for base in [
                        f"/run/media/{username}",
                        f"/media/{username}",
                        "/mnt",
                    ]:
                        if src.startswith(base):
                            mount = os.path.basename(os.path.dirname(src))
                            trash_base = os.path.join(base, mount, ".Trash-1000")
                            info_file = os.path.join(
                                trash_base, "info", file_name + ".trashinfo"
                            )
                            if os.path.exists(info_file):
                                os.remove(info_file)
                            break
                self.fm.notify(f"Restored: {file_name}")
            else:
                self.fm.notify(f"Failed: {file_name}", bad=True)


class trash(Command):
    def execute(self):
        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return

        username = subprocess.run(
            ["id", "-nu"], capture_output=True, text=True
        ).stdout.strip()

        for f in selected_files:
            file_name = os.path.basename(f)
            is_dir = os.path.isdir(f)

            trash_path = get_trash_path(f, username)
            trash_files = os.path.join(trash_path, "files")

            unique_name = file_name
            counter = 1
            while os.path.exists(os.path.join(trash_files, unique_name)):
                if "." in file_name:
                    parts = file_name.rsplit(".", 1)
                    unique_name = f"{parts[0]}_{counter}.{parts[1]}"
                else:
                    unique_name = f"{file_name}_{counter}"
                counter += 1

            src = f
            dst = os.path.join(trash_files, unique_name)

            try:
                shutil.move(src, dst)
                add_to_trash(f, trash_path, unique_name, is_dir)

                if ".Trash-1000" in trash_path:
                    info_file = os.path.join(
                        trash_path, "info", unique_name + ".trashinfo"
                    )
                    with open(info_file, "w") as fh:
                        fh.write(
                            f"[Trash Info]\nPath={f}\nDeletionDate={subprocess.run(['date', '+%Y-%m-%dT%H:%M:%S'], capture_output=True, text=True).stdout.strip()}\n"
                        )
            except Exception as e:
                self.fm.notify(f"Error: {e}", bad=True)

        self.fm.notify(f"Trashed {len(selected_files)} file(s)")


class trashrm(Command):
    def execute(self):
        username = subprocess.run(
            ["id", "-nu"], capture_output=True, text=True
        ).stdout.strip()

        rows = get_all_trash()
        system_items = scan_system_trash(username)

        all_items = []

        for row in rows:
            all_items.append(
                {
                    "original_path": row[1],
                    "trash_path": row[2],
                    "file_name": row[3],
                    "is_system": False,
                }
            )

        for item in system_items:
            exists_in_db = any(
                x["original_path"] == item["original_path"] for x in all_items
            )
            if not exists_in_db:
                all_items.append(item)

        if not all_items:
            self.fm.notify("Trash is empty!", bad=True)
            return

        lines = [
            f"{item['file_name']} | {item['original_path']} -> {item['trash_path']}"
            for item in all_items
        ]

        fzf = subprocess.Popen(
            ["fzf", "--prompt", "Delete> ", "--multi"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        )
        stdout, _ = fzf.communicate(input="\n".join(lines))

        if fzf.returncode != 0 or not stdout.strip():
            return

        selected = stdout.strip().split("\n")

        for s in selected:
            parts = s.split(" | ")
            file_name = parts[0]
            original_path = parts[1].split(" -> ")[0]

            src = None

            # Check ranger trash first
            db_result = find_in_trash(original_path)
            if db_result:
                trash_id, trash_path, trash_name = db_result
                test_src = os.path.join(trash_path, "files", trash_name)
                if os.path.exists(test_src):
                    src = test_src

            # Find in system trashes
            if not src:
                for base in [f"/run/media/{username}", f"/media/{username}", "/mnt"]:
                    if not os.path.exists(base):
                        continue
                    try:
                        for mount in os.listdir(base):
                            trash_path = os.path.join(base, mount, ".Trash-1000")
                            if os.path.exists(trash_path):
                                files_dir = os.path.join(trash_path, "files")
                                if os.path.exists(files_dir):
                                    test_src = os.path.join(files_dir, file_name)
                                    if os.path.exists(test_src):
                                        src = test_src
                                        break
                    except PermissionError:
                        pass

            if not src:
                self.fm.notify(f"Not found: {file_name}", bad=True)
                continue

            result = subprocess.run(
                ["rm", "-rf", src],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
            )

            if result.returncode == 0:
                # Remove from DB
                remove_from_trash(original_path)

                # Remove info file from system trash
                for base in [f"/run/media/{username}", f"/media/{username}", "/mnt"]:
                    if src.startswith(base):
                        mount = os.path.basename(os.path.dirname(src))
                        trash_base = os.path.join(base, mount, ".Trash-1000")
                        info_file = os.path.join(
                            trash_base, "info", file_name + ".trashinfo"
                        )
                        if os.path.exists(info_file):
                            os.remove(info_file)
                        break
                self.fm.notify(f"Deleted: {file_name}")
            else:
                self.fm.notify(f"Failed: {file_name}", bad=True)
