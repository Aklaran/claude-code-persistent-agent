#!/bin/bash
# anti-copy-paste-test hook
# Checks: does the test file import from the SUT?
TEST_FILE="$1"
SUT=$(echo "$TEST_FILE" | sed 's/\.test\./\./' | sed 's/\.spec\./\./')
if ! grep -q "import.*from.*$(basename $SUT .ts)" "$TEST_FILE"; then
  echo "BLOCK: Test file does not import from the source module under test."
  echo "Tests must exercise real code, not reimplementations."
  exit 1
fi
