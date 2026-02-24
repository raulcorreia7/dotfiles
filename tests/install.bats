#!/usr/bin/env bats

setup() {
  REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
}

@test "install help prints usage" {
  run "$REPO_ROOT/install" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: ./install"* ]]
}

@test "install list shows phases" {
  run "$REPO_ROOT/install" --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available phases"* ]]
  [[ "$output" == *"check"* ]]
  [[ "$output" == *"configure"* ]]
}

@test "install dry-run only check and tools succeeds" {
  run "$REPO_ROOT/install" --dry-run --only check,tools
  [ "$status" -eq 0 ]
}

@test "uninstall help prints usage" {
  run "$REPO_ROOT/uninstall" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: ./uninstall"* ]]
}
