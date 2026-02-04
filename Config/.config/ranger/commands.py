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
        files_str = " ".join([f'"{f}"' for f in selected_files])
        subprocess.Popen(['/bin/bash', '-c', f'{wrapper} {files_str}'], 
                       start_new_session=True, 
                       stdout=subprocess.DEVNULL, 
                       stderr=subprocess.DEVNULL)

class fzf_open_with(Command):
    def execute(self):
        import os
        
        selected_files = [f for f in self.fm.thistab.get_selection()]
        if not selected_files:
            selected_file = self.fm.thisfile
            selected_files = [selected_file]
        
        is_dir = any(f.is_directory for f in selected_files)
        has_multiple = len(selected_files) > 1
        
        preconfigured_commands = {}
        
        if is_dir:
            preconfigured_commands = {
                'xdg-open': 'xdg-open {}',
            }
        else:
            selected_file = selected_files[0]
            ext = os.path.splitext(selected_file.path)[1].lower()
            
            image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.tiff', '.tif'}
            pdf_extensions = {'.pdf','odf','.pub'}
            video_extensions = {'.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.wmv', '.m4v'}
            audio_extensions = {'.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.wma'}
            text_extensions = {'.txt', '.md', '.py', '.js', '.ts', '.json', '.yaml', '.yml', '.xml', '.html', '.css', '.sh', '.c', '.cpp', '.h', '.hpp', '.rs', '.go', '.java'}
            archive_extensions = {'.zip', '.tar', '.gz', '.bz2', '.xz', '.7z', '.rar'}
            
            if ext in image_extensions:
                import os
                base_name = os.path.splitext(selected_file.path)[0]
                preconfigured_commands = {
                    'nsxiv': 'nsxiv {}',
                    'feh': 'feh {}',
                    'satty': f'satty -f {{}} -o "{base_name}-edited.png"',
                    'xdg-open': 'xdg-open {}',
                    'fotokilof': 'fotokilof {}',
                }
            elif ext in video_extensions:
                preconfigured_commands = {
                    'mpv': 'mpv {}',
                    'vlc': 'vlc {}',
                    'xdg-open': 'xdg-open {}',
                }

            elif ext in pdf_extensions:
                preconfigured_commands = {
                    'evince': 'evince {}',
                    'zathura': 'zathura {}',
                }
            elif ext in audio_extensions:
                preconfigured_commands = {
                    'mpv': 'mpv {}',
                    'vlc': 'vlc {}',
                    'xdg-open': 'xdg-open {}',
                }
            elif ext in text_extensions:
                preconfigured_commands = {
                    'vim': 'vim {}',
                    'nvim': 'nvim {}',
                    'code': 'code {}',
                    'less': 'less {}',
                    'cat': 'cat {}',
                    'xdg-open': 'xdg-open {}',
                }
            elif ext in archive_extensions:
                preconfigured_commands = {
                    'unzip': f'unzip -d "{os.path.splitext(selected_file.path)[0]}" {{}}',
                    'xdg-open': 'xdg-open {}',
                }
            else:
                preconfigured_commands = {
                    'xdg-open': 'xdg-open {}',
                    'less': 'less {}',
                    'cat': 'cat {}',
                }
        
        command_list = list(preconfigured_commands.keys())
        
        fzf = subprocess.Popen(
            ['fzf', '--prompt', 'Open with> ', '--header', 'Select a program or type custom command'],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
        )
        
        input_text = '\n'.join(command_list) + '\n'
        stdout, _ = fzf.communicate(input_text)
        
        if fzf.returncode == 0 and stdout.strip():
            selection = stdout.strip()
            command_template = preconfigured_commands.get(selection, selection)
            
            if has_multiple:
                files_str = " ".join([f'"{f.path}"' for f in selected_files])
                cmd = command_template.replace('{}', files_str)
            else:
                cmd = command_template.replace('{}', selected_files[0].path)
            
            subprocess.Popen(['/bin/bash', '-c', cmd], 
                           start_new_session=True, 
                           stdout=subprocess.DEVNULL, 
                           stderr=subprocess.DEVNULL)
    
    def tab(self, tabnum):
        return ['']

class zip(Command):
    def execute(self):
        if not self.arg(1):
            self.fm.notify("Usage: zip <archive_name>", bad=True)
            return
        
        archive_name = self.arg(1)
        if not archive_name.endswith('.zip'):
            archive_name += '.zip'
        
        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return
        
        archive_path = os.path.join(self.fm.thisdir.path, archive_name)
        files_str = " ".join([f'"{f}"' for f in selected_files])
        subprocess.Popen(['/bin/bash', '-c', f'zip -r "{archive_path}" {files_str}'], 
                       start_new_session=True, 
                       stdout=subprocess.DEVNULL, 
                       stderr=subprocess.DEVNULL)
    
    def tab(self, tabnum):
        return ['']

class unzip(Command):
    def execute(self):
        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return
        
        for zip_file in selected_files:
            if not zip_file.endswith('.zip'):
                self.fm.notify(f"Not a zip file: {os.path.basename(zip_file)}", bad=True)
                continue
            
            extract_dir = os.path.join(self.fm.thisdir.path, os.path.basename(zip_file)[:-4])
            subprocess.Popen(['/bin/bash', '-c', f'unzip -d "{extract_dir}" "{zip_file}"'], 
                           start_new_session=True, 
                           stdout=subprocess.DEVNULL, 
                           stderr=subprocess.DEVNULL)
    
    def tab(self, tabnum):
        return ['']
