"""核對搬移、刪除、資料保護與 Git 邊界；不產生新的業務測試資料。"""
from pathlib import Path
import hashlib
import json
import subprocess

CENTER = Path(__file__).resolve().parent.parent
ROOT = CENTER.parent
REPORT = CENTER / "docs/project-layout"


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1048576), b""):
            h.update(block)
    return h.hexdigest()


def git(repo, *args):
    return subprocess.check_output(["git", "-c", "safe.directory=*", "--no-optional-locks",
        "-C", str(repo), *args], encoding="utf-8", errors="strict")


def main():
    plan = json.loads((REPORT / "operations.json").read_text(encoding="utf-8"))
    baseline = json.loads((REPORT / "baseline.json").read_text(encoding="utf-8"))
    journal = json.loads((REPORT / "execution.json").read_text(encoding="utf-8"))
    checks = {}
    failures = []

    def check(name, condition):
        checks[name] = bool(condition)
        if not condition:
            failures.append(name)

    check("所有清冊動作完成", len(journal) == len(plan["actions"]) + 2 and
          all(item["status"] == "completed" for item in journal))
    for action in plan["actions"]:
        source = ROOT / action["source"]
        check("來源已清理：" + action["source"], not source.exists())
        if action["action"] == "move":
            target = ROOT / action["destination"]
            for relative, expected in action["fingerprints"].items():
                file = target if relative == "." else target / relative
                check("搬移內容一致：" + file.relative_to(ROOT).as_posix(),
                      file.is_file() and digest(file) == expected)
    for relative, expected in plan["protected"].items():
        file = ROOT / relative
        check("保護內容一致：" + relative, file.is_file() and digest(file) == expected)
    before = json.loads((CENTER / "artifacts/layout-safety/history_index.before.json").read_text(encoding="utf-8"))
    after = json.loads((ROOT / "15_chainflow-inspector/history/history_index.json").read_text(encoding="utf-8"))
    ids = {item["id"] for item in plan["history"]["entries"]}
    check("其餘歷史索引逐欄位一致", after == [item for item in before if item["id"] not in ids])
    for entry in plan["history"]["entries"]:
        check("虛構快照已移除：" + entry["id"],
              not (ROOT / "15_chainflow-inspector/history" / entry["snapshot_file"]).exists())

    intentional = {
        "00_Dev-Control-Center": {".gitignore", "build_all_desktop_apps.ps1", "scripts/gui.ps1",
            "IMPLEMENTATION_PLAN.md", "HANDOFF.md", "IMPROVEMENTS.md", "config/agent-environment.example.json",
            "docs/python-environment-repair/SYNTHETIC-ACCEPTANCE.md"},
        "04_Photo-Report-Generator": {"README.md", "HANDOFF.md"},
        "06_System-Optimizer-Tool": {".gitignore", "AGENTS.md", "README.md", "ARCHITECTURE.md",
            "MEMORY.md", "legacy-python/README.md", "dotnet-src/build_release.ps1", "⚡ 啟動系統優化工具.bat", "HANDOFF.md"},
        "12_ClipMask-AI": {"README.md", "ACCEPTANCE_RECORD.md", "HANDOFF.md"},
        "14_Google-Photos-Takeout-Organizer": {"README.zh-TW.md", "匯出資料夾邏輯.txt", "HANDOFF.md"},
        "15_chainflow-inspector": {"HANDOFF.md"},
    }
    for action in plan["actions"]:
        project = action["source"].split("/")[0]
        intentional.setdefault(project, set()).update(action["tracked"])
    for project in ("01_AG-MONITOR-Smart-Video-Screening", "05_tw-formal-writing", "07_auto-learning-bot",
                    "09_PaperSwitch", "10_Smart-Photo-Organizer", "DesktopFramesPlus"):
        intentional.setdefault(project, set()).add("HANDOFF.md")
    states = {}
    preserved = 0
    for name, old in baseline["projects"].items():
        repo = ROOT / name
        check("HEAD 保持：" + name, git(repo, "rev-parse", "HEAD").strip() == old["head"])
        check("分支保持：" + name, git(repo, "branch", "--show-current").strip() == old["branch"])
        for relative, expected in old["changed_hashes"].items():
            if relative in intentional.get(name, set()):
                continue
            file = repo / relative
            check("繼承修改保持：" + name + "/" + relative, file.is_file() and digest(file) == expected)
            preserved += 1
        status = git(repo, "status", "--porcelain=v1", "-z")
        old_paths = {item[3:] for item in old["status"].split("\0") if len(item) >= 4 and item[:2] != "??"}
        new_paths = {item[3:] for item in status.split("\0") if len(item) >= 4 and item[:2] != "??"}
        unexpected = new_paths - old_paths - intentional.get(name, set())
        check("無額外已追蹤異動：" + name, not unexpected)
        for option in ([], ["--cached"]):
            result = subprocess.run(["git", "-c", "safe.directory=*", "--no-optional-locks", "-C", str(repo),
                "diff", *option, "--check"], capture_output=True, text=True, encoding="utf-8")
            check("Git 差異格式：" + name + ("/staged" if option else "/working"), result.returncode == 0)
            if result.returncode:
                failures.append(result.stdout + result.stderr)
        states[name] = {"branch": old["branch"], "head": old["head"], "status": status,
                        "unexpected_tracked_changes": sorted(unexpected)}
    for relative in ["01_AG-MONITOR-Smart-Video-Screening/dist", "03_Police-Image-Toolkit/dist/PoliceImageToolkit.exe",
        "05_tw-formal-writing/dist", "06_System-Optimizer-Tool/dist/standalone/SystemOptimizer.App.exe",
        "08_Financial-Data-Parser/dist",
        "09_PaperSwitch/dotnet-src/src/PaperSwitch/bin/Release/net8.0-windows10.0.19041.0/win-x64/PaperSwitch.exe",
        "09_PaperSwitch/dist/release_assets/PaperSwitch-v4.3.0-Standalone.exe", "11_Calendar-Card-App/dist",
        "12_ClipMask-AI/dist", "13_Project-Hub/downloads/Photo_Report.rar",
        "DesktopFramesPlus/Code/Desktop Frames/bin/Release/net8.0-windows7.0/Desktop Frames.exe",
        "04_Photo-Report-Generator/tests/fixtures", "04_Photo-Report-Generator/tests/baseline"]:
        check("現行成品／有效素材保持：" + relative, (ROOT / relative).exists())
    # 只編譯語法物件，不寫入 __pycache__。
    for relative in ["scripts/audit_project_layout.py", "scripts/plan_project_layout.py",
        "scripts/verify_project_layout.py", "scripts/tests/create_synthetic_acceptance_pack.py"]:
        file = CENTER / relative
        compile(file.read_text(encoding="utf-8"), str(file), "exec")
    result = {"checks": checks, "failures": failures, "passed": not failures, "projects": states,
        "inherited_files_verified": preserved, "history_retained": len(after),
        "removed_files": sum(item["files"] for item in journal if item["action"].startswith("remove")),
        "removed_bytes": sum(item["bytes"] for item in journal if item["action"].startswith("remove")),
        "moved_files": sum(item["files"] for item in journal if item["action"] == "move")}
    (REPORT / "verification.json").write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({key: value for key, value in result.items() if key not in {"checks", "projects"}}, ensure_ascii=False))
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
