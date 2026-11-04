# Refresh the README and add the aido mascot

## Context

The README opens without a visual identity, and its long paragraphs are hard to scan. A proposed
rewrite with a pixel-art robot mascot (`aido-complete-readme.zip`) improves both, but it misstates
what some skills do, drops some useful detail, moves the only manual setup step near the bottom, and
differs from the README's style. Its mascot has an opaque background and a 1.2 MB file, and its
`assets/` folder conflicts with the layout in `CLAUDE.md`.

## Intent

Adopt the proposed README's structure and wording, with the mascot on a transparent background,
while keeping the README accurate about the skills and consistent with the repository. All the
README's images live together in `docs/readme/`. The mascot belongs to the repository only.

## Out of scope

- changing the plugin: its icon, skills, guidelines, hooks and version stay as they are
- replacing the 🥋 in the README's heading
- changing the diagrams or the screenshot themselves

## Acceptance criteria

Layout

- AC1: the README opens with the mascot, the tagline, a one-line description and navigation links,
  and each link's anchor matches a heading in the README
- AC2: the top-level sections run Get started, Why aido?, How it works, Skills, Other ways to use
  aido, Engineering guidelines
- AC3: "Recommended Claude Code settings" is inside Get started, after the five steps and the
  planning walkthrough
- AC4: every skill in `plugins/aido/skills/` and every guideline in `plugins/aido/guidelines/` is
  listed in the README

Images

- AC5: `docs/assets/aido-mascot.png` is a byte-for-byte copy of the original transparent mascot,
  `Pixel Robot Mascot with Laptop.png`
- AC16: `docs/readme/aido-mascot-small.png` is a 520×520 PNG with a transparent background, resized
  from that original, and the README displays it at a width of 260
- AC6: the README's four images are all in `docs/readme/`, no image remains directly in `docs/`, and
  every image path in the README resolves
- AC7: the two diagrams keep their current alt text, which describes each stage

Accuracy and style

- AC8: the README presents the choice to implement, change or defer an unmet criterion as part of
  implementation, not verification
- AC9: step 04 says that `/aido:4-create-pr` offers verification, not that it always verifies
- AC10: the README says verification uses a fresh context so that the agent that built the change is
  not the one judging it
- AC11: the README uses British spelling, and its prose wraps at about 100 columns

Repository

- AC12: the layout in `CLAUDE.md` describes `docs/readme/` and `docs/assets/`
- AC13: the change adds no top-level `assets/` folder, does not commit the zip or the root copy of
  the mascot under its original name, and leaves `plugins/` untouched
- AC14: `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass
- AC15 (manual): the README renders well on GitHub in the light and dark themes, with no dark square
  behind the mascot

## Plan

1. **docs — move the existing images to `docs/readme/`**, updating the README's links (AC6)
2. **docs — add the mascot**: store the original as `docs/assets/aido-mascot.png`, and resize it to
   520×520 as `docs/readme/aido-mascot-small.png` (AC5, AC16)
3. **docs — adopt the proposed README**, with image paths under `docs/readme/` (AC1, AC2, AC4, AC6,
   AC16)
4. **docs — apply the corrections**: move the settings section, restore the alt text, correct the
   verification and step 04 wording, restore the fresh-context reason, and match the spelling and
   line wrapping (AC3, AC7, AC8, AC9, AC10, AC11)
5. **docs — update the layout in `CLAUDE.md`** (AC12)
6. **check**: confirm the diff's scope, run both validators, and have the user check the rendered
   README on GitHub (AC13, AC14, AC15)

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. moved the existing images to `docs/readme/`
- [x] 2. added the mascot: the original in `docs/assets/`, the 520×520 version in `docs/readme/`
- [x] 3. adopted the proposed README
- [x] 4. applied the corrections
- [x] 5. updated the layout in `CLAUDE.md`
- [x] 6. ran the checks, and removed the zip and the root copy of the mascot

Acceptance criteria. AC1 to AC13 and AC16 were checked by a throwaway script, not committed, because
`tests/` holds only the hook checks:

- AC1: met — mascot, tagline, description and nav present; every nav anchor matches a heading
- AC2: met — top-level sections in the agreed order
- AC3: met — settings section inside Get started, after the planning walkthrough
- AC4: met — every skill and guideline directory entry is listed
- AC5: met — `docs/assets/aido-mascot.png` has the original's SHA-256
- AC6: met — exactly four images in `docs/readme/`, all resolve, none directly in `docs/`
- AC7: met — both diagrams carry their previous alt text
- AC8: met — the choice is in the Implementation bullet, not the Verification one
- AC9: met — step 04 reads "Offer verification"
- AC10: met — the fresh-context reason is in the verification section
- AC11: met — no American spellings found, and no prose line over 100 columns
- AC12: met — the layout in `CLAUDE.md` names both folders
- AC13: met — no top-level `assets/`, zip and original name gone, `plugins/` unchanged
- AC14: met — `claude plugin validate .` and `claude plugin validate ./plugins/aido` passed
- AC15: met — confirmed by the user: shown the mascot previewed on light and dark backgrounds, before
  the branch was pushed
- AC16: met — 520×520 PNG with transparent corners, displayed at a width of 260

Decisions: the prose keeps "center" and "-ize" spellings, as the existing diagrams and skill names
do. The Systemic Design Checkpoint was skipped by the user. No refactorings were deferred.
