#!/usr/bin/env python
"""發布前版本一致性檢查（唯讀）。

比對每個專案的「程式內版本」（version.txt、package.json、tauri.conf.json、.csproj、pyproject.toml）、
README 標題版本與 CHANGELOG 最新已發布標題，找出不一致，避免使用者下載到與說明不符的版本。

用法：
    python scripts/check_release_versions.py              # 檢查全部專案
    python scripts/check_release_versions.py 09 19        # 只檢查指定編號
    python scripts/check_release_versions.py --online     # 另外比對最新 git tag 與 GitHub Release

結束碼：0 = 沒有錯誤（可有警告）；1 = 有專案的版本來源互相矛盾。
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

CENTER = Path(__file__).resolve().parent.parent
WORKSPACE = CENTER.parent
VERSION_RE = re.compile(r'(\d+\.\d+\.\d+)(?:\.\d+)?')


def norm(text: str | None) -> str | None:
    """取出 x.y.z（忽略 v／V 前綴與 -zh-TW、-beta 等後綴）。"""
    if not text:
        return None
    m = VERSION_RE.search(text)
    return m.group(1) if m else None


def read(path: Path, limit: int = 8000) -> str:
    try:
        return path.read_text(encoding='utf-8-sig', errors='replace')[:limit]
    except OSError:
        return ''


def git(repo: Path, *args: str) -> str:
    try:
        r = subprocess.run(['git', '-C', str(repo), *args], capture_output=True, text=True,
                           encoding='utf-8', errors='replace', timeout=60)
        return r.stdout.strip()
    except (OSError, subprocess.TimeoutExpired):
        return ''


def program_versions(repo: Path) -> dict[str, str]:
    found: dict[str, str] = {}
    for rel in ('version.txt', 'VERSION'):
        text = read(repo / rel).strip().splitlines()
        if text and norm(text[0]):
            found[rel] = norm(text[0])  # type: ignore[assignment]
    for rel in ('package.json', 'src-tauri/tauri.conf.json'):
        m = re.search(r'"version"\s*:\s*"([^"]+)"', read(repo / rel))
        if m and norm(m.group(1)):
            found[rel] = norm(m.group(1))  # type: ignore[assignment]
    m = re.search(r'^version\s*=\s*"([^"]+)"', read(repo / 'pyproject.toml'), re.M)
    if m and norm(m.group(1)):
        found['pyproject.toml'] = norm(m.group(1))  # type: ignore[assignment]
    for rel in git(repo, 'ls-files', '*.csproj').splitlines():
        if re.search(r'test', rel, re.I):
            continue
        m = re.search(r'<Version>([^<]+)</Version>', read(repo / rel))
        if m and norm(m.group(1)):
            found[rel] = norm(m.group(1))  # type: ignore[assignment]
    return found


def readme_version(repo: Path) -> str | None:
    head = '\n'.join(read(repo / 'README.md', 4000).splitlines()[:14])
    return norm(head)


def changelog_version(repo: Path) -> str | None:
    """最新「已發布」標題；略過未發布區塊。"""
    for line in read(repo / 'CHANGELOG.md', 20000).splitlines():
        if not line.startswith('## '):
            continue
        if re.search(r'Unreleased|未發布', line):
            continue
        v = norm(line)
        if v:
            return v
    return None


def online_info(repo: Path) -> tuple[str | None, str | None]:
    tag = norm(git(repo, 'describe', '--tags', '--abbrev=0'))
    try:
        r = subprocess.run(['gh', 'release', 'list', '--limit', '1'], cwd=repo, capture_output=True,
                           text=True, encoding='utf-8', errors='replace', timeout=40)
        parts = r.stdout.strip().split('\t')
        release = norm(parts[2]) if len(parts) > 2 else None
    except (OSError, subprocess.TimeoutExpired):
        release = None
    return tag, release


def main(argv: list[str]) -> int:
    # Windows 主控台預設 cp950，統一以 UTF-8 輸出避免中文或符號造成例外。
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    online = '--online' in argv
    wanted = [a for a in argv if not a.startswith('--')]
    config = json.loads((CENTER / 'development-repositories.json').read_text(encoding='utf-8'))
    errors = warnings = 0
    for item in config['repositories']:
        folder = item['folder']
        if wanted and not any(folder.startswith(w) for w in wanted):
            continue
        repo = WORKSPACE / folder
        if not (repo / '.git').exists():
            continue
        prog = program_versions(repo)
        readme = readme_version(repo)
        changelog = changelog_version(repo)
        problems: list[str] = []
        notes: list[str] = []

        if len(set(prog.values())) > 1:
            problems.append('程式內版本來源互相矛盾：' + '、'.join(f'{k}={v}' for k, v in prog.items()))
        main_version = next(iter(prog.values()), None) if prog else None
        reference = main_version or changelog
        # 沒有程式內版本檔時，README 前幾行可能只是提到其他元件的版本（例如中樞的憲法版號），不拿來比對。
        if readme and main_version and readme != main_version:
            problems.append(f'README 版本 {readme} ≠ 程式版本 {main_version}')
        if main_version and changelog and changelog != main_version:
            problems.append(f'CHANGELOG 最新已發布 {changelog} ≠ 程式版本 {main_version}')
        if not prog:
            notes.append('沒有程式內版本檔（以 CHANGELOG 為準）')
        if online:
            tag, release = online_info(repo)
            if reference and tag and tag != reference:
                notes.append(f'最新 git tag {tag} ≠ {reference}（尚未打 tag 或尚未發布）')
            if reference and release and release != reference:
                notes.append(f'最新 GitHub Release {release} ≠ {reference}')

        status = 'ERR ' if problems else ('WARN' if notes else 'OK  ')
        errors += bool(problems)
        warnings += bool(notes and not problems)
        shown = main_version or changelog or '?'
        print(f'[{status}] {folder}  版本={shown}')
        for p in problems:
            print(f'        x {p}')
        for n in notes:
            print(f'        - {n}')
    print(f'\n結果：{errors} 個專案有版本矛盾，{warnings} 個專案有提醒。')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
