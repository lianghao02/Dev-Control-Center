"""環境修復邊界：檢查模式、錯誤版本、原始資料與選用功能。"""
from __future__ import annotations

import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
SHELL = shutil.which('pwsh.exe') or shutil.which('powershell.exe')
PROJECTS = ('10_Smart-Photo-Organizer', '12_ClipMask-AI', '15_chainflow-inspector')


def run(*args):
    return subprocess.run(args, capture_output=True, text=True, encoding='utf-8', errors='replace')


class EnvironmentBoundaries(unittest.TestCase):
    def test_application_arguments_are_not_bound_to_setup_parameters(self):
        python313 = Path(os.environ['LOCALAPPDATA']) / 'Programs/Python/Python313/python.exe'
        with tempfile.TemporaryDirectory(prefix='啟動 參數-') as directory:
            target = Path(directory).resolve()
            self.assertTrue(target.is_relative_to(Path(tempfile.gettempdir()).resolve()))
            # 只測啟動器的參數邊界，測試程式使用標準庫，避免安裝 GUI 套件。
            setup = (ROOT / PROJECTS[2] / 'setup_and_run.ps1').read_text(encoding='utf-8')
            (target / 'setup_and_run.ps1').write_text(setup.replace("'tkinter,sqlite3,webview'", "'tkinter,sqlite3'"), encoding='utf-8')
            (target / 'requirements.txt').write_text('', encoding='utf-8')
            (target / 'app.py').write_text('import json,sys; print(json.dumps(sys.argv[1:],ensure_ascii=True))', encoding='utf-8')
            result = run(str(python313), '-B', '-m', 'venv', str(target / '.venv'))
            self.assertEqual(result.returncode, 0, result.stderr)
            expected = ['含 空白.txt', '--flag', '值']
            result = run(SHELL, '-NoProfile', '-File', str(target / 'setup_and_run.ps1'), *expected)
            self.assertEqual(result.returncode, 0, result.stderr)
            import json
            self.assertEqual(json.loads(result.stdout.splitlines()[-1]), expected)

    def test_check_only_missing_environment_does_not_create_files(self):
        for project in PROJECTS:
            with self.subTest(project=project), tempfile.TemporaryDirectory(prefix='環境 缺失-') as directory:
                target = Path(directory).resolve()
                self.assertTrue(target.is_relative_to(Path(tempfile.gettempdir()).resolve()))
                for filename in ('setup_and_run.ps1', 'requirements.txt'):
                    shutil.copy2(ROOT / project / filename, target / filename)
                before = {p.name: p.read_bytes() for p in target.iterdir()}
                result = run(SHELL, '-NoProfile', '-File', str(target / 'setup_and_run.ps1'), '-CheckOnly')
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(before, {p.name: p.read_bytes() for p in target.iterdir()})

    def test_wrong_minor_is_preserved_and_never_installs(self):
        python314 = Path(os.environ['LOCALAPPDATA']) / 'Programs/Python/Python314/python.exe'
        with tempfile.TemporaryDirectory(prefix='環境 錯誤版本-') as directory:
            target = Path(directory).resolve()
            self.assertTrue(target.is_relative_to(Path(tempfile.gettempdir()).resolve()))
            for filename in ('setup_and_run.ps1', 'requirements.txt'):
                shutil.copy2(ROOT / PROJECTS[2] / filename, target / filename)
            result = run(str(python314), '-B', '-m', 'venv', str(target / '.venv'))
            self.assertEqual(result.returncode, 0, result.stderr)
            python = target / '.venv/Scripts/python.exe'
            before = run(str(python), '-B', '-s', '-m', 'pip', 'list', '--format=json').stdout
            cfg = (target / '.venv/pyvenv.cfg').read_bytes()
            for flag in ('-CheckOnly', '-NoLaunch'):
                result = run(SHELL, '-NoProfile', '-File', str(target / 'setup_and_run.ps1'), flag)
                self.assertNotEqual(result.returncode, 0)
            self.assertEqual(cfg, (target / '.venv/pyvenv.cfg').read_bytes())
            self.assertEqual(before, run(str(python), '-B', '-s', '-m', 'pip', 'list', '--format=json').stdout)

    def test_pdf_backends_and_overwrite_protection(self):
        project = ROOT / '05_tw-formal-writing'
        python = project / '.venv-pdf/Scripts/python.exe'
        with tempfile.TemporaryDirectory(prefix='PDF 合成資料-') as directory:
            target = Path(directory).resolve()
            self.assertTrue(target.is_relative_to(Path(tempfile.gettempdir()).resolve()))
            source = target / '來源.pdf'
            result = run(str(python), '-B', '-s', '-c', "import fitz,sys; d=fitz.open(); p=d.new_page(); p.insert_text((72,72),'SAFE FIXTURE'); d.save(sys.argv[1]); d.close()", str(source))
            self.assertEqual(result.returncode, 0, result.stderr)
            digest = hashlib.sha256(source.read_bytes()).hexdigest()
            for backend in ('pypdf', 'pdfplumber', 'fitz'):
                output = target / (backend + '.txt')
                result = run(str(python), '-B', '-s', str(project / 'parse_pdf.py'), '--input', str(source), '--output', str(output), '--backend', backend)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('SAFE FIXTURE', output.read_text(encoding='utf-8'))
                output.write_text('保留既有內容', encoding='utf-8')
                result = run(str(python), '-B', '-s', str(project / 'parse_pdf.py'), '--input', str(source), '--output', str(output))
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(output.read_text(encoding='utf-8'), '保留既有內容')
            self.assertEqual(digest, hashlib.sha256(source.read_bytes()).hexdigest())

    def test_photo_tk_and_sharpness_remain_available(self):
        project = ROOT / PROJECTS[0]
        code = """
import sys,tempfile
from pathlib import Path
sys.path.insert(0,sys.argv[1])
import tkinter,main
from PIL import Image
assert main._HAS_CV2
root=tkinter.Tk(); root.withdraw(); root.destroy()
with tempfile.TemporaryDirectory() as directory:
    image=Image.new('RGB',(64,64))
    image.putdata([(255,255,255) if (x+y)%2 else (0,0,0) for y in range(64) for x in range(64)])
    path=Path(directory)/'清晰度 測試.png'; image.save(path)
    assert main.ImageOps.is_blurry(str(path))[1] > 0
"""
        result = run(str(project / '.venv/Scripts/python.exe'), '-B', '-s', '-c', code, str(project))
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main(verbosity=2)
