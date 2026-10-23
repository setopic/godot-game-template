"""make ci（scripts/local_ci.py）がGodotを探す順番のテスト（#75）。

順番は.claude/scripts/test-run.shと同じで、commands.testの先頭、engine.path、PATHのgodotである。
"""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "local_ci.py"
spec = importlib.util.spec_from_file_location("local_ci", SCRIPT)
local_ci = importlib.util.module_from_spec(spec)
spec.loader.exec_module(local_ci)

EDITOR = "C:/Godot/Godot_v4.7.2-stable_win64_console.exe"


def find(settings: dict[str, str], present: set[str]) -> str | None:
    return local_ci.godot_exe(lambda key: settings.get(key, ""), lambda exe: exe in present)


class GodotExe(unittest.TestCase):
    def test_engine_path_is_used_when_godot_is_not_on_path(self):
        settings = {"commands.test": "godot --headless", "engine.path": EDITOR}
        self.assertEqual(find(settings, {EDITOR}), EDITOR)

    def test_path_godot_when_engine_path_is_unset(self):
        self.assertEqual(find({}, {"godot"}), "godot")

    def test_engine_path_comes_before_path_godot(self):
        self.assertEqual(find({"engine.path": EDITOR}, {EDITOR, "godot"}), EDITOR)

    def test_missing_engine_path_falls_back_to_path_godot(self):
        self.assertEqual(find({"engine.path": EDITOR}, {"godot"}), "godot")

    def test_quoted_commands_test_comes_first(self):
        settings = {"commands.test": f'"{EDITOR}" --headless', "engine.path": "D:/other/godot.exe"}
        self.assertEqual(find(settings, {EDITOR, "D:/other/godot.exe"}), EDITOR)

    def test_wrapper_in_commands_test_is_not_the_editor(self):
        settings = {"commands.test": "bash run-tests.sh"}
        self.assertEqual(find(settings, {"bash", "godot"}), "godot")

    def test_none_when_nothing_is_found(self):
        self.assertIsNone(find({"engine.path": EDITOR}, set()))


if __name__ == "__main__":
    unittest.main()
