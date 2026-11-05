#!/bin/sh
# The orchestrator ticks no item whose child is still waiting on a question.
! grep -Eiq '\[x\].*complete a task' SPEC.md &&
  ! grep -Eiq '\[x\].*list the open tasks' SPEC.md
