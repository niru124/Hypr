import os
import subprocess
from ranger.api.commands import Command

class fzf_e(Command):
    def execute(self):
        fzf = subprocess.Popen(
            ['fzf', '--prompt', 'e> '],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True, cwd=self.fm.thisdir.path
        )
        items = subprocess.run(
            ['find', '-maxdepth', '1', '(', '-type', 'f', '-o', '-type', 'd', ')', '-printf', '%f\n'],
            capture_output=True, text=True, cwd=self.fm.thisdir.path
        ).stdout
        stdout, _ = fzf.communicate(items)
        if fzf.returncode == 0 and stdout.strip():
            selected = stdout.strip()
            path = os.path.join(self.fm.thisdir.path, selected)
            if os.path.isdir(path):
                self.fm.cd(selected)
            else:
                self.fm.select_file(path)

class fzf_E(Command):
    def execute(self):
        fzf = subprocess.Popen(
            ['fzf', '--prompt', 'E> '],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True, cwd=self.fm.thisdir.path
        )
        items = subprocess.run(
            ['find', '.', '(', '-type', 'f', '-o', '-type', 'd', ')', '-printf', '%P\n'],
            capture_output=True, text=True, cwd=self.fm.thisdir.path
        ).stdout
        stdout, _ = fzf.communicate(items)
        if fzf.returncode == 0 and stdout.strip():
            selected = stdout.strip()
            path = os.path.join(self.fm.thisdir.path, selected)
            if os.path.isdir(path):
                self.fm.cd(selected)
            else:
                self.fm.select_file(path)

class wormhole_send(Command):
    def execute(self):
        import os
        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return

        wrapper = os.path.expanduser("~/.config/ranger/wormhole_wrapper.sh")
        self.fm.run([wrapper] + selected_files)
