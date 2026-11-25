"""以隔離範例驗證 Skill 檢查器能攔下實際部署與引用錯誤。"""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "check_skill_contracts.py"
spec = importlib.util.spec_from_file_location("skill_contracts", SCRIPT)
contracts = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contracts)


class SkillContractsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.home = self.root / "configs/skills/example"
        self.home.mkdir(parents=True)
        self.manifest = self.root / "configs/skills-manifest.json"
        self.manifest.write_text(json.dumps({"schemaVersion": 2, "shared": ["example"],
                                            "codexOnly": [], "antigravityOnly": []}), encoding="utf-8")
        self.skill = self.home / "SKILL.md"
        self.skill.write_text("---\nname: example\ndescription: >\n  範例流程與觸發條件\n---\n", encoding="utf-8")

    def errors(self):
        return contracts.check(self.root)[0]

    def test_shared_inventory_and_read_only(self):
        before = {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        errors, counts = contracts.check(self.root)
        self.assertFalse(errors)
        self.assertEqual(counts['deployment_targets'], 3)
        self.assertEqual(before, {p.relative_to(self.root): p.read_bytes() for p in self.root.rglob('*') if p.is_file()})

    def test_duplicate_manifest_assignment(self):
        data = json.loads(self.manifest.read_text(encoding="utf-8"))
        data['codexOnly'] = ['example']
        self.manifest.write_text(json.dumps(data), encoding="utf-8")
        self.assertIn('Manifest 分流重複', self.errors())

    def test_unassigned_skill(self):
        (self.home.parent / 'unassigned').mkdir()
        self.assertTrue(any('目錄不一致' in e for e in self.errors()))

    def test_invalid_frontmatter(self):
        for content in ['---\nname: example\nname: duplicate\ndescription: x\n---\n',
                        '---\nname: example\ndescription: x\nhooks: on\n---\n',
                        '---\nname: other\ndescription: x\n---\n',
                        '---\nname: example\ndescription:\n---\n']:
            with self.subTest(content=content):
                self.skill.write_text(content, encoding="utf-8")
                self.assertTrue(self.errors())

    def test_missing_and_escaping_links(self):
        for ref in ['references/missing.md', '../../../../outside.md']:
            with self.subTest(ref=ref):
                self.skill.write_text(self.skill.read_text(encoding="utf-8") + f'\n[錯誤引用]({ref})\n', encoding="utf-8")
                self.assertTrue(any('無效相對連結' in e for e in self.errors()))

    def test_relative_reference_and_code_fence(self):
        (self.home / 'references').mkdir()
        (self.home / 'references/valid.md').write_text('有效文件', encoding="utf-8")
        self.skill.write_text(self.skill.read_text(encoding="utf-8") + '\n[參考](references/valid.md)\n`references/valid.md`\n```md\n[範例](missing.md)\n```\n', encoding="utf-8")
        self.assertFalse(self.errors())
        self.skill.write_text(self.skill.read_text(encoding="utf-8") + '\n`references/missing.md`\n', encoding="utf-8")
        self.assertTrue(any('無效行內引用' in e for e in self.errors()))

    def test_link_must_be_deployed_to_every_source_platform(self):
        data = json.loads(self.manifest.read_text(encoding="utf-8"))
        data["antigravityOnly"] = ["agy-only"]
        self.manifest.write_text(json.dumps(data), encoding="utf-8")
        target = self.home.parent / "agy-only" / "SKILL.md"
        target.parent.mkdir()
        target.write_text("---\nname: agy-only\ndescription: Example\n---\n[共用來源](../example/SKILL.md)\n", encoding="utf-8")
        self.assertFalse(self.errors())
        with self.skill.open("a", encoding="utf-8") as stream:
            stream.write("[專用技能](../agy-only/SKILL.md)\n")
        self.assertTrue(any("未部署到 Claude Code, Codex" in e for e in self.errors()))

    def test_reference_style_link_and_heading_fragment(self):
        target = self.home / "references" / "valid.md"
        target.parent.mkdir()
        target.write_text("# 雙系統驗收\n", encoding="utf-8")
        with self.skill.open("a", encoding="utf-8") as stream:
            stream.write("[清單][os]\n\n[os]: references/valid.md#雙系統驗收\n")
        self.assertFalse(self.errors())
        with self.skill.open("a", encoding="utf-8") as stream:
            stream.write("[錯誤](references/valid.md#不存在的章節)\n[missing]: references/missing.md\n")
        errors = self.errors()
        self.assertTrue(any("找不到 Markdown 章節" in e for e in errors))
        self.assertTrue(any("無效相對連結 references/missing.md" in e for e in errors))


if __name__ == '__main__':
    unittest.main()
