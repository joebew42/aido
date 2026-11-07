# Fit the README workflow diagram without a horizontal scroll bar

## Context

The last merged change put the workflow at the top of the README as a text diagram. Its widest line
is 99 characters. GitHub's README view fits about 91 on a desktop screen, so the browser shows a
horizontal scroll bar under the diagram.

## Intent

The diagram fits on GitHub's desktop README view, with no horizontal scroll bar. It stays a text
diagram that shows the same five steps, in the same order, each with its skill name.

## Out of scope

- a Mermaid diagram or an image in place of the text diagram
- fitting narrow screens, such as phones
- other parts of the README

## Acceptance criteria

- AC1: No line of the workflow diagram is longer than 80 characters.
- AC2: The diagram still shows the five steps in order, each with its number, name, short
  description and full skill name.
- AC3 (manual): On GitHub's desktop README view, the diagram shows no horizontal scroll bar and its
  boxes and arrows line up.

## Plan

1. **redraw the workflow diagram in 80 characters** (AC1, AC2, AC3) — inside-out: follows the
   current diagram at the top of `README.md`, with the same two rows, boxes, arrows and skill names.
   Touches documentation only
   - narrow each box and the gaps between them, so a row of three boxes and its return line fit in
     80 characters
   - reword the box texts that no longer fit, keeping each step's meaning
   - keep each full skill name under its box, even where it runs past the box's edge
   - check AC1 by measuring the longest line of the block. The free checks cover the plugin, not
     the README, so no permanent test is added
   - the plugin does not change, so its version stays as it is

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. redraw the workflow diagram in 80 characters
- Decision: each step's number moved into its box's top border, because "3 · Organize commits"
  didn't fit inside a narrower box. The box texts for steps 2, 4 and 5 were shortened
- AC1: met — the longest line of the diagram block measures 80 characters (was 99). No permanent
  test, as planned
- AC2: met — the diagram shows the five steps in order, each with its number, name, short
  description and full skill name
- AC3: met — confirmed by the user: the redrawn diagram, previewed before pushing
- the final design review was skipped
