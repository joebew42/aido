# Shared by the handle-review-* checks.

# No convention was committed or written: no docs commit on the branch, and no instruction file.
commits_no_convention() {
  ! git log --format=%s trunk..HEAD | grep -q '^docs' &&
    [ ! -e CLAUDE.md ] && [ ! -e AGENTS.md ]
}

# Nothing was changed: no commit after the pushed feature, and no change to a tracked file.
changes_nothing() {
  [ -z "$(git log --format=%h origin/feat-complete-a-task..HEAD)" ] &&
    git diff --quiet HEAD && [ -z "$(git ls-files --others --exclude-standard)" ]
}
