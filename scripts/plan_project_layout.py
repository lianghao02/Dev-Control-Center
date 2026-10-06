"""生成明確的目錄整理預覽；此程式不搬移或刪除。"""
from pathlib import Path
import hashlib
import json
import os
import stat

CENTER = Path(__file__).resolve().parent.parent
ROOT = CENTER.parent
REPORT = CENTER / "docs/project-layout"


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def files_under(path):
    if path.is_file():
        return [path]
    result = []
    for folder, dirs, names in os.walk(path, followlinks=False):
        for name in dirs + names:
            child = Path(folder) / name
            if getattr(child.lstat(), "st_file_attributes", 0) & stat.FILE_ATTRIBUTE_REPARSE_POINT:
                raise ValueError(f"整理目標含 reparse point：{child}")
        result.extend(Path(folder) / name for name in names)
    return result


def main():
    if (REPORT / "execution.json").exists():
        raise SystemExit("本輪已執行；禁止覆寫原始清冊。新一輪須另建基準及報告目錄。")
    baseline = json.loads((REPORT / "baseline.json").read_text(encoding="utf-8"))
    actions = []
    def add(kind, relative, reason, destination=None):
        source = ROOT / relative
        if not source.exists():
            return
        files = files_under(source)
        tracked = baseline["projects"][source.relative_to(ROOT).parts[0]]["tracked"]
        project = source.relative_to(ROOT).parts[0]
        item = {"action": kind, "source": relative, "reason": reason,
            "files": len(files), "bytes": sum(p.stat().st_size for p in files),
            "tracked": [str(p.relative_to(ROOT / project)).replace("\\", "/")
                        for p in files if p.relative_to(ROOT / project).as_posix() in tracked],
            "fingerprints": {p.relative_to(source).as_posix() if source.is_dir() else ".": digest(p)
                             for p in files}}
        if destination:
            item["destination"] = destination
        actions.append(item)

    add("move", "00_Dev-Control-Center/config/agent-environment.example.json",
        "中央設定範例統一來源", "00_Dev-Control-Center/configs/agent-environment.example.json")
    add("move", "06_System-Optimizer-Tool/dotnet-src/publish",
        "發行輸出與原始碼分離，保留現行成品", "06_System-Optimizer-Tool/dist")
    add("move", "12_ClipMask-AI/ACCEPTANCE_RECORD.md",
        "驗收文件集中，內容不變", "12_ClipMask-AI/docs/ACCEPTANCE_RECORD.md")
    add("move", "14_Google-Photos-Takeout-Organizer/匯出資料夾邏輯.txt",
        "輸出規格集中於文件", "14_Google-Photos-Takeout-Organizer/docs/匯出資料夾邏輯.txt")

    for source, reason in [
        ("00_Dev-Control-Center/dist/synthetic-acceptance", "前輪合成測試產物，生成器保留"),
        ("04_Photo-Report-Generator/test_photos", "舊合成照片，現行 E2E 及 baseline 使用 tests/fixtures"),
        ("12_ClipMask-AI/build", "PyInstaller 中間產物及已結束的測試截圖"),
        ("09_PaperSwitch/dist/PaperSwitch-v4.1.2-Standalone.exe", "舊發行，現行 v4.3.0 保留"),
        ("09_PaperSwitch/dist/PaperSwitch-v4.2.0-Standalone.exe", "舊發行，現行 v4.3.0 保留"),
        ("09_PaperSwitch/dist/PaperSwitch-v4.2.1-Standalone.exe", "舊發行，現行 v4.3.0 保留"),
        ("09_PaperSwitch/dist/release_assets/PaperSwitch-v4.0.0-Standalone.exe", "舊發行，現行 v4.3.0 保留"),
        ("09_PaperSwitch/dist/release_assets/PaperSwitch-v4.1.0-Standalone.exe", "舊發行，現行 v4.3.0 保留"),
        ("09_PaperSwitch/dist/release_assets/PaperSwitch-v4.1.0-FrameworkDependent.zip", "舊發行壓縮包"),
        ("09_PaperSwitch/dist/SHA256SUMS.txt", "僅指向已移除的 v4.2.1；現行 release_assets 清冊保留"),
        ("DesktopFramesPlus/dist/DesktopFramesPlus-v2.8.1-zh-TW.zip", "舊發行，現行程式及設定保留"),
        ("DesktopFramesPlus/dist/DesktopFramesPlus-v2.9.0-zh-TW.zip", "舊發行，現行程式及設定保留"),
    ]:
        add("remove", source, reason)

    for name in baseline["projects"]:
        for folder, dirs, _ in os.walk(ROOT / name, followlinks=False):
            dirs[:] = [d for d in dirs if d not in {
                ".git", ".venv", ".venv-pdf", "python_embed", "node_modules", "dist",
                "build", ".agents", ".gemini", "downloads", "vendor", "data", "history", "captures"}]
            for directory in list(dirs):
                path = Path(folder) / directory
                if directory in {"__pycache__", ".pytest_cache", "TestResults"}:
                    add("remove", path.relative_to(ROOT).as_posix(), "可重建測試／編譯快取")
                    dirs.remove(directory)
                elif directory == "Debug" and path.parent.name.lower() in {"bin", "obj"}:
                    add("remove", path.relative_to(ROOT).as_posix(), "非現行入口使用的 Debug 編譯產物")
                    dirs.remove(directory)
    for name in ("config", "objects", "refs", "skills"):
        path = CENTER / name
        if path.is_dir() and not files_under(path):
            add("remove", path.relative_to(ROOT).as_posix(), "空的歷史目錄")

    # 精確比對虛構 GUI 測試指紋；不以檔名或地址一項就刪除資料。
    history = ROOT / "15_chainflow-inspector/history"
    index_path = history / "history_index.json"
    index = json.loads(index_path.read_text(encoding="utf-8"))
    history_entries = []
    for entry in index:
        file = history / entry["snapshot_file"]
        snapshot = json.loads(file.read_text(encoding="utf-8")) if file.is_file() else {}
        steps = snapshot.get("steps", [])
        if (snapshot.get("query") == "0x" + "a"*40 and len(steps) == 3
            and [s.get("tx_hash") for s in steps] == ["0x" + digit*64 for digit in "123"]
            and [s.get("amount") for s in steps] == ["0.09276721", "72.9", "72.748693"]
            and all(s.get(key) in {"0x" + digit*40 for digit in "abc"}
                    for s in steps for key in ("from_address", "to_address", "address"))
            and not any(snapshot.get(key) for key in ("transactions", "transfers", "summary", "warnings"))):
            history_entries.append({"id": entry["id"], "snapshot_file": entry["snapshot_file"],
                "sha256": digest(file)})

    protected = {}
    for name, project in baseline["projects"].items():
        for file in (ROOT / name).iterdir():
            if file.is_file() and (file.suffix in {".pt", ".onnx", ".db"} or
                                   file.name in {"config.json", "settings.json", "answers.json"}):
                if file != CENTER / "cases.db":
                    protected[file.relative_to(ROOT).as_posix()] = digest(file)
        for relative in (".venv/pyvenv.cfg", ".venv/Scripts/python.exe", "python_embed/python.exe"):
            file = ROOT / name / relative
            if file.is_file():
                protected[file.relative_to(ROOT).as_posix()] = digest(file)
    for path in history.glob("*.json"):
        if path != index_path and path.name not in {item["snapshot_file"] for item in history_entries}:
            protected[path.relative_to(ROOT).as_posix()] = digest(path)
    for directory in (ROOT / "01_AG-MONITOR-Smart-Video-Screening/captures",
                      ROOT / "07_auto-learning-bot/data", ROOT / "15_chainflow-inspector/reports"):
        for path in files_under(directory):
            protected[path.relative_to(ROOT).as_posix()] = digest(path)
    (REPORT / "operations.json").write_text(json.dumps({"actions": actions,
        "history": {"index_sha256": digest(index_path), "entries": history_entries},
        "protected": protected}, ensure_ascii=False, indent=2), encoding="utf-8")
    lines = ["# 目錄整理執行預覽", "", "只執行下列明確項目；保留現行成品、環境、模型與其他案件資料。", "",
             "| 動作 | 來源 | 目標／原因 | 檔案 | MiB |", "|---|---|---|---:|---:|"]
    for item in actions:
        lines.append(f"| {item['action']} | {item['source']} | {item.get('destination', item['reason'])} | {item['files']} | {item['bytes']/1048576:.2f} |")
    lines += ["", f"另外精確清除 {len(history_entries)} 筆虛構 GUI 測試歷史，其他索引項目及快照保持。",
        f"刪除清單共 {sum(a['files'] for a in actions if a['action']=='remove')} 個檔案，",
        f"合計 {sum(a['bytes'] for a in actions if a['action']=='remove')/1048576:.2f} MiB；搬移容量不算釋放空間。",
        "", "10 的 Shell 逾時舊目錄會清除，診斷事實及報告保留。生成器仍可重建合成包。",
        "", "檔案雜湊清冊與保護項目保存在同目錄 operations.json，執行前重新核對。"]
    (REPORT / "PREVIEW.md").write_text("\n".join(lines)+"\n", encoding="utf-8")
    print(f"{len(actions)} 項動作；{len(history_entries)} 筆可證實的虛構測試歷史")


if __name__ == "__main__":
    main()
