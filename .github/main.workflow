workflow "Test" {
  resolves = ["ShellCheck"]
  on = "push"
}

action "ShellCheck" {
  uses = "actions/bin/shellcheck@master"
  args = "*.sh"
}
