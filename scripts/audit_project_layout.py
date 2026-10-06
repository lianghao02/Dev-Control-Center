"""唯讀盤點專案目錄、容量與 Git 狀態，保留本輪整理基準。"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess


def git(repo, *args):
    return subprocess.check_output(["git", "-c", "safe.directory=*", "--no-optional-locks",
        "-C", str(repo), *args], encoding="utf-8", errors="replace")


def directory_stats(root):
    count = total = 0
    errors = []
    links = []
    stack = [root]
    while stack:
        folder = stack.pop()
        try:
            entries = list(os.scandir(folder))
        except OSError as exc:
            errors.append({"path": str(folder), "error": str(exc)})
            continue
        for entry in entries:
            if entry.name == ".git":
                continue
            try:
                info = entry.stat(follow_symlinks=False)
                if getattr(info, "st_file_attributes", 0) & stat.FILE_ATTRIBUTE_REPARSE_POINT:
                    links.append(str(entry.path))
                elif entry.is_dir(follow_symlinks=False):
                    stack.append(Path(entry.path))
                elif entry.is_file(follow_symlinks=False):
                    count += 1
                    total += info.st_size
            except OSError as exc:
                errors.append({"path": str(entry.path), "error": str(exc)})
    return {"files": count, "bytes": total, "links": links, "errors": errors}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    workspace = Path(__file__).resolve().parents[2]
    report = {"workspace": str(workspace), "projects": {}}
    for repo in sorted(workspace.iterdir()):
        if not repo.is_dir() or not (repo / ".git").exists():
            continue
        tracked = git(repo, "ls-files", "-z").split("\0")
        tracked = [p for p in tracked if p]
        status = git(repo, "status", "--porcelain=v1", "-z")
        project = {"branch": git(repo, "branch", "--show-current").strip(),
            "head": git(repo, "rev-parse", "HEAD").strip(), "status": status,
            "tracked": tracked, "root_files": [], "directories": {}, "changed_hashes": {}}
        parts = status.split("\0")
        for item in parts:
            if len(item) < 4 or item[0:2] == "??":
                continue
            path = repo / item[3:]
            if path.is_file():
                project["changed_hashes"][item[3:]] = hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(repo.iterdir()):
            if path.name == ".git":
                continue
            info = path.lstat()
            if getattr(info, "st_file_attributes", 0) & stat.FILE_ATTRIBUTE_REPARSE_POINT:
                project["directories"][path.name] = {"reparse_point": True}
            elif path.is_dir():
                detail = directory_stats(path)
                detail["tracked_count"] = sum(p.startswith(path.name + "/") for p in tracked)
                detail["children"] = [p.name for p in path.iterdir()][:100]
                project["directories"][path.name] = detail
            else:
                project["root_files"].append({"name": path.name, "bytes": info.st_size,
                    "tracked": path.name in tracked})
        report["projects"][repo.name] = project
        print(repo.name, flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
