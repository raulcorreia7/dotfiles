#!/usr/bin/env bats

setup() {
  REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
}

@test "runtime exposes core helpers" {
  run bash -c '. "$1/config/runtime.sh"; type dot_has >/dev/null 2>&1; type dot_shell_type >/dev/null 2>&1; type rdf >/dev/null 2>&1' -- "$REPO_ROOT"
  [ "$status" -eq 0 ]
}

@test "dot_shell_type reports bash in test shell" {
  run bash -c '. "$1/config/runtime.sh"; dot_shell_type' -- "$REPO_ROOT"
  [ "$status" -eq 0 ]
  [ "$output" = "bash" ]
}

@test "rdf help returns usage text" {
  run bash -c 'DOTFILES_DIR="$1"; export DOTFILES_DIR; . "$1/config/runtime.sh"; rdf help' -- "$REPO_ROOT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: rdf <command>"* ]]
  [[ "$output" == *"raul dotfiles"* ]]
}
