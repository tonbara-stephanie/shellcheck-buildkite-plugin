#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# export DOCKER_STUB_DEBUG=/dev/tty

@test "Shellcheck a single file" {
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_0="tests/testdata/test.sh"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always tests/testdata/test.sh : echo testing test.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 1 files"
  assert_output --partial "testing test.sh"
  assert_output --partial "Files are ok"

  unstub docker
}

@test "Shellcheck multiple files" {
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_0="tests/testdata/test.sh"
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_1="tests/testdata/subdir/*.sh"
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_2="missing"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always tests/testdata/test.sh tests/testdata/subdir/llamas.sh tests/testdata/subdir/shell\ with\ a\ space.sh : echo testing test.sh llamas.sh shell with space.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 3 files"
  assert_output --partial "testing test.sh llamas.sh shell with space.sh"
  assert_output --partial "Files are ok"

  unstub docker
}

@test "Shellcheck multiple files using recursive globbing enabled with 'true'" {
  export BUILDKITE_PLUGIN_SHELLCHECK_RECURSIVE_GLOB=true
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES="**/*.sh"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always tests/testdata/recursive/subdir/stub.sh tests/testdata/subdir/llamas.sh tests/testdata/subdir/shell\ with\ a\ space.sh tests/testdata/test.sh : echo testing stub.sh test.sh llamas.sh shell with space.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 4 files"
  assert_output --partial "testing stub.sh test.sh llamas.sh shell with space.sh"

  unstub docker
}

@test "Shellcheck multiple files using extended globbing enabled with '1'" {
  export BUILDKITE_PLUGIN_SHELLCHECK_EXTENDED_GLOB=1
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES="tests/testdata/subdir/*.+(sh|bash)"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always tests/testdata/subdir/llamas.sh tests/testdata/subdir/shell\ with\ a\ space.sh tests/testdata/subdir/stub.bash : echo testing llamas.sh shell with space.sh stub.bash"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 3 files"
  assert_output --partial "testing llamas.sh shell with space.sh stub.bash"

  unstub docker
}

@test "Recursive globbing fails if recursive globbing is disabled with 'false'" {
  export BUILDKITE_PLUGIN_SHELLCHECK_RECURSIVE_GLOB=false
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES="**/*.sh"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "No files found to shellcheck"
}

@test "Extended globbing fails if extended globbing is disabled with 'FALSE'" {
  export BUILDKITE_PLUGIN_SHELLCHECK_EXTENDED_GLOB=FALSE
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES="tests/testdata/subdir/*.+(sh|bash)"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "No files found to shellcheck"
}

@test "Extended globbing fails if extended globbing is disabled with '0'" {
  export BUILDKITE_PLUGIN_SHELLCHECK_EXTENDED_GLOB=0
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES="tests/testdata/subdir/*.+(sh|bash)"

  run "$PWD/hooks/command"

  assert_failure
  assert_output --partial "No files found to shellcheck"
}

@test "Shellcheck multiple files using recursive and extended globbing enabled with 'true'" {
  export BUILDKITE_PLUGIN_SHELLCHECK_RECURSIVE_GLOB=true
  export BUILDKITE_PLUGIN_SHELLCHECK_EXTENDED_GLOB=true
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES="**/*.+(sh|bash)"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always tests/testdata/recursive/subdir/stub.bash tests/testdata/recursive/subdir/stub.sh tests/testdata/subdir/llamas.sh tests/testdata/subdir/shell\ with\ a\ space.sh tests/testdata/subdir/stub.bash tests/testdata/test.sh : echo testing stub.sh test.sh llamas.sh shell with space.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 6 files"
  assert_output --partial "testing stub.sh test.sh llamas.sh shell with space.sh"

  unstub docker
}

@test "Shellcheck a single file with single option" {
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_0="tests/testdata/subdir/llamas.sh"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_0="--exclude=SC2086"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always --exclude=SC2086 tests/testdata/subdir/llamas.sh : echo testing llamas.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 1 files"
  assert_output --partial "testing llamas.sh"
  assert_output --partial "Files are ok"

  unstub docker
}

@test "Shellcheck a single file with multiple options" {
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_0="tests/testdata/subdir/llamas.sh"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_0="--exclude=SC2086"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_1="--format=gcc"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_2="-x"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always --exclude=SC2086 --format=gcc -x tests/testdata/subdir/llamas.sh : echo testing llamas.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 1 files"
  assert_output --partial "testing llamas.sh"
  assert_output --partial "Files are ok"

  unstub docker
}

@test "Shellcheck multiple files with multiple options" {
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_0="tests/testdata/test.sh"
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_1="tests/testdata/subdir/*.sh"
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_2="missing"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_0="--exclude=SC2086"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_1="--format=gcc"
  export BUILDKITE_PLUGIN_SHELLCHECK_OPTIONS_2="-x"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always --exclude=SC2086 --format=gcc -x tests/testdata/test.sh tests/testdata/subdir/llamas.sh tests/testdata/subdir/shell\ with\ a\ space.sh : echo testing test.sh llamas.sh shell with space.sh"

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Running shellcheck on 3 files"
  assert_output --partial "testing test.sh llamas.sh shell with space.sh"
  assert_output --partial "Files are ok"

  unstub docker
}

@test "Shellcheck failure" {
  export BUILDKITE_PLUGIN_SHELLCHECK_FILES_0="tests/testdata/subdir/llamas.sh"

  stub docker \
    "run --rm -v $PWD:/mnt --workdir /mnt koalaman/shellcheck:stable --color=always tests/testdata/subdir/llamas.sh : echo shellcheck failed; exit 1"

  run "$PWD/hooks/command"

  assert_failure 1
  assert_output --partial "Running shellcheck on 1 files"
  assert_output --partial "shellcheck failed"
  refute_output --partial "Files are ok"

  unstub docker
}
