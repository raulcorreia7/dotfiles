#!/usr/bin/env bats

setup() {
  REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
}

@test "install dry-run prints all stages and succeeds" {
  run "$REPO_ROOT/install/install.sh" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"[dry-run] would run: do_check"* ]]
  [[ "$output" == *"[dry-run] would run: do_setup"* ]]
  [[ "$output" == *"[dry-run] would run: do_tools"* ]]
  [[ "$output" == *"[dry-run] would run: do_configure"* ]]
}

@test "packages installer help prints usage" {
  run "$REPO_ROOT/packages/install.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: ./packages/install.sh"* ]]
}
