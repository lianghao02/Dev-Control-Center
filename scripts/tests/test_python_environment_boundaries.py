"""環境修復邊界：啟動器參數、檢查模式與錯誤 Python 版本防護。"""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
SHELL = shutil.which('pwsh.exe') or shutil.which('powershell.exe')
PROJECTS = ('12_ClipMask-AI', '15_chainflow-inspector')
CHAINFLOW_PROJECT = '15_chainflow-inspector'


def run(*args):
    return subprocess.run(args, capture_output=True, text=True, encoding='utf-8', errors='replace')


class EnvironmentBoundaries(unittest.TestCase):
    def test_application_arguments_are_not_bound_to_setup_parameters(self):
        python313 = Path(os.environ['LOCALAPPDATA']) / 'Programs/Python/Python313/python.exe'
        with tempfile.TemporaryDirectory(prefix='啟動 參數-') as directory:
            target = Path(directory).resolve()
            self.assertTrue(target.is_relative_to(Path(tempfile.gettempdir()).resolve()))
            # 只測啟動器的參數邊界，測試程式使用標準庫，避免安裝 GUI 套件。
            setup = (ROOT / CHAINFLOW_PROJECT / 'setup_and_run.ps1').read_text(encoding='utf-8')
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
                shutil.copy2(ROOT / CHAINFLOW_PROJECT / filename, target / filename)
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


if __name__ == '__main__':
    unittest.main(verbosity=2)
