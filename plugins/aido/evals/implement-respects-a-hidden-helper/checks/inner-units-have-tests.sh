#!/bin/sh
# An acceptance test runs bin/todo. A unit test is a test file that loads the code in lib/ itself.
find . \( -path ./.git -o -path ./.fixture -o -path ./lib -o -path ./bin \) -prune -o \
  -type f -path '*test*' -print | xargs grep -l 'lib/' >/dev/null
