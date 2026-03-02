import os
import subprocess
from ranger.api.commands import Command


class zip(Command):
    def execute(self):
        if not self.arg(1):
            self.fm.notify("Usage: zip <archive_name>", bad=True)
            return

        archive_name = self.arg(1)
        if not archive_name.endswith(".zip"):
            archive_name += ".zip"

        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return

        archive_path = os.path.join(self.fm.thisdir.path, archive_name)
        files_str = " ".join([f'"{f}"' for f in selected_files])
        subprocess.Popen(
            ["/bin/bash", "-c", f'zip -r "{archive_path}" {files_str}'],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def tab(self, tabnum):
        return [""]


class unzip(Command):
    def execute(self):
        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return

        for zip_file in selected_files:
            if not zip_file.endswith(".zip"):
                self.fm.notify(
                    f"Not a zip file: {os.path.basename(zip_file)}", bad=True
                )
                continue

            extract_dir = os.path.join(
                self.fm.thisdir.path, os.path.basename(zip_file)[:-4]
            )
            subprocess.Popen(
                ["/bin/bash", "-c", f'unzip -d "{extract_dir}" "{zip_file}"'],
                start_new_session=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    def tab(self, tabnum):
        return [""]
