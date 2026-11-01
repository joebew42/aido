# Connect aido to AI-Augmented Engineering in the README

## Context

The README section "What is an AI-Augmented Engineer?" defines a generic role and then speaks of
"the workflow" without naming aido, so it is difficult to understand why that section is there.
The only link between the two is a sentence in the intro, about 40 lines earlier, and the README
gives no pointer to learn more about the wider field.

## Intent

A reader understands that aido is a workflow for working as an AI-augmented engineer, and why the
section is in the README. A reader who wants to know more about the wider field has a reference to
the page of Carnegie Mellon's Software Engineering Institute.

## Out of scope

- moving the section; it stays after "Recommended user settings"
- changing the other README sections, apart from the intro link and the title's emoji
- changing the plugin (skills, guidelines, hooks, `displayName`), so no version bump
- claiming that the Software Engineering Institute endorses aido or that aido derives from its work

## Acceptance criteria

- AC1: the section's heading names both aido and AI-Augmented Engineering
- AC2: the section opens with the short definition of an AI-augmented engineer and states that aido
  is a workflow for working that way
- AC3: the sentence introducing the bullets names aido instead of "the workflow", and the bullets
  describe what aido does
- AC4: the section is still directly after "Recommended user settings" and before "How the workflow
  works"
- AC5: the intro's mention of AI-Augmented Engineering links to the section, and the link resolves
  to the renamed heading
- AC6: the section has one sentence that names Carnegie Mellon's Software Engineering Institute and
  links to https://www.sei.cmu.edu/ai-augmented-software-engineering/ as further reading
- AC7 (manual): the section reads as the reason for aido, and the further-reading sentence implies
  no endorsement or lineage
- AC8: `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass
- AC9: the README's title is `# aido 🥋`, a nod to how the name evokes martial arts

## Plan

1. **docs — reframe the section around aido** (AC1, AC2, AC3, AC4, AC7): in `README.md`, rename the
   heading to "Why aido: AI-Augmented Engineering", keep the definition and follow it with the
   sentence that names aido, and adjust the bullets' wording only where they don't read as what aido
   does. The section stays in place
2. **docs — link the intro to the section** (AC5): in the intro at the top of `README.md`, link
   "AI-Augmented Engineering" to `#why-aido-ai-augmented-engineering`
3. **docs — add the further-reading sentence** (AC6, AC7): at the end of the section, one sentence
   pointing to the Software Engineering Institute's page for more about the wider field
4. **docs — add the emoji to the title** (AC9): in `README.md`, change the title to `# aido 🥋`
5. **chore — validate the plugin and marketplace** (AC8): run both validate commands

The enabling refactoring analysis was skipped.

## Progress

- [x] reframe the section around aido
- [x] link the intro to the section
- [x] add the further-reading sentence
- [x] add the emoji to the title
- [x] validate the plugin and marketplace

The repository has no test suite, so AC1 to AC6 and AC9 were checked by a throwaway shell script
against `README.md`; it was not committed.

- AC1: met — script check on the heading
- AC2: met — script check on the section's opening
- AC3: met — script check on the sentence before the bullets and the removed phrases
- AC4: met — script check on the order of the headings
- AC5: met — script check on the intro link; the anchor was derived from the heading, not clicked
  on GitHub
- AC6: met — script check on the institute's name and the link
- AC7: met — confirmed by the user: the new heading, the sentence before the bullets and the
  further-reading sentence
- AC8: met — both validate commands pass; the plugin one also warns about a missing icon, which
  this change did not cause
- AC9: met — script check on the title

Key decisions: 🥋 was chosen over 👘 because it is the martial arts uniform emoji. No version bump,
because the plugin is unchanged.

The final Systemic Design Checkpoint was skipped by the user. No deferred refactorings.
