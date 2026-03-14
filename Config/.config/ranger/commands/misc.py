import os
import subprocess
from ranger.api.commands import Command


class mkfile(Command):
    def execute(self):
        filename = self.arg(1)
        if not filename:
            self.fm.notify("No name provided", bad=True)
            return

        target = os.path.join(self.fm.thisdir.path, filename.rstrip("/"))

        if filename.endswith("/"):
            try:
                os.makedirs(target, exist_ok=True)
                self.fm.notify(f"Created directory: {filename}")
            except Exception as e:
                self.fm.notify(f"Error: {e}", bad=True)
        else:
            try:
                os.mknod(target)
                self.fm.notify(f"Created file: {filename}")
            except Exception as e:
                self.fm.notify(f"Error: {e}", bad=True)


class wormhole_send(Command):
    def execute(self):
        import os

        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return

        wrapper = os.path.expanduser("~/.config/ranger/wormhole_wrapper.sh")
        files_str = " ".join([f'"{f}"' for f in selected_files])
        subprocess.Popen(
            ["/bin/bash", "-c", f"{wrapper} {files_str}"],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
