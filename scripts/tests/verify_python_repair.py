"""唯讀核對修復前後的全域套件、保護檔案與 Git 索引。"""
import hashlib
import json
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[3]
report_dir = root / '00_Dev-Control-Center/docs/python-environment-repair'
baseline = json.loads((report_dir / 'baseline.json').read_text(encoding='utf-8'))
result = {}
for version in ('313', '314'):
    python = Path.home() / f'AppData/Local/Programs/Python/Python{version}/python.exe'
    output = subprocess.check_output([str(python), '-B', '-m', 'pip', '--disable-pip-version-check', 'list', '--format=json'], text=True)
    normalize = lambda packages: {p['name'].lower().replace('_', '-'): p['version'] for p in packages}
    equal = normalize(json.loads(output)) == normalize(baseline['global_packages'][version])
    result[f'global_{version}_packages_unchanged'] = equal
    assert equal, f'全域 {version} 套件與基準不符'
for filename, digest in baseline['projects']['07_auto-learning-bot']['protected_files'].items():
    equal = hashlib.sha256((root / '07_auto-learning-bot' / filename).read_bytes()).hexdigest() == digest
    result[f'protected_07_{filename}'] = equal
    assert equal, f'受保護檔案改變：{filename}'
for project in ('10_Smart-Photo-Organizer', '12_ClipMask-AI', '15_chainflow-inspector'):
    output = subprocess.check_output(['git', '-c', 'safe.directory=*', '-C', str(root / project), 'ls-files', '.venv'], text=True)
    assert not output.strip(), f'{project} .venv 不應被追蹤'
    result[f'{project}_venv_not_tracked'] = True
assert not subprocess.check_output(['git', '-c', 'safe.directory=*', '-C', str(root / '10_Smart-Photo-Organizer'), 'ls-files', 'python_embed'], text=True).strip()
result['photo_embedded_not_tracked'] = True
print(json.dumps(result, ensure_ascii=False, indent=2))
