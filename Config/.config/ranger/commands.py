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
