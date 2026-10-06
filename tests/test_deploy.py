"""Deployment regressions using temporary homes and stubbed external commands.

Run with: python3 -m unittest discover -s tests -v
Requires Ansible, GNU Stow, and /bin/bash; never installs packages or plugins.
"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


class DeploymentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}")

    def command(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\n" + body)
        path.chmod(0o755)

    def play(self, tasks, variables, check=False, success=True):
        path = self.root / "play.json"
        path.write_text(json.dumps([{
            "hosts": "localhost", "connection": "local", "gather_facts": False,
            "vars": variables, "tasks": tasks,
        }]))
        result = subprocess.run(
            ["ansible-playbook", "-i", "localhost,", str(path)]
            + (["--check"] if check else []),
            cwd=REPO, env=self.env, capture_output=True, text=True,
        )
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result.stdout

    def stow(self, **kwargs):
        return self.play([
            {"ansible.builtin.include_tasks": str(REPO / "roles/dotmodules/tasks/module.yml")},
            {"ansible.builtin.include_tasks": str(REPO / "roles/dotmodules/tasks/stow.yml")},
        ], {
            "dotmodule_name": "claude", "dotmodules_root": str(REPO / "modules"),
            "dotmodules_target_home": str(self.home),
            "dotmodules_homebrew_packages": [], "dotmodules_homebrew_casks": [],
            "dotmodules_stow_dirs": [], "dotmodules_stow_backup_files": {},
            "dotmodules_shells": [],
        }, **kwargs)

    def test_bash_argument_forwarding(self):
        self.command("ansible-galaxy", "printf 'community.general 10.0.0\\n'\n")
        self.command("ansible-playbook", 'printf "%s\\0" "$@"\n')
        cases = [
            ([], ["--ask-become-pass"]),
            (["--restricted"], ["--skip-tags", "register_shell"]),
            (["--check", "--restricted"], ["--check", "--skip-tags", "register_shell"]),
            (["--extra-vars", "label=two words", "--extra-vars", ""],
             ["--ask-become-pass", "--extra-vars", "label=two words", "--extra-vars", ""]),
        ]
        for args, expected in cases:
            with self.subTest(args=args):
                result = subprocess.run(
                    ["/bin/bash", str(REPO / "deploy"), *args],
                    cwd=self.root, env=self.env, capture_output=True, check=True,
                )
                self.assertEqual(result.stdout.decode().split("\0")[:-1],
                                 ["-i", "playbooks/inventory", "playbooks/deploy.yml", *expected])

    def test_existing_settings_backup_and_repeat(self):
        settings = self.home / ".claude/settings.json"
        settings.parent.mkdir()
        original = b'{"theme":"dark","personal":"preserve me"}\n'
        settings.write_bytes(original)
        settings.chmod(0o600)
        older_backup = settings.with_name("settings.json.pre-dotfiles-older")
        older_backup.write_text("older backup")
        self.stow(check=True)
        self.assertFalse(settings.is_symlink())
        self.assertEqual(settings.read_bytes(), original)
        self.assertEqual(set(self.home.rglob("*")), {settings.parent, settings, older_backup})
        self.stow()
        self.assertTrue(settings.is_symlink())
        self.assertEqual(settings.resolve(), REPO / "modules/claude/files/.claude/settings.json")
        backups = set(settings.parent.glob("settings.json.pre-dotfiles-*")) - {older_backup}
        self.assertEqual(len(backups), 1)
        backup = backups.pop()
        self.assertEqual(backup.read_bytes(), original)
        self.assertEqual(backup.stat().st_mode & 0o777, 0o600)
        self.assertEqual(older_backup.read_text(), "older backup")
        self.assertIn("changed=0", self.stow())
        self.assertIn("changed=0", self.stow(check=True))

    def test_fresh_home(self):
        self.stow()
        self.assertTrue((self.home / ".claude/settings.json").is_symlink())
        self.assertFalse(list(self.home.rglob("*.pre-dotfiles-*")))

    def test_unrelated_symlink_still_fails(self):
        target = self.root / "personal.json"
        target.write_text('{"personal":true}')
        settings = self.home / ".claude/settings.json"
        settings.parent.mkdir()
        settings.symlink_to(target)
        self.stow(success=False)
        self.assertEqual(settings.resolve(), target.resolve())
        self.assertEqual(target.read_text(), '{"personal":true}')
        self.assertFalse(list(self.home.rglob("*.pre-dotfiles-*")))

    def test_existing_directory_still_fails(self):
        settings = self.home / ".claude/settings.json"
        settings.mkdir(parents=True)
        personal = settings / "keep"
        personal.write_text("preserve me")
        self.stow(success=False)
        self.assertTrue(settings.is_dir())
        self.assertEqual(personal.read_text(), "preserve me")

    def test_fisher_empty_list_and_real_errors(self):
        tasks = [{"ansible.builtin.include_tasks": str(REPO / "modules/fish/tasks.yml")}]
        variables = {"dotmodules_root": str(REPO / "modules")}
        for body, success in [
            ("exit 1\n", True),
            ("echo broken >&2; exit 1\n", False),
            ("exit 127\n", False),
        ]:
            with self.subTest(body=body):
                self.command("fish", body)
                self.play(tasks, variables, check=True, success=success)


if __name__ == "__main__":
    unittest.main()
