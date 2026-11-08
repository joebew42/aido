# Shared by the handle-review-* cases: a pushed feature branch that completes a task, and its review.

. "$(dirname "${BASH_SOURCE[0]}")/organize-history.sh"

feature_branch() {
  base_app
  write_domain
  write_store
  write_application
  write_entry_point
  write_first_acceptance_test
}

# Commits and pushes the feature, and writes the review from stdin to .fixture/review.md.
push_for_review() {
  git add . && git commit -q -m "feat: complete a task"
  git push -q origin feat-complete-a-task
  cat > .fixture/review.md
}
