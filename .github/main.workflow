workflow "Test on push" {
  resolves = ["shellcheck"]
  on = "push"
}

action "shellcheck" {
  uses = "ludeeus/action-shellcheck@0.1.0"
}
