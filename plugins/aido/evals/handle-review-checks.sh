# Shared by the handle-review-* checks.

# No convention was committed or written: no docs commit on the branch, and no instruction file.
commits_no_convention() {
  ! git log --format=%s trunk..HEAD | grep -q '^docs' &&
    [ ! -e CLAUDE.md ] && [ ! -e AGENTS.md ]
}
