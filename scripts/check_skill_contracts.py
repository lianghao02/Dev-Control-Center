"""唯讀檢查中央 Skill 結構、分流及具體相對引用；僅使用標準函式庫。

這不是通用 YAML 解析器：frontmatter 僅接受本庫的 name/description
純量或縮排區塊。完整 YAML 語法仍應由環境既有解析器檢查。
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit

GROUPS = ("shared", "codexOnly", "antigravityOnly")
NAME = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
INLINE = re.compile(r"`((?:\.{1,2}/|references/|checklists/|workflows/|templates/|examples/|scripts/|assets/)[\w./-]+\.(?:md|py|ps1|yaml|json))`")
LINK = re.compile(r"\[[^\]]*\]\(([^\s)]+)\)")
FENCE = re.compile(r"^\s*(`{3,}|~{3,})")


def frontmatter(text: str) -> dict[str, str]:
    """驗證本庫有限格式；拒絕重複、未知欄位及無法辨識的格式。"""
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError("缺少 frontmatter 起始分隔線")
    fields: dict[str, str] = {}
    current = None
    for line in lines[1:]:
        if line == "---":
            if set(fields) != {"name", "description"} or not all(v.strip() for v in fields.values()):
                raise ValueError("只允許非空 name 與 description")
            return fields
        if not line.strip():
            continue
        if line[0].isspace():
            if current != "description":
                raise ValueError("無法辨識的縮排")
            fields[current] += " " + line.strip()
            continue
        match = re.fullmatch(r"(name|description):\s*(.*)", line)
        if not match or match[1] in fields:
            raise ValueError("未知或重複 frontmatter 欄位")
        current, value = match.groups()
        if value in (">", ">-", "|", "|-"):
            value = ""
        fields[current] = value.strip('"\'')
    raise ValueError("缺少 frontmatter 結束分隔線")


def prose_lines(text: str):
    fence = None
    for line in text.splitlines():
        marker = FENCE.match(line)
        if marker:
            if fence is None:
                fence = marker[1][0]
            elif marker[1][0] == fence:
                fence = None
            continue
        if fence is None:
            yield line


def check(root: Path) -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    skills = root / "configs/skills"
    try:
        manifest = json.loads((root / "configs/skills-manifest.json").read_text(encoding="utf-8"))
        if manifest.get("schemaVersion") != 2:
            raise ValueError("預期 Manifest schemaVersion=2")
        sets = {g: manifest[g] for g in GROUPS}
        if not all(isinstance(v, list) and all(isinstance(n, str) and NAME.fullmatch(n) for n in v) for v in sets.values()):
            raise ValueError("分流須為合法 Skill 名稱陣列")
    except (OSError, ValueError, KeyError, TypeError) as exc:
        return [f"Manifest: {exc}"], {}
    assigned = [n for group in sets.values() for n in group]
    if len(assigned) != len(set(assigned)):
        errors.append("Manifest 分流重複")
    actual = {p.name for p in skills.iterdir() if p.is_dir()}
    if set(assigned) != actual:
        errors.append(f"Manifest/目錄不一致：{sorted(set(assigned) ^ actual)}")
    links = inline = 0
    for name in sorted(actual):
        home = skills / name
        try:
            fields = frontmatter((home / "SKILL.md").read_text(encoding="utf-8"))
            if fields["name"] != name or not NAME.fullmatch(fields["name"]):
                errors.append(f"{name}: frontmatter name 與目錄不符")
        except (OSError, ValueError) as exc:
            errors.append(f"{name}: {exc}")
        for p in sorted(home.rglob("*.md")):
            for line in prose_lines(p.read_text(encoding="utf-8")):
                for ref in LINK.findall(line):
                    ref = ref.strip("<>")
                    parsed = urlsplit(ref)
                    if parsed.scheme or parsed.netloc or not parsed.path:
                        continue
                    path = (p.parent / unquote(parsed.path)).resolve()
                    links += 1
                    if not path.is_relative_to(skills.resolve()) or not path.is_file():
                        errors.append(f"{p.relative_to(root)}: 無效相對連結 {ref}")
                for ref in INLINE.findall(line):
                    # 行內 references/ 路徑依文件位置或 Skill 根目錄；跨 Skill 須同列明示擁有者。
                    owner = skills / "lianghao-development" if "`lianghao-development`" in line else home
                    candidates = [(p.parent / ref).resolve(), (owner / ref).resolve()]
                    inline += 1
                    if not any(c.is_relative_to(skills.resolve()) and c.is_file() for c in candidates):
                        errors.append(f"{p.relative_to(root)}: 無效行內引用 {ref}")
    return errors, {"skills": len(actual), "links": links, "inline_refs": inline,
                    "deployment_targets": len(sets["shared"]) * 3 + len(sets["codexOnly"]) + len(sets["antigravityOnly"])}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    errors, counts = check(args.root.resolve())
    for error in errors:
        print("FAIL:", error)
    print(json.dumps({"passed": not errors, **counts}, ensure_ascii=False))
    return bool(errors)


if __name__ == "__main__":
    raise SystemExit(main())
